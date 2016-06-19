//
//  StudentInfoController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/14/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit

class StudentInfoController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var student : Student! = nil
    
    let imagePicker = UIImagePickerController()
    
    var newStudent = false
    
    @IBOutlet weak var studentPicButton: UIButton!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if (student != nil) {
            navigationItem.title = student.commaName()
            lastNameText.text = student.last_name
            firstNameText.text = student.first_name
            yearText.text = student.year
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(sender : UITextField)
    {
        var offset : CGFloat = 0
        if sender == lastNameText {
            offset = 100.0
        }
        else if sender == firstNameText {
            offset = 140.0
        }
        else if sender == yearText {
            offset = 180.0
        }
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            self.setViewMovedUp(true,kOFFSET_FOR_KEYBOARD: offset);
        }
    }
    
    func textFieldDidEndEditing(sender : UITextField)
    {
        var offset : CGFloat = 0
        if sender == lastNameText {
            offset = 100.0
        }
        else if sender == firstNameText {
            offset = 140.0
        }
        else if sender == yearText {
            offset = 180.0
        }
        
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y < 0)
        {
            self.setViewMovedUp(false,kOFFSET_FOR_KEYBOARD: offset);
        }
    }
    
    func textViewDidBeginEditing(sender : UITextView) {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            self.setViewMovedUp(true, kOFFSET_FOR_KEYBOARD: 80.0)
            
            // add done button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(StudentInfoController.dismiss))
        }
    }
    
    func dismiss() {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y < 0)
        {
            self.setViewMovedUp(false, kOFFSET_FOR_KEYBOARD: 80.0)
        }
        notesText.resignFirstResponder()
        // remove done button
        self.navigationItem.rightBarButtonItem = nil
    }
    
    //method to move the view up/down whenever the keyboard is shown/dismissed
    func setViewMovedUp(movedUp : Bool, kOFFSET_FOR_KEYBOARD : CGFloat) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
    
        var rect = self.view.frame;
        if (movedUp)
        {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
            rect.origin.y -= kOFFSET_FOR_KEYBOARD;
            //rect.size.height += kOFFSET_FOR_KEYBOARD;
        }
        else
        {
            // revert back to the normal state.
            rect.origin.y += kOFFSET_FOR_KEYBOARD;
            //rect.size.height -= kOFFSET_FOR_KEYBOARD;
        }
        self.view.frame = rect;
        
        UIView.commitAnimations();
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