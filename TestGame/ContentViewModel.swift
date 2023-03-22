//
//  ContentViewModel.swift
//  TestGame
//
//  Created by Mario Vanegas on 22/3/23.
//

import Foundation
import Combine
import MultipeerConnectivity

class ContentViewModel: NSObject, ObservableObject {
    @Published var message = ""
    @Published var friendsMessage = ""
    
    private var session: MCSession?
    private var advertiser: MCAdvertiserAssistant?
    
    func setup() {
        // Initialize session
        session = MCSession(peer: MCPeerID(displayName: UIDevice.current.name))
        session?.delegate = self
        
        guard let session = session else {
            fatalError("Session Not Found")
        }
        
        // Initialize advertiser
        advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
        advertiser?.start()
    }
    
    func sendMessage() {
        guard let session = session else {
            fatalError("Session Not Found")
        }
        
        sendMessage(message: message, toPeer: session.connectedPeers[0])
        showMessage(message: message, fromPeer: session.myPeerID)
    }
    
    func sendMessage(message: String, toPeer peerID: MCPeerID) {
        if session?.connectedPeers.contains(peerID) == true {
            guard let messageData = message.data(using: .utf8) else { return }
            do {
                try session?.send(messageData, toPeers: [peerID], with: .reliable)
            } catch {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func showMessage(message: String, fromPeer peerID: MCPeerID) {
        friendsMessage = "\(peerID.displayName): \(message)"
    }
}

extension ContentViewModel: MCSessionDelegate {
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("INPUT STREAM")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("INPUT RECEIVE RESOURCE")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("FINISHED RECEIVING")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let message = String(data: data, encoding: .utf8)
        print("Received message: \(message ?? "")")
        
        // Display the message on the screen
        DispatchQueue.main.async {
            self.showMessage(message: message ?? "", fromPeer: peerID)
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("Peer \(peerID.displayName) did change state to \(state)")
        
        // Handle peer state changes
        switch state {
        case .connected:
            print("Peer \(peerID.displayName) connected")
            // Send a welcome message to the new peer
            let message = "Welcome to the game!"
            sendMessage(message: message, toPeer: peerID)
        case .connecting:
            print("Peer \(peerID.displayName) connecting")
        case .notConnected:
            print("Peer \(peerID.displayName) not connected")
        @unknown default:
            fatalError("Unknown session state")
        }
    }
}
