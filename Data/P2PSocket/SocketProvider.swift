//
//  SocketProvider.swift
//  SocketProvider
//
//  Created by jung on 11/6/24.
//

import Combine
import Core
import MultipeerConnectivity

public final class SocketProvider: NSObject {
	fileprivate enum Constant {
		static let serviceType = "bestory"
	}
	
	// MARK: - Properties
	public let updatedPeer = PassthroughSubject<SocketPeer, Never>()
	public let invitationReceived = PassthroughSubject<SocketPeer, Never>()
	public let resourceShared = PassthroughSubject<SharedResource, Never>()
	public let dataShared = PassthroughSubject<(Data, SocketPeer), Never>()
	
	private var isAllowedInvitation: Bool = true
	private var invitationHandler: ((Bool, MCSession?) -> Void)?
	
	private let peerID = MCPeerID(displayName: UIDevice.current.name)
	private let browser: MCNearbyServiceBrowser
	private let advertiser: MCNearbyServiceAdvertiser
	private let session: MCSession
	
	// MARK: - Initializers
	public override init() {
		self.browser = .init(peer: peerID, serviceType: Constant.serviceType)
		self.advertiser = .init(
			peer: peerID,
			discoveryInfo: nil,
			serviceType: Constant.serviceType
		)
		self.session = .init(peer: peerID)
		super.init()
		
		startBrowsing()
		startAdvertising()
		configureDelegate()
	}
	
	deinit {
		stopBrowsing()
		stopAdvertising()
	}
}

// MARK: - SocketInvitable
extension SocketProvider: SocketAdvertiseable {
	public func startAdvertising() {
		advertiser.startAdvertisingPeer()
	}
	
	public func stopAdvertising() {
		advertiser.stopAdvertisingPeer()
	}
}

// MARK: - SocketBrowsable
extension SocketProvider: SocketBrowsable {
	public func browsingPeers() -> [SocketPeer] {
		return MCPeerIDStorage.shared
			.peerIDByIdentifier
			.filter { $0.value.state == .found }
			.map {
				let name = $0.value.id.displayName
				let id = $0.key
				return SocketPeer(id: id, name: name, state: .connected)
			}
	}
	
	public func connectedPeers() -> [SocketPeer] {
		return MCPeerIDStorage.shared
			.peerIDByIdentifier
			.filter { $0.value.state == .connected || $0.value.state == .pending }
			.map {
				let name = $0.value.id.displayName
				let id = $0.key
				return SocketPeer(id: id, name: name, state: .connected)
			}
	}
	
	public func startBrowsing() {
		browser.startBrowsingForPeers()
	}
	
	public func stopBrowsing() {
		browser.stopBrowsingForPeers()
	}
}

// MARK: - SocketInvitable
extension SocketProvider: SocketInvitable {
	public func invite(peer id: String, timeout: Double) {
		guard let peer = MCPeerIDStorage.shared.peerIDByIdentifier[id] else { return }
		
		browser.invitePeer(
			peer.id,
			to: session,
			withContext: nil,
			timeout: .init(timeout)
		)
	}
	
	public func startReceiveInvitation() {
		isAllowedInvitation = true
	}
	
	public func stopReceiveInvitation() {
		isAllowedInvitation = false
	}
	
	public func acceptInvitation() {
		invitationHandler?(true, session)
		
		invitationHandler = nil
	}
	
	public func rejectInvitation() {
		invitationHandler?(false, session)
		
		invitationHandler = nil
	}
}

// MARK: - SocketDisconnectable
extension SocketProvider: SocketDisconnectable {
	// TODO: - 이거 가능한지 확인해볼 것
	public func disconnect() {
		session.disconnect()
	}
}

// MARK: - SocketResourceSendable
extension SocketProvider: SocketResourceSendable {
	public func sendResource(
		url localURL: URL,
		resourceName: String,
		to peerID: String
	) {
		guard let mcPeerID = MCPeerIDStorage.shared.peerIDByIdentifier[peerID]?.id else { return }
		
		session.sendResource(
			at: localURL,
			withName: resourceName,
			toPeer: mcPeerID
		)
	}
	
	public func broadcastResource(url localUrl: URL, resourceName: String) {
		session.connectedPeers.forEach { peer in
			session.sendResource(
				at: localUrl,
				withName: resourceName,
				toPeer: peer
			)
		}
	}
}

// MARK: - SocketDataSendable
extension SocketProvider: SocketDataSendable {
	public func send(data: Data, to peerID: String) {
		guard let mcPeerID = MCPeerIDStorage.shared.peerIDByIdentifier[peerID]?.id else { return }
		try? session.send(data, toPeers: [mcPeerID], with: .reliable)
	}
	
