//
//  StudentInfoController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/14/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    public override func shouldAutorotate() -> Bool {
        if (visibleViewController != nil) {
            return visibleViewController!.shouldAutorotate()
        }
        else {
            return true;
        }
    }
}

class StudentInfoController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var student : Student! = nil
    
    let imagePicker = UIImagePickerController()
    
    var newStudent = false
    
    var parentController : ShowRosterController?
    
    @IBOutlet weak var studentPicButton: UIButton!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var viewLoaded = false
    var noBackAlert = false

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
        
        // force portrait mode
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        /* Did not work. See here: http://stackoverflow.com/a/2796488/561677
        // change back button
        let btn = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(StudentInfoController.backBtnClicked))
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem=btn
        */
        let button  = UIButton(type: .Custom)
        if let image = UIImage(named:"backButtonImage.png") {
            button.setImage(image, forState: .Normal)
        }
        // trying to get the button as close as possible
        button.frame = CGRectMake(0.0, 0.0, 56.0, 28.0)
        button.addTarget(self, action: #selector(backBtnClicked), forControlEvents: .TouchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButton
        viewLoaded = true;
    }
    
    
    
    func backBtnClicked() {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        print("Going back, checking for differences.");
        // check for differences
        if student.last_name != lastNameText.text ||
            student.first_name != firstNameText.text ||
            student.picture != studentPicButton.currentImage ||
            student.notes != notesText.text ||
            student.year != yearText.text {
            saveAlert("Information has Changed", message: "Do you want to save?")
        }
        else {
            self.navigationController!.popViewControllerAnimated(true);
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        /* update: did end up creating my own button above */
        /* decided against this. There is a save button for a reason.
           If someone changes an image, it's changed forever, and there isn't
           an undo button
        // save
        student.last_name = lastNameText.text!
        student.first_name = firstNameText.text!
        student.picture = studentPicButton.currentImage
        student.notes = notesText.text!
        student.year = yearText.text!
        parentController!.roster.sortStudents()
        parentController!.parentController.saveRosters()
         */
        super.viewWillDisappear(animated)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        return
        if viewLoaded && !noBackAlert {
            print("Back button pressed");
            saveAlert("Save Changes?", message: "Do you want to save the changes?")
        }
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
    
    // don't allow landscape mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait

    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    override func shouldAutorotate() -> Bool {
        switch UIDevice.currentDevice().orientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return true
        default:
            return false
        }
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
    
    // Helper for showing an alert
    func saveAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let yes = UIAlertAction(
            title: "YES",
            style: UIAlertActionStyle.Default,
            handler: yesSelected
        )
        let no = UIAlertAction(
            title: "NO",
            style: UIAlertActionStyle.Destructive,
            handler: noSelected
        )
        let cancel = UIAlertAction(
            title: "CANCEL",
            style: UIAlertActionStyle.Cancel,
            handler: nil // don't go back
        )
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    func noSelected(action: UIAlertAction){
        self.navigationController!.popViewControllerAnimated(true);
    }
    
    func yesSelected(action: UIAlertAction){
        self.performSegueWithIdentifier("Save on Return",sender:self)
    }

}