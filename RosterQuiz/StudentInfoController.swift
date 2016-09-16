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
    open override var shouldAutorotate : Bool {
        if (visibleViewController != nil) {
            return visibleViewController!.shouldAutorotate
        }
        else {
            return true;
        }
    }
}

class StudentInfoController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    var student : Student! = nil
    
    var newStudent = false
    
    var parentController : ShowRosterController?
    
    @IBOutlet weak var studentPicButton: UIButton!
    @IBOutlet weak var notesText: UITextView!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var viewIsLoaded = false
    var noBackAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if (student != nil) {
            navigationItem.title = student.commaName()
            lastNameText.text = student.last_name
            firstNameText.text = student.first_name
            yearText.text = student.year
            studentPicButton.setTitle("", for: UIControlState())
            if (student.picture != nil) {
                studentPicButton.setImage(student.picture, for:UIControlState())
            }
            else {
                studentPicButton.setImage(UIImage(named: "User-400"), for:UIControlState())
            }
            notesText.text = student.notes
        }
        notesText.layer.borderWidth = 0.5
        notesText.layer.borderColor = UIColor.lightGray.cgColor
        notesText.layer.cornerRadius = 5.0
        lastNameText.addTarget(self, action: #selector(StudentInfoController.nameChanged), for: UIControlEvents.editingChanged)
        firstNameText.addTarget(self, action: #selector(StudentInfoController.nameChanged), for: UIControlEvents.editingChanged)
        studentPicButton.imageView!.contentMode = .scaleAspectFit
        
        // force portrait mode
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        /* Did not work. See here: http://stackoverflow.com/a/2796488/561677
        // change back button
        let btn = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(StudentInfoController.backBtnClicked))
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem=btn
        */
        let button  = UIButton(type: .custom)
        if let image = UIImage(named:"backButtonImage.png") {
            button.setImage(image, for: UIControlState())
        }
        // trying to get the button as close as possible
        button.frame = CGRect(x: 0.0, y: 0.0, width: 56.0, height: 28.0)
        button.addTarget(self, action: #selector(backBtnClicked), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)

        // the button is too far to the right, so add some negative space...
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -10;
        navigationItem.setLeftBarButtonItems([negativeSpacer,barButton], animated: false)
        viewIsLoaded = true;
        //navigationItem.backBarButtonItem = barButton
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
            self.navigationController!.popViewController(animated: true);
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    override func willMove(toParentViewController parent: UIViewController?) {
        /* not necessary
        if viewIsLoaded && !noBackAlert {
            print("Back button pressed");
            saveAlert("Save Changes?", message: "Do you want to save the changes?")
        }
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ sender : UITextField)
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
    
    func textFieldDidEndEditing(_ sender : UITextField)
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
    
    func textViewDidBeginEditing(_ sender : UITextView) {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            self.setViewMovedUp(true, kOFFSET_FOR_KEYBOARD: 80.0)
            
            // add done button
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(StudentInfoController.newDismiss))
        }
    }
    
    func newDismiss() {
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
    func setViewMovedUp(_ movedUp : Bool, kOFFSET_FOR_KEYBOARD : CGFloat) {
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
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait

    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    override var shouldAutorotate : Bool {
        switch UIDevice.current.orientation {
        case .portrait, .portraitUpsideDown, .unknown:
            return true
        default:
            return false
        }
    }
    
    func nameChanged(){
        navigationItem.title = lastNameText.text! + ", " + firstNameText.text!
    }
    
    @IBAction func picClicked(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            picker.sourceType = .camera
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            picker.allowsEditing = true
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /*@IBAction func picClicked(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }*/
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            studentPicButton.setImage(pickedImage, for: UIControlState())
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Helper for showing an alert
    func saveAlert(_ title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let yes = UIAlertAction(
            title: "YES",
            style: UIAlertActionStyle.default,
            handler: yesSelected
        )
        let no = UIAlertAction(
            title: "NO",
            style: UIAlertActionStyle.destructive,
            handler: noSelected
        )
        let cancel = UIAlertAction(
            title: "CANCEL",
            style: UIAlertActionStyle.cancel,
            handler: nil // don't go back
        )
        alert.addAction(yes)
        alert.addAction(no)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    func noSelected(_ action: UIAlertAction){
        self.navigationController!.popViewController(animated: true);
    }
    
    func yesSelected(_ action: UIAlertAction){
        self.performSegue(withIdentifier: "Save on Return",sender:self)
    }

}
