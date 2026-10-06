import Combine
import Foundation
import MultipeerConnectivity
import UIKit

final class RemotePoseLink: NSObject {
    enum Role {
        case idle
        case camera
        case monitor
    }

    let remotePosePublisher = PassthroughSubject<PoseSnapshot, Never>()
    let statusPublisher = CurrentValueSubject<String, Never>("Remote off")

    private let serviceType = "poselab-body"
    private let localPeer = MCPeerID(displayName: UIDevice.current.name)

    private lazy var session: MCSession = {
        let session = MCSession(
            peer: localPeer,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        session.delegate = self
        return session
    }()

    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private(set) var role: Role = .idle

    func startCamera() {
        stop()
        role = .camera

        let advertiser = MCNearbyServiceAdvertiser(
            peer: localPeer,
            discoveryInfo: ["role": "camera"],
            serviceType: serviceType
        )
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser
        statusPublisher.send("Waiting for iPad…")
    }

    func startMonitor() {
        stop()
        role = .monitor

        let browser = MCNearbyServiceBrowser(
            peer: localPeer,
            serviceType: serviceType
        )
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser
        statusPublisher.send("Searching for iPhone…")
    }

    func stop() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()
        advertiser = nil
        browser = nil
        session.disconnect()
        role = .idle
        statusPublisher.send("Remote off")
    }

    func send(_ pose: PoseSnapshot) {
        guard role == .camera,
              !session.connectedPeers.isEmpty
        else { return }

        do {
            let data = try JSONEncoder().encode(PosePacket(snapshot: pose))
            try session.send(
                data,
                toPeers: session.connectedPeers,
                with: .unreliable
            )
        } catch {
            statusPublisher.send("Pose send failed")
        }
    }

    private func connectedText() -> String {
        guard let first = session.connectedPeers.first else {
            return role == .camera ? "Waiting for iPad…" : "Searching for iPhone…"
        }

        return "Connected: \(first.displayName)"
    }
}

extension RemotePoseLink: MCNearbyServiceAdvertiserDelegate {
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        invitationHandler(true, session)
    }

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: Error
    ) {
        statusPublisher.send("Camera advertising failed")
    }
}

extension RemotePoseLink: MCNearbyServiceBrowserDelegate {
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        guard role == .monitor,
              session.connectedPeers.isEmpty,
              peerID != localPeer
        else { return }

        statusPublisher.send("Connecting to \(peerID.displayName)…")
        browser.invitePeer(
            peerID,
            to: session,
            withContext: nil,
            timeout: 10
        )
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {}

    func browser(
        _ browser: MCNearbyServiceBrowser,
        didNotStartBrowsingForPeers error: Error
    ) {
        statusPublisher.send("Monitor discovery failed")
    }
}

extension RemotePoseLink: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        switch state {
        case .connected:
            statusPublisher.send("Connected: \(peerID.displayName)")
        case .connecting:
            statusPublisher.send("Connecting to \(peerID.displayName)…")
        case .notConnected:
            statusPublisher.send(connectedText())
        @unknown default:
            statusPublisher.send("Remote state changed")
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        guard role == .monitor,
              let packet = try? JSONDecoder().decode(PosePacket.self, from: data),
              let snapshot = packet.snapshot()
        else { return }

        remotePosePublisher.send(snapshot)
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}
