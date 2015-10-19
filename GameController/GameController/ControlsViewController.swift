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
    @IBOutlet var interactButton: UIButton!
    @IBOutlet var attackButton: UIButton!
    @IBOutlet var movementTrackpadView: UIView!
    @IBOutlet var cameraTrackpadView: UIView!
    
    var movementTrackpadTGR: UITapGestureRecognizer?
    var movementTrackpadPGR: UIPanGestureRecognizer?
    
    var cameraTrackpadTGR: UITapGestureRecognizer?
    var cameraTrackpadPGR: UIPanGestureRecognizer?
    
    let sendKeystrokesNotificationKey = "elg_sendKeystrokes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crouchButton.layer.borderWidth = 0.5
        crouchButton.layer.borderColor = UIColor.whiteColor().CGColor
        interactButton.layer.borderWidth = 0.5
        interactButton.layer.borderColor = UIColor.whiteColor().CGColor
        attackButton.layer.borderWidth = 0.5
        attackButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Create the Tap Gesture Recognizer for the movement trackpad
        movementTrackpadTGR = UITapGestureRecognizer(target: self, action: "movementTrackpadRespondToTapGesture:")
        movementTrackpadTGR?.numberOfTapsRequired = 1
        movementTrackpadView.addGestureRecognizer(movementTrackpadTGR!)
        
        movementTrackpadPGR = UIPanGestureRecognizer(target: self, action: "movementTrackpadRespondToPanGesture:")
        movementTrackpadView.addGestureRecognizer(movementTrackpadPGR!)
        
        // Create the Tap Gesture Recognizer for the camera trackpad
        cameraTrackpadTGR = UITapGestureRecognizer(target: self, action: "cameraTrackpadRespondToTapGesture:")
        cameraTrackpadTGR?.numberOfTapsRequired = 2 // Double tap required for jump
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
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Movement
        strokeInfo.gestureType = Keystroke.GestureType.Tap
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    @IBAction func movementTrackpadRespondToPanGesture(recognizer: UIPanGestureRecognizer) {
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Movement
        strokeInfo.gestureType = Keystroke.GestureType.Pan
        
        let radius: CGFloat = 30.0
        let circle = CAShapeLayer()
        
        if recognizer.state == UIGestureRecognizerState.Began {
            // What to do when panning has just started
            let translationPoint = recognizer.translationInView(movementTrackpadView)
            strokeInfo.panTranslation = translationPoint
            strokeInfo.panStart = true
            
            circle.path = (UIBezierPath(roundedRect: CGRectMake(0, 0, CGFloat(2.0)*radius, 2.0*radius), cornerRadius: radius)).CGPath
            circle.position = CGPointMake(recognizer.locationInView(movementTrackpadView).x, recognizer.locationInView(movementTrackpadView).y)
            circle.fillColor = UIColor.redColor().CGColor
            circle.opacity = 0.3
            movementTrackpadView.layer.addSublayer(circle)
            
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            // What to do as user is panning
            let translationPoint = recognizer.translationInView(movementTrackpadView)
            strokeInfo.panTranslation = translationPoint
        } else if recognizer.state == UIGestureRecognizerState.Ended {
            // What to do when user has ceased panning
            dispatch_async(dispatch_get_main_queue(), {
                self.movementTrackpadView.layer.sublayers?.popLast() 
            })
            
        }
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    // Camera Trackpad Gesture Recognizers
    @IBAction func cameraTrackpadRespondToTapGesture(recognizer: UITapGestureRecognizer) {
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Camera
        strokeInfo.gestureType = Keystroke.GestureType.Tap
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    @IBAction func cameraTrackpadRespondToPanGesture(recognizer: UIPanGestureRecognizer) {
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Trackpad)
        strokeInfo.trackpadType = Keystroke.TrackpadType.Camera
        strokeInfo.gestureType = Keystroke.GestureType.Pan
        
        let radius: CGFloat = 30.0
        let circle = CAShapeLayer()
        
        if recognizer.state == UIGestureRecognizerState.Began {
            // What to do when panning has just started
            let translationPoint = recognizer.translationInView(cameraTrackpadView)
            strokeInfo.panTranslation = translationPoint
            strokeInfo.panStart = true
            
            circle.path = (UIBezierPath(roundedRect: CGRectMake(0, 0, CGFloat(2.0)*radius, 2.0*radius), cornerRadius: radius)).CGPath
            circle.position = CGPointMake(recognizer.locationInView(cameraTrackpadView).x, recognizer.locationInView(cameraTrackpadView).y)
            circle.fillColor = UIColor.greenColor().CGColor
            circle.opacity = 0.3
            cameraTrackpadView.layer.addSublayer(circle)
            
        } else if recognizer.state == UIGestureRecognizerState.Changed {
            // What to do as user is panning
            let translationPoint = recognizer.translationInView(cameraTrackpadView)
            strokeInfo.panTranslation = translationPoint
        } else if recognizer.state == UIGestureRecognizerState.Ended {
            // What to do when user has ceased panning
            dispatch_async(dispatch_get_main_queue(), {
                self.cameraTrackpadView.layer.sublayers?.popLast()
            })
        }
        
            let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    // MARK: - IBAction Button Response Methods
    // Other Controller Button Action Methods
    @IBAction func crouchButtonPressed(sender: UIButton) {
        print("crouch button pressed!")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Button)
        strokeInfo.button = Keystroke.Button.Crouch
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    @IBAction func interactButtonPressed(sender: UIButton) {
        print("interact button pressed")
        
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Button)
        strokeInfo.button = Keystroke.Button.Interact
        
        let userInfoData: NSData = NSData(bytes: &strokeInfo, length: sizeof(Keystroke))
        
        NSNotificationCenter.defaultCenter().postNotificationName(sendKeystrokesNotificationKey, object: self, userInfo: ["strokeInfo": userInfoData])
    }
    
    @IBAction func attackButtonPressed(sender: UIButton) {
        var strokeInfo = Keystroke(interactionType: Keystroke.InteractionType.Button)
        strokeInfo.button = Keystroke.Button.Attack
        
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
