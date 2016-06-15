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
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (student != nil) {
            navigationItem.title = student.commaName()
            lastNameText.text = student.last_name
            firstNameText.text = student.first_name
            yearText.text = student.year
            genderText.text = student.gender
            studentPic.image = student.picture
            notesText.text = student.notes
        }
        notesText.layer.borderWidth = 0.5
        notesText.layer.borderColor = UIColor.lightGrayColor().CGColor
        notesText.layer.cornerRadius = 5.0
        lastNameText.addTarget(self, action: #selector(StudentInfoController.nameChanged), forControlEvents: UIControlEvents.EditingChanged)
        firstNameText.addTarget(self, action: #selector(StudentInfoController.nameChanged), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func nameChanged(){
        navigationItem.title = lastNameText.text! + ", " + firstNameText.text!
    }
    


}