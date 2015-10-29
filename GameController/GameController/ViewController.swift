//
//  ViewController.swift
//  GameController
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

struct Keystroke {
    enum InteractionType {
        case Button
        case Trackpad
    }
    enum TrackpadType {
        case Movement
        case Camera
    }
    enum GestureType {
        case Tap
        case Pan
    }
    enum Button {
        case Crouch
        case Attack
        case Interact
    }
    
    var interactionType: InteractionType?
    var trackpadType: TrackpadType?
    var gestureType: GestureType?
    var button: Button?
    var panTranslation: CGPoint?
    var panStart: Bool?
    
    init() {
        self.interactionType = nil
    }
    
    init(interactionType: InteractionType) {
        self.interactionType = interactionType
    }
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var peerTable: UITableView!
    @IBOutlet var statusTF: UILabel!
    @IBOutlet var titleTF: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    let kFoundPeer = "elg-foundPeer"
    let updateConnectionNotificationKey = "elg_connectionUpdate"
    let kSendInvite = "elg-sendInvite"
    
    let serviceBrowser = ServiceBrowser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusTF.hidden = true
        spinner.hidden = true
        
        peerTable.dataSource = self
        peerTable.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatePeerList:", name: kFoundPeer, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConnectionDetails:", name: updateConnectionNotificationKey, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func switchToMainScreen() {
        print("in switchToMainScreen")
        dispatch_async(dispatch_get_main_queue(), {
            print("in the main queue")
            // Switch to main screen
            //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("main")self.view
            [self.navigationController?.popToRootViewControllerAnimated(true)]
        })
    }
    
    func updatePeerList(notification: NSNotification) {
        self.peerTable.reloadData()
        self.titleTF.text = "Available Peers:"
        self.titleTF.textColor = UIColor.whiteColor()
    }
    
    func updateConnectionDetails(notification: NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let sessionStatus = userInfo["sessionStatus"]!
        
        if(sessionStatus == "Connected") {
            dispatch_async(dispatch_get_main_queue(), {
                self.statusTF.text = "Connected!"
                print("statusTF Text: \(self.statusTF.text)")
                self.spinner.stopAnimating()
                self.spinner.hidden = true
                
            // Switch to controller view
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("controls")
                self.showViewController(vc! as UIViewController, sender: vc)
            })
        } else if sessionStatus == "Not Connected" {
            dispatch_async(dispatch_get_main_queue(), {
                self.statusTF.text = "Unable to Connect"
                self.spinner.hidden = true
            })
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        
        if let peerIdsArray = serviceBrowser.foundPeerIds {
            count = peerIdsArray.count
        } else {
            count = 0
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->   UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("peerIdCell", forIndexPath: indexPath) as! UITableViewCell
        let peerArray = serviceBrowser.foundPeerIds!
        cell.textLabel?.text = peerArray[indexPath.item].displayName
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.sizeToFit()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.peerTable.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        
        NSNotificationCenter.defaultCenter().postNotificationName(kSendInvite, object: self, userInfo: ["peerId": cell!.textLabel!.text!])
        
        statusTF.text = "Connecting to Peer..."
        statusTF.hidden = false
        spinner.hidden = false
        spinner.startAnimating()
    }

}

