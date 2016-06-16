//
//  StudentInfoController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/14/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit

class StudentInfoController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var student : Student! = nil
    
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var studentPicButton: UIButton!
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
            studentPicButton.setTitle("", forState: .Normal)
            if (student.picture != nil) {
                studentPicButton.setImage(student.picture, forState:.Normal)
            }
            else {
                studentPicButton.setImage(UIImage(named: "User-400"), forState:.Normal)
            }
            notesText.text = student.notes
        }
        notesText.layer.borderWidth = 0.5
        notesText.layer.borderColor = UIColor.lightGrayColor().CGColor
        notesText.layer.cornerRadius = 5.0
        lastNameText.addTarget(self, action: #selector(StudentInfoController.nameChanged), forControlEvents: UIControlEvents.EditingChanged)
        firstNameText.addTarget(self, action: #selector(StudentInfoController.nameChanged), forControlEvents: UIControlEvents.EditingChanged)
        imagePicker.delegate = self
        studentPicButton.imageView!.contentMode = .ScaleAspectFit
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
    
    @IBAction func picClicked(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            studentPicButton.setImage(pickedImage, forState: .Normal)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}