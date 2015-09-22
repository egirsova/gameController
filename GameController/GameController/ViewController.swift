//
//  ViewController.swift
//  GameController
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var codeTF: UITextField!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var statusTF: UILabel!
    @IBOutlet var spinner: UIActivityIndicatorView!
    
    let codeEnteredNotificationKey = "elg_codeEntered"
    let updateConnectionNotificationKey = "elg_connectionUpdate"
    
    let serviceBrowser = ServiceBrowser()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        statusTF.hidden = true
        spinner.hidden = true
        enterButton.enabled = false
        
        codeTF.delegate = self
        codeTF.keyboardType = .NumberPad
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateConnectionDetails(notification: NSNotification) {
        print("In updateConnectionDetails...")
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let sessionStatus = userInfo["sessionStatus"]!
        print("sessionStatus: \(sessionStatus)")
        
        if(sessionStatus == "Connected") {
            print("trying to stop animation")
            
            dispatch_async(dispatch_get_main_queue(), {
            self.statusTF.text = "Connected!"
            print("statusTF Text: \(self.statusTF.text)")
            self.spinner.stopAnimating()
            self.spinner.hidden = true
                
            // Switch to controller view
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("controls")
                self.showViewController(vc! as UIViewController, sender: vc)
            })
        } 
    }
    
    @IBAction func enterButton(sender: UIButton)
    {
        self.view.endEditing(true)
        statusTF.hidden = false
        spinner.hidden = false
        spinner.startAnimating()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateConnectionDetails:", name: updateConnectionNotificationKey, object: nil)
        
        NSNotificationCenter.defaultCenter().postNotificationName(codeEnteredNotificationKey, object: self, userInfo: ["codeEntered": codeTF.text!])
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let newLength = codeTF.text!.utf16.count + string.utf16.count - range.length
        
        if (newLength == 4) {
            enterButton.enabled = true
        } else {
            enterButton.enabled = false
        }
        return newLength <= 4
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}

