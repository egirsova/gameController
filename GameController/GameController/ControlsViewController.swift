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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        crouchButton.layer.borderWidth = 1.0

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
