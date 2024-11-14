//
//  SocketProvider.swift
//  SocketProvider
//
//  Created by jung on 11/6/24.
//

import Combine
import MultipeerConnectivity

public protocol SocketProvidable {
	var updatedPeer: PassthroughSubject<SocketPeer, Never> { get }
	var invitationReceived: PassthroughSubject<SocketPeer, Never> { get }
	/// Browsing된 Peer를 리턴합니다.
	func browsingPeers() -> [SocketPeer]
	/// Session에 연결된 Peer를 리턴합니다.
	func connectedPeers() -> [SocketPeer]
	
	/// 유저를 초대합니다.
	func invite(peer id: String)
	
	func acceptInvitation()
	func rejectInvitation()
	
	func startAdvertising()
	func stopAdvertising()
	func startBrowsing()
	func stopBrowsing()
}

public final class SocketProvider: NSObject, SocketProvidable {
	fileprivate enum Constant {
		static let invitationTimeOut = TimeInterval(30)
		static let serviceType = "beStory"
	}
	
	// MARK: - Properties
	public let updatedPeer = PassthroughSubject<SocketPeer, Never>()
	public let invitationReceived = PassthroughSubject<SocketPeer, Never>()

	private var invitationTimer: Timer?
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

// MARK: - Public Methods
public extension SocketProvider {
	func startAdvertising() {
		advertiser.startAdvertisingPeer()
	}
	
	func stopAdvertising() {
		advertiser.stopAdvertisingPeer()
	}
	
	func startBrowsing() {
		browser.startBrowsingForPeers()
	}
	
	func stopBrowsing() {
		browser.stopBrowsingForPeers()
	}
	
	func connectedPeers() -> [SocketPeer] {
		return MCPeerIDStorage.shared
			.peerIDByIdentifier
			.filter { $0.value.state == .connected }
			.map {
				let name = $0.value.id.displayName
				let id = $0.key
				return SocketPeer(id: id, name: name, state: .connected)
			}
	}
	
	func browsingPeers() -> [SocketPeer] {
		return MCPeerIDStorage.shared
			.peerIDByIdentifier
			.filter { $0.value.state == .found }
			.map {
				let name = $0.value.id.displayName
				let id = $0.key
				return SocketPeer(id: id, name: name, state: .connected)
			}
	}
	
	func invite(peer id: String) {
		guard let peer = MCPeerIDStorage.shared.peerIDByIdentifier[id] else { return }

		browser.invitePeer(
			peer.id,
			to: session,
			withContext: nil,
			timeout: Constant.invitationTimeOut
		)
	}
	
	func acceptInvitation() {
		invitationHandler?(true, session)
		
		invitationHandler = nil
		stopInvitationTimer()
	}
	
	func rejectInvitation() {
		invitationHandler?(false, session)
		
		invitationHandler = nil
		stopInvitationTimer()
	}
}

// MARK: - MCSessionDelegate
extension SocketProvider: MCSessionDelegate {
	public func session(
		_ session: MCSession,
		peer peerID: MCPeerID,
		didChange state: MCSessionState
	) {
		defer {
			if let socketPeer = mapToSocketPeer(peerID) { updatedPeer.send(socketPeer)
			}
		}
		
		switch state {
			case .connected:
				MCPeerIDStorage.shared.update(state: .connected, id: peerID)
			case .notConnected:
				MCPeerIDStorage.shared.update(state: .disconnected, id: peerID)
			case .connecting:
				MCPeerIDStorage.shared.update(state: .connecting, id: peerID)
			@unknown default: break
		}
	}
	
	public func session(
		_ session: MCSession,
		didReceive data: Data,
		fromPeer peerID: MCPeerID
	) { }
	
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
	
	public func session(
		_ session: MCSession,
		didFinishReceivingResourceWithName resourceName: String,
		fromPeer peerID: MCPeerID,
		at localURL: URL?,
		withError error: (any Error)?
	) { }
}

// MARK: - MCNearbyServiceBrowserDelegate
extension SocketProvider: MCNearbyServiceBrowserDelegate {
	public func browser(
		_ browser: MCNearbyServiceBrowser,
		foundPeer peerID: MCPeerID,
		withDiscoveryInfo info: [String: String]?
	) {
		MCPeerIDStorage.shared.append(id: peerID, state: .found)
		
		guard let peer = mapToSocketPeer(peerID) else { return }
		updatedPeer.send(peer)
	}
	
	public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
		defer { MCPeerIDStorage.shared.remove(id: peerID) }
		
		guard var peer = mapToSocketPeer(peerID) else { return }
		peer.state = .lost
		updatedPeer.send(peer)
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
			self.invitationHandler == nil,
			let invitationPeer = mapToSocketPeer(peerID)
		else { return }
		
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
	
	func startInvitationTimer() {
		invitationTimer?.invalidate()
		invitationTimer = Timer.scheduledTimer(
			timeInterval: Constant.invitationTimeOut,
			target: self,
			selector: #selector(invitationTimerDidFired),
			userInfo: nil,
			repeats: false
		)
	}
	
	func stopInvitationTimer() {
		invitationTimer?.invalidate()
		invitationTimer = nil
	}
	
	@objc func invitationTimerDidFired() {
		// TODO: - Send to Stream
	}
}
