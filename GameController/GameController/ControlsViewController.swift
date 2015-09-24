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
    var movementTrackpadPGR: UIPanGestureRecognizer?
    
    var cameraTrackpadTGR: UITapGestureRecognizer?
    var cameraTrackpadPGR: UIPanGestureRecognizer?
    
    let sendKeystrokesNotificationKey = "elg_sendKeystrokes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crouchButton.layer.borderWidth = 1.0
        crouchButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Create the Tap Gesture Recognizer for the movement trackpad
        movementTrackpadTGR = UITapGestureRecognizer(target: self, action: "movementTrackpadRespondToTapGesture:")
        movementTrackpadTGR?.numberOfTapsRequired = 1
        movementTrackpadView.addGestureRecognizer(movementTrackpadTGR!)
        
        movementTrackpadPGR = UIPanGestureRecognizer(target: self, action: "movementTrackpadRespondToPanGesture:")
        movementTrackpadView.addGestureRecognizer(movementTrackpadPGR!)
        
        // Create the Tap Gesture Recognizer for the camera trackpad
        cameraTrackpadTGR = UITapGestureRecognizer(target: self, action: "cameraTrackpadRespondToTapGesture:")
        cameraTrackpadTGR?.numberOfTapsRequired = 1
        cameraTrackpadView.addGestureRecognizer(cameraTrackpadTGR!)
        
        cameraTrackpadPGR = UIPanGestureRecognizer(target: self, action: "cameraTrackpadRespondToPanGesture:")
        cameraTrackpadView.addGestureRecognizer(cameraTrackpadPGR!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Gesture Recognizer Response Methods
    // Movement Trackpad Gesture Recognizers
    @IBAction func movementTrackpadRespondToTapGesture(recognizer: UITapGestureRecognizer) {
        print ("movement trackpad tapped!")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Movement
        strokeInfo.gestureType = Keystroke.GestureType.Tap
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    @IBAction func movementTrackpadRespondToPanGesture(recognizer: UIPanGestureRecognizer) {
        print ("movement trackpad pan gesture!")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Movement
        strokeInfo.gestureType = Keystroke.GestureType.Pan
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    // Camera Trackpad Gesture Recognizers
    @IBAction func cameraTrackpadRespondToTapGesture(recognizer: UITapGestureRecognizer) {
        print ("camera trackpad tapped!")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Camera
        strokeInfo.gestureType = Keystroke.GestureType.Tap
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    @IBAction func cameraTrackpadRespondToPanGesture(recognizer: UIPanGestureRecognizer) {
        print ("camera trackpad pan gesture!")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Camera
        strokeInfo.gestureType = Keystroke.GestureType.Pan
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    // MARK: - IBAction Button Response Methods
    // Other Controller Button Action Methods
    @IBAction func crouchButton(sender: UIButton) {
        print("crouch button pressed!")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Button)
        strokeInfo.button = Keystroke.Button.Crouch
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
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
