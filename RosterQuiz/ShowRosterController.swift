//
//  ShowRoster.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/6/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit

class ShowRosterController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    @IBOutlet weak var rosterTitle: UINavigationItem!
    
    @IBOutlet weak var studentsTableView: UITableView!
    
    @IBOutlet weak var newStudentButton: UIButton!
    var roster : Roster!
    var parentController : FirstViewController!
    let textCellIdentifier = "StudentCell"
    var rosterNameTextField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTitle.title = roster.name
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Helvetica", size: 15)!]
        //navigationController?.delegate = self
        self.studentsTableView.allowsMultipleSelectionDuringEditing = false
        
        // set up rename button
        let renameButton = UIBarButtonItem(title: "Rename", style: UIBarButtonItemStyle.plain, target: self, action: #selector(renameRoster))
        navigationItem.setRightBarButton(renameButton, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renameRoster(){
        print("renaming roster")
        let alert = UIAlertController(title: "Rename Roster", message: "Please enter the new roster name.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Rename", style: UIAlertActionStyle.default, handler: newNameChosen))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Roster name"
            self.rosterNameTextField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func newNameChosen(_ action: UIAlertAction) {
        roster.name = rosterNameTextField!.text!
        rosterTitle.title = roster.name
        parentController.saveRosters()
        parentController.rosterTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roster.students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = (indexPath as NSIndexPath).row
        if (roster.students[row].picture != nil) {
            cell.imageView!.image = roster.students[row].picture
        }
        else {
            cell.imageView!.image = UIImage(named:"User-100")
        }
        cell.textLabel?.text = roster.students[row].commaName();
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        /*
        let row = indexPath.row
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("Show Roster Controller") as! ShowRosterController
        navigationController?.pushViewController(destination, animated: true)
        performSegueWithIdentifier("Show Roster Segue", sender: self)*/
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath : IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            roster.students.remove(at: (indexPath as NSIndexPath).row)
            parentController.saveRosters()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "Loading Student Info" || segue.identifier == "New Student Segue") {
            let destinationVC : StudentInfoController = segue.destination as! StudentInfoController
            
            destinationVC.parentController = self
            
            if segue.identifier == "Loading Student Info" {
                destinationVC.student = roster[((studentsTableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
                destinationVC.newStudent = false
            }
            else if segue.identifier == "New Student Segue" {
                destinationVC.student = Student()
                destinationVC.student.last_name = "Last Name"
                destinationVC.student.first_name = "First Name"
                destinationVC.student.picture = UIImage(named: "User-400")
                destinationVC.newStudent = true
            }
        }
        else if segue.identifier == "Quiz Segue" {
            let destinationVC : QuizTabBarController = segue.destination as! QuizTabBarController
            destinationVC.roster = roster
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if (viewController == self) {
            if (studentsTableView.indexPathForSelectedRow != nil) {
                let student = roster[((studentsTableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
                student.printStudent()
            }
        }
    }
    
    @IBAction func returnFromStudentInfo(_ segue: UIStoryboardSegue) {
        // Here you can receive the parameter(s) from secondVC
        let studentInfoView : StudentInfoController = segue.source as! StudentInfoController
        var student : Student
        
        if studentInfoView.newStudent {
            student = Student()
            roster.addStudent(student)
        }
        else {
            student = roster[((studentsTableView.indexPathForSelectedRow as NSIndexPath?)?.row)!]
        }
        student.last_name = studentInfoView.lastNameText.text!
        student.first_name = studentInfoView.firstNameText.text!
        student.year = studentInfoView.yearText.text!
        student.notes = studentInfoView.notesText.text!
        student.picture = studentInfoView.studentPicButton.currentImage
        roster.sortStudents() // in case name change would re-sort
        parentController.saveRosters() // save officially
        studentsTableView.reloadData()
        // will go back to StudentInfoController to willMoveToParentViewController
        // so we want to stop that from popping an alert (this seems like a kludge...)
        studentInfoView.noBackAlert = true;
    }
}
