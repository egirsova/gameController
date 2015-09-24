//
//  ServiceBrowser.swift
//  GameController
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceBrowser : NSObject {
    
    private let serviceBrowser : MCNearbyServiceBrowser
    
    private let gameServiceType = "elg-escape-game"
    private let peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
    var connectedPeerId: MCPeerID?
    
    let codeEnteredNotificationKey = "elg_codeEntered"
    let updateConnectionNotificationKey = "elg_connectionUpdate"
    let sendKeystrokesNotificationKey = "elg_sendKeystrokes"
    
    var currentBrowser: MCNearbyServiceBrowser?
    var currentFoundPeerId: MCPeerID?
    
    override init() {
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: gameServiceType)
        super.init()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        print("Started browsing for peers...")
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
        }()
    
    func sendInvite(notification: NSNotification) {
        print("Sending invite")
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let codeEntered = userInfo["codeEntered"]
        
        let codeData = codeEntered!.dataUsingEncoding(NSUTF8StringEncoding)
        currentBrowser!.invitePeer(currentFoundPeerId!, toSession: self.session, withContext: codeData, timeout: 10)
    }
}

extension ServiceBrowser : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        // Invite any peer discovered
        currentBrowser = browser
        currentFoundPeerId = peerID
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendInvite:", name: codeEnteredNotificationKey, object: nil)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "Not Connected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown Status"
        }
    }
}

extension ServiceBrowser : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.stringValue())")
        
        NSNotificationCenter.defaultCenter().postNotificationName(updateConnectionNotificationKey, object: self, userInfo: ["sessionStatus": state.stringValue()])
        
        if state.stringValue() == "Connected"{
            // We are now able to send data to the game app
            connectedPeerId = peerID
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendKeystrokes:", name: sendKeystrokesNotificationKey, object: nil)
        }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("peer \(peerID) didStartReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("peer \(peerID) didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveData: \(data)")
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveStream, with name: \(streamName)")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func sendKeystrokes(notification: NSNotification) {
        print("Going to send keystrokes to game app")
        
        let userInfo:Dictionary<String, NSData!> = notification.userInfo as! Dictionary<String, NSData!>
        let strokeInfoData: NSData = userInfo["strokeInfo"]!
        
        var strokeInfo: Keystroke = Keystroke()
        strokeInfoData.getBytes(&strokeInfo, length: sizeof(Keystroke))
        
        // First check if keystroke is a trackpad event, so that it can break apart the necessary information
        
        do {
            try session.sendData(strokeInfoData, toPeers: [self.connectedPeerId!], withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("Error: Could not send data")
        }
    }
}