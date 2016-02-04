//
//  Constants.swift
//  GameController
//
//  Created by Liza on 12/16/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation

struct Constants {
    struct Notifications {
        static let foundPeer = "elg-foundPeer"
        static let sendInvite = "elg-sendInvite"
        static let updateConnection = "elg_connectionUpdate"
        static let sendKeystrokes = "elg_sendKeystrokes"
        static let sendReadySignal = "elg_readySignal"
        static let switchToDeadView = "elg_switchToDeadView"
        static let vibrateDevice = "elg_vibrateDevice"
    }
    
    struct UserDefaults {
        static let peerIDKey = "elg-peerid"
    }
}