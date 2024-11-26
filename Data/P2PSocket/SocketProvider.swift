//
//  SocketProvider.swift
//  SocketProvider
//
//  Created by jung on 11/6/24.
//

import Combine
import Core
import MultipeerConnectivity

public final class SocketProvider: NSObject, SocketProvidable {
	fileprivate enum Constant {
		static let serviceType = "bestory"
	}
	
	// MARK: - Properties
	public let updatedPeer = PassthroughSubject<SocketPeer, Never>()
	public let invitationReceived = PassthroughSubject<SocketPeer, Never>()
    public let resourceShared = PassthroughSubject<SharedResource, Never>()
    public let isSynchronized = PassthroughSubject<Void, Never>()
	private var isAllowedInvitation: Bool = true
	private var invitationHandler: ((Bool, MCSession?) -> Void)?
	
	private let peerID = MCPeerID(displayName: UIDevice.current.name)
	private let browser: MCNearbyServiceBrowser
	private let advertiser: MCNearbyServiceAdvertiser
	private let session: MCSession
    private var sharingTasks = [Task<(), Never>]()
    private var sharedResources = [SharedResource]()
    private var syncFlags: [MCPeerID: Bool] = [:]
    
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
    
    func sendHashes(_ hashes: [String: String]) {
        guard let data = try? JSONSerialization.data(withJSONObject: hashes, options: []) else { return }
        try? session.send(data, toPeers: session.connectedPeers, with: .reliable)
        
        for peer in session.connectedPeers {
            syncFlags[peer] = false
        }
    }
	  
    func shareResource(url localUrl: URL, resourceName: String) async throws -> SharedResource {
        return try await withCheckedThrowingContinuation { resourceUrlContinuation in
            let uuid = UUID()
            let nameWithUUID = [resourceName, uuid.uuidString].joined(separator: "/")
            
            let recievers = session.connectedPeers
            let recieverCount = recievers.count
            let counter = Counter(targetCount: recieverCount)
            
            let sharedResource = SharedResource(
                localUrl: localUrl,
                name: resourceName,
                uuid: uuid,
                sender: session.myPeerID.displayName
            )
            
            let handler = continuedCountableResouceHandler(
                counter: counter,
                sharedResource: sharedResource,
                continuation: resourceUrlContinuation
            )
            
            recievers.forEach { peer in
                let progress = session.sendResource(
                    at: localUrl,
                    withName: nameWithUUID,
                    toPeer: peer,
                    withCompletionHandler: handler
                )
                
                guard progress == nil else { return }
                
                let error = ShareResourceError.peerFailedDownload(id: peerID.displayName)
                resourceUrlContinuation.resume(throwing: error)
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
        // hashes 관련 코드입니다.
        if let hashes = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
            let localHashes = FileSystemManager.shared.collectHashes()
            let result: SyncMessage = (hashes == localHashes) ? .hashMatch : .hashMismatch
            guard let data = try? JSONEncoder().encode(result) else { return }
            try? session.send(data, toPeers: [peerID], with: .reliable)
        }
        
        // 동기화 결과 관련 코드입니다.
        if let result = try? JSONDecoder().decode(SyncMessage.self, from: data) {
            switch result {
            case .hashMatch:
                syncFlags[peerID] = true
                let allSynced = syncFlags.values.allSatisfy { $0 }
                if allSynced {
                    guard let completedMessage = try? JSONEncoder().encode(SyncMessage.completed) else { return }
                    try? session.send(completedMessage,
                        toPeers: session.connectedPeers,
                        with: .reliable
                    )
                    isSynchronized.send(())
                }
            case .hashMismatch:
                return
            case .completed:
                isSynchronized.send(())
            }
        }
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
	
	public func session(
		_ session: MCSession,
		didFinishReceivingResourceWithName resourceName: String,
		fromPeer peerID: MCPeerID,
		at localURL: URL?,
		withError error: (any Error)?
	) {
        let fileSystemManager = FileSystemManager.shared
        guard let localURL,
              let (resourceName, uuid) = ResourceValidator.extractInformation(name: resourceName),
              let url = fileSystemManager.copyToFileSystemWithName(
                tempURL: localURL,
                resourceName: resourceName
              ) else { return }
        
        let resource = SharedResource(
            localUrl: url,
            name: resourceName,
            uuid: uuid,
            sender: peerID.displayName
        )
        sharedResources.append(resource)
        resourceShared.send(resource)
    }
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
    
    func continuedCountableResouceHandler(
        counter: Counter,
        sharedResource resource: SharedResource,
        continuation: CheckedContinuation<SharedResource, any Error>
    ) -> ((any Error)?) -> Void {
        return { [weak self] error in
            let task = Task {
                if let error {
                    return continuation.resume(throwing: error)
                }
                await counter.increaseNumber()
                if await counter.didReachedTargetNumber() {
                    self?.sharedResources.append(resource)
                    self?.resourceShared.send(resource)
                    
                    return continuation.resume(returning: resource)
                }
            }
            self?.sharingTasks.append(task)
        }
    }
}

private extension SocketProvider {
    enum SyncMessage: Codable {
        case hashMatch
        case hashMismatch
        case completed
    }
}
