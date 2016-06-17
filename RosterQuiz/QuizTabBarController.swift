//
//  QuizController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/16/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit

class QuizTabBarController : UITabBarController {
    var roster : Roster?
    
    override func viewDidLoad() {
        let rightButton = UIBarButtonItem(title: "⚙", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = rightButton
        
        // populate the roster of both controllers with roster from the original viewcontroller
        (viewControllers![0] as! QuizController).roster = roster
        (viewControllers![1] as! QuizController).roster = roster
        
        //self.viewControllers
    }

}
