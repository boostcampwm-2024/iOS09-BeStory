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
    var resourceShared: PassthroughSubject<SharedResource, Never> { get }
	/// Browsing된 Peer를 리턴합니다.
	func browsingPeers() -> [SocketPeer]
	/// Session에 연결된 Peer를 리턴합니다.
	func connectedPeers() -> [SocketPeer]
	
	/// 유저를 초대합니다.
	func invite(peer id: String, timeout: Double)
	
	func acceptInvitation()
	func rejectInvitation()
	
	func startReceiveInvitation()
	func stopReceiveInvitation()
	
	func startAdvertising()
	func stopAdvertising()
	func startBrowsing()
	func stopBrowsing()
    
    /// 연결된 모든 Peer들에게 리소스를 전송합니다.
    @discardableResult
    func shareResource(url: URL, resourceName: String) async throws -> SharedResource
    /// Peer들과 공유한 모든 리소스를 리턴합니다.
    func sharedAllResources() -> [SharedResource]
}

public final class SocketProvider: NSObject, SocketProvidable {
	fileprivate enum Constant {
		static let serviceType = "beStory"
	}
	
	// MARK: - Properties
	public let updatedPeer = PassthroughSubject<SocketPeer, Never>()
	public let invitationReceived = PassthroughSubject<SocketPeer, Never>()
    public let resourceShared = PassthroughSubject<SharedResource, Never>()

	private var isAllowedInvitation: Bool = true
	private var invitationHandler: ((Bool, MCSession?) -> Void)?

	private let peerID = MCPeerID(displayName: UIDevice.current.name)
	private let browser: MCNearbyServiceBrowser
	private let advertiser: MCNearbyServiceAdvertiser
	private let session: MCSession
    private var sharingTasks = [Task<(), Never>]()
    private var sharedResources = [SharedResource]()
    
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
        sharingTasks.forEach {
            $0.cancel()
        }
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
	
	func invite(peer id: String, timeout: Double) {
		guard let peer = MCPeerIDStorage.shared.peerIDByIdentifier[id] else { return }

		browser.invitePeer(
			peer.id,
			to: session,
			withContext: nil,
			timeout: .init(timeout)
		)
	}
	
	func startReceiveInvitation() {
		isAllowedInvitation = true
	}
	
	func stopReceiveInvitation() {
		isAllowedInvitation = false
	}
	
	func acceptInvitation() {
		invitationHandler?(true, session)
		
		invitationHandler = nil
	}
	
	func rejectInvitation() {
		invitationHandler?(false, session)
		
		invitationHandler = nil
	}
    
    func shareResource(url localUrl: URL, resourceName: String) async throws -> SharedResource {
        return try await withCheckedThrowingContinuation { resourceUrlContinuation in
            let uuid = UUID()
            let resourceName = [resourceName, uuid.uuidString].joined(separator: "/")
            
            let recievers = session.connectedPeers
            let recieverCount = recievers.count
            let counter = Counter(targetCount: recieverCount)
            
            recievers.forEach { peer in
                let progress = session.sendResource(at: localUrl,
                                                    withName: resourceName,
                                                    toPeer: peer,
                                                    withCompletionHandler: { [weak self] error in
                    let task = Task {
                        if let error {
                            return resourceUrlContinuation.resume(throwing: error)
                        }
                        await counter.increaseNumber()
                        if await counter.currentNumber == recieverCount {
                            let sharedResource = SharedResource(localUrl: localUrl,
                                                                name: resourceName,
                                                                uuid: uuid,
                                                                sender: peer.displayName)
                            self?.resourceShared.send(sharedResource)
                            return resourceUrlContinuation.resume(returning: sharedResource)
                        }
                    }
                    self?.sharingTasks.append(task)
                })
                
                if progress == nil {
                    let error = ShareResourceError.peerFailedDownload(id: peerID.displayName)
                    resourceUrlContinuation.resume(throwing: error)
                }
            }
        }
    }
    
    func sharedAllResources() -> [SharedResource] {
        return sharedResources
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
	) {
        if let localURL,
            let (resourceName, uuid) = ResourceValidator.extractInformation(name: resourceName) {
            let resource = SharedResource(localUrl: localURL,
                                                name: resourceName,
                                                uuid: uuid,
                                                sender: peerID.displayName)
            resourceShared.send(resource)
        }
    }
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
}
