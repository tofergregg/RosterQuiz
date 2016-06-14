//
//  StudentInfoController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/14/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit

class StudentInfoController : UIViewController {
    
    var student : Student! = nil
    
    @IBOutlet weak var studentPic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (student != nil) {
            navigationItem.title = student.commaName()
            studentPic.image = student.picture
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}