	public func broadcast(data: Data) {
		try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
	}
}

// MARK: - MCSessionDelegate
extension SocketProvider: MCSessionDelegate {
	public func session(
		_ session: MCSession,
		peer peerID: MCPeerID,
		didChange state: MCSessionState
	) {
		guard let socketPeer = mapToSocketPeer(peerID) else { return }
		
		var willRemovedAtStorage: Bool = false
		
		switch state {
			case .connected:
				MCPeerIDStorage.shared.update(state: .connected, id: peerID)
			case .notConnected:
				willRemovedAtStorage = socketPeer.state == .connected
				MCPeerIDStorage.shared.update(state: .disconnected, id: peerID)
			default: break
		}
		
		if let sendSocketPeer = mapToSocketPeer(peerID) {
			updatedPeer.send(sendSocketPeer)
		}
		
		if willRemovedAtStorage {
			MCPeerIDStorage.shared.remove(id: peerID)
		}
	}
	
	public func session(
		_ session: MCSession,
		didReceive data: Data,
		fromPeer peerID: MCPeerID
	) {
		guard let socketPeer = mapToSocketPeer(peerID) else { return }
		
		dataShared.send((data, socketPeer))
	}
	
	public func session(
		_ session: MCSession,
		didFinishReceivingResourceWithName resourceName: String,
		fromPeer peerID: MCPeerID,
		at localURL: URL?,
		withError error: (any Error)?
	) {
		let fileSystemManager = FileSystemManager.shared
		guard
			let localURL,
			let url = fileSystemManager.copyToFileSystem(tempURL: localURL, resourceName: resourceName),
			let socketPeer = mapToSocketPeer(peerID)
		else { return }
		
		let resource = SharedResource(
			url: url,
			name: resourceName,
			sender: socketPeer
		)

		resourceShared.send(resource)
	}
	
	public func session(
		_ session: MCSession,
		didReceive stream: InputStream,
		withName streamName: String,
		fromPeer peerID: MCPeerID
	) { }
	
	public func session(
		_ session: MCSession,
		didStartReceivingResourceWithName resourceName: String,
		fromPeer peerID: MCPeerID,
		with progress: Progress
	) { }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension SocketProvider: MCNearbyServiceBrowserDelegate {
	public func browser(
		_ browser: MCNearbyServiceBrowser,
		foundPeer peerID: MCPeerID,
		withDiscoveryInfo info: [String: String]?
	) {
		if let peer = MCPeerIDStorage.shared.findPeer(for: peerID)?.value {
			if peer.state == .pending {
				MCPeerIDStorage.shared.update(state: .connected, id: peerID)
			}
		} else {
			MCPeerIDStorage.shared.append(id: peerID, state: .found)
		}
		
		guard let peer = mapToSocketPeer(peerID) else { return }
		updatedPeer.send(peer)
	}
	
	public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		guard var peer = mapToSocketPeer(peerID) else { return }
		
		if peer.state == .connected {
			MCPeerIDStorage.shared.update(state: .pending, id: peerID)
			peer.state = .pending
		} else if peer.state == .found {
			peer.state = .lost
		}
		
		updatedPeer.send(peer)
		
		if peer.state == .lost {
			MCPeerIDStorage.shared.remove(id: peerID)
		}
	}
}

// MARK: - MCNearbyServiceAdvertiserDelegate
extension SocketProvider: MCNearbyServiceAdvertiserDelegate {
	public func advertiser(
		_ advertiser: MCNearbyServiceAdvertiser,
		didReceiveInvitationFromPeer peerID: MCPeerID,
		withContext context: Data?,
		invitationHandler: @escaping (Bool, MCSession?) -> Void
	) {
		guard
			isAllowedInvitation,
			let invitationPeer = mapToSocketPeer(peerID)
		else { return invitationHandler(false, session) }
		
		invitationReceived.send(invitationPeer)
		self.invitationHandler = invitationHandler
	}
}

// MARK: - Private Methods
private extension SocketProvider {
	func configureDelegate() {
		session.delegate = self
		browser.delegate = self
		advertiser.delegate = self
	}
	
	func mapToSocketPeer(_ peerID: MCPeerID) -> SocketPeer? {
		guard let peer = MCPeerIDStorage.shared.findPeer(for: peerID) else { return nil }
		let state = peer.value.state
		let name = peer.value.id.displayName
		let id = peer.key
		
		return .init(id: id, name: name, state: state)
	}
	
	/// 자신의 `SocketPeer`를 리턴합니다.
	func socketPeer() -> SocketPeer {
		.init(id: "0", name: peerID.displayName, state: .connected)
	}
}
