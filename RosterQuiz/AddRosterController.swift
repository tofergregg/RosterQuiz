//
//  SecondViewController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit

class AddRosterController: UIViewController {
    @IBOutlet weak var rosterText: UITextView!
    @IBOutlet weak var rosterNameText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        rosterText.layer.borderWidth = 0.5
        rosterText.layer.borderColor = UIColor.grayColor().CGColor
        rosterText.layer.cornerRadius = 5.0
        rosterText.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
}

