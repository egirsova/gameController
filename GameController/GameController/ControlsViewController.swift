//
//  ControlsViewController.swift
//  GameController
//
//  Created by Liza Girsova on 9/22/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit
import QuartzCore

class ControlsViewController: UIViewController {

    @IBOutlet var crouchButton: UIButton!
    @IBOutlet var movementTrackpadView: UIView!
    @IBOutlet var cameraTrackpadView: UIView!
    
    var movementTrackpadTGR: UITapGestureRecognizer?
    var movementTrackpadLPGR: UILongPressGestureRecognizer?
    
    var cameraTrackpadTGR: UITapGestureRecognizer?
    var cameraTrackpadLPGR: UILongPressGestureRecognizer?
    
    let sendKeystrokesNotificationKey = "elg_sendKeystrokes"
    let kMovementTrackpad = 0
    let kCameraTrackpad = 1
    let kTapGesture = 0
    let kLongPressGesture = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crouchButton.layer.borderWidth = 1.0
        crouchButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Create the Tap Gesture Recognizer for the movement trackpad
        movementTrackpadTGR = UITapGestureRecognizer(target: self, action: "movementTrackpadRespondToTapGesture:")
        movementTrackpadTGR?.numberOfTapsRequired = 1
        movementTrackpadView.addGestureRecognizer(movementTrackpadTGR!)
        
        movementTrackpadLPGR = UILongPressGestureRecognizer(target: self, action: "movementTrackpadRespondToLongPress:")
        movementTrackpadLPGR?.numberOfTapsRequired = 0
        movementTrackpadView.addGestureRecognizer(movementTrackpadLPGR!)
        
        // Create the Tap Gesture Recognizer for the camera trackpad
        cameraTrackpadTGR = UITapGestureRecognizer(target: self, action: "cameraTrackpadRespondToTapGesture:")
        cameraTrackpadTGR?.numberOfTapsRequired = 1
        cameraTrackpadView.addGestureRecognizer(cameraTrackpadTGR!)
        
        cameraTrackpadLPGR = UILongPressGestureRecognizer(target: self, action: "cameraTrackpadRespondToLongPress:")
        cameraTrackpadLPGR?.numberOfTapsRequired = 0
        cameraTrackpadView.addGestureRecognizer(cameraTrackpadLPGR!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Gesture Recognizer Response Methods
    // Movement Trackpad Gesture Recognizers
    @IBAction func movementTrackpadRespondToTapGesture(recognizer: UITapGestureRecognizer) {
        print ("movement trackpad tapped!")
        // Must send the movement information to the game app
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["trackpad": kMovementTrackpad, "gesture":kTapGesture])
    }
    
    @IBAction func movementTrackpadRespondToLongPress(recognizer: UILongPressGestureRecognizer) {
        print ("movement trackpad long press!")
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["trackpad": kMovementTrackpad, "gesture":kLongPressGesture])
    }
    
    // Camera Trackpad Gesture Recognizers
    @IBAction func cameraTrackpadRespondToTapGesture(recognizer: UITapGestureRecognizer) {
        print ("camera trackpad tapped!")
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["trackpad": kCameraTrackpad, "gesture":kTapGesture])
    }
    
    @IBAction func cameraTrackpadRespondToLongPress(recognizer: UILongPressGestureRecognizer) {
        print ("camera trackpad long press!")
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["trackpad": kCameraTrackpad, "gesture":kLongPressGesture])
    }
    
    // MARK: - IBAction Button Response Methods
    // Other Controller Button Action Methods
    @IBAction func crouchButton(sender: UIButton) {
        print("crouch button pressed!")
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
