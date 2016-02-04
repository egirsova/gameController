//
//  ServiceBrowser.swift
//  GameController
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct StreamData {
    static var stream: NSData?
}

class ServiceBrowser : NSObject {
    
    private let serviceBrowser : MCNearbyServiceBrowser
    
    private let gameServiceType = "elg-escape-game"
    
    private let peerId: MCPeerID
    private var connectedPeerId: MCPeerID?
    private var connectingTo: MCPeerID?
    
    var foundPeerIds: Array<MCPeerID>?
    private var defaults: NSUserDefaults
    private var outputStream: NSOutputStream?
    var byteIndex = 0
    
    override init() {
        
        defaults = NSUserDefaults.standardUserDefaults()
        if let peerIDData = defaults.dataForKey(Constants.UserDefaults.peerIDKey) {
            peerId = NSKeyedUnarchiver.unarchiveObjectWithData(peerIDData) as! MCPeerID
        } else {
            peerId = MCPeerID(displayName: UIDevice.currentDevice().name)
            let peerIDData = NSKeyedArchiver.archivedDataWithRootObject(peerId)
            defaults.setObject(peerIDData, forKey: Constants.UserDefaults.peerIDKey)
            defaults.synchronize()
        }
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerId, serviceType: gameServiceType)
        super.init()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        print("Started browsing for peers...")
        
        foundPeerIds = [MCPeerID]()
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
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let peerIdInvite = userInfo["peerId"]
        
        var mcPeerIdInvite: MCPeerID?
        
        for id in self.foundPeerIds! {
            if id.displayName == peerIdInvite {
                mcPeerIdInvite = id
            }
        }
        connectingTo = mcPeerIdInvite
        serviceBrowser.invitePeer(mcPeerIdInvite!, toSession: self.session, withContext: nil, timeout: 15)
    }
}

extension ServiceBrowser : MCNearbyServiceBrowserDelegate {
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID)")
        self.foundPeerIds?.append(peerID)
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.foundPeer, object: self, userInfo: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendInvite:", name: Constants.Notifications.sendInvite, object: nil)
        
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
        }
    }
}

extension ServiceBrowser : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.stringValue())")
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.updateConnection, object: self, userInfo: ["sessionStatus": state.stringValue()])
        
        if state == MCSessionState.Connected {
            // We are now able to send data to the game app
            if let attemptingToConnectTo = connectingTo {
                if attemptingToConnectTo == peerID {
                    connectedPeerId = peerID
                    //                    do {
                    //                        try outputStream = session.startStreamWithName("keystrokeStream", toPeer: connectedPeerId!)
                    //                        outputStream?.delegate = self
                    //                        outputStream?.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                    //                        outputStream?.open()
                    //                    } catch {
                    //                        print("could not start stream")
                    //                    }
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendReadySignal", name: Constants.Notifications.sendReadySignal, object: nil)
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendKeystrokes:", name: Constants.Notifications.sendKeystrokes, object: nil)
                }
            }
        }
        
        if state == MCSessionState.NotConnected {
            // Here must return to the main screen
            // Try sending invite again
            
        }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("peer \(peerID) didStartReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("peer \(peerID) didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        let receivedObject = NSKeyedUnarchiver.unarchiveObjectWithData(data)
        
        if let unarchivedData = receivedObject {
            if unarchivedData.isEqual("playerDead")  {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.switchToDeadView, object: self, userInfo: nil)
            } else if unarchivedData.isEqual("playerDamaged") {
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.vibrateDevice, object: self, userInfo: nil)
            }
        }
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveStream, with name: \(streamName)")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
    
    func sendReadySignal() {
        do {
            let readySignal = "Ready"
            let readySignalData = NSKeyedArchiver.archivedDataWithRootObject(readySignal)
            try session.sendData(readySignalData, toPeers: [self.connectedPeerId!], withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("Error: Could not send data")
        }
    }
    
    func sendKeystrokes(notification: NSNotification) {
        
        let userInfo:Dictionary<String, NSData!> = notification.userInfo as! Dictionary<String, NSData!>
        let strokeInfoData: NSData = userInfo["strokeInfo"]!
        
        var strokeInfo: Keystroke = Keystroke()
        strokeInfoData.getBytes(&strokeInfo, length: sizeof(Keystroke))
        
        do {
            try session.sendData(strokeInfoData, toPeers: [self.connectedPeerId!], withMode: MCSessionSendDataMode.Reliable)
        } catch {
            print("Error: Could not send data")
        }
        //        if let data = StreamData.stream {
        //            if outputStream!.hasSpaceAvailable {
        //            outputStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        //            }
        //        }
    }
}

extension ServiceBrowser : NSStreamDelegate
{
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            if let data = StreamData.stream {
                print("trying to send data")
                outputStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
                
            }
        default: break
        }
    }
}