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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTitle.title = roster.name
        studentsTableView.delegate = self
        studentsTableView.dataSource = self
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Helvetica", size: 15)!]
        //navigationController?.delegate = self
        self.studentsTableView.allowsMultipleSelectionDuringEditing = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roster.students.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        if (roster.students[row].picture != nil) {
            cell.imageView!.image = roster.students[row].picture
        }
        else {
            cell.imageView!.image = UIImage(named:"User-100")
        }
        cell.textLabel?.text = roster.students[row].commaName();
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        /*
        let row = indexPath.row
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("Show Roster Controller") as! ShowRosterController
        navigationController?.pushViewController(destination, animated: true)
        performSegueWithIdentifier("Show Roster Segue", sender: self)*/
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath : NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            roster.students.removeAtIndex(indexPath.row)
            parentController.saveRosters()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "Loading Student Info" || segue.identifier == "New Student Segue") {
            let destinationVC : StudentInfoController = segue.destinationViewController as! StudentInfoController
            
            if segue.identifier == "Loading Student Info" {
                destinationVC.student = roster[(studentsTableView.indexPathForSelectedRow?.row)!]
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
            let destinationVC : QuizTabBarController = segue.destinationViewController as! QuizTabBarController
            destinationVC.roster = roster
        }
    }
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if (viewController == self) {
            if (studentsTableView.indexPathForSelectedRow != nil) {
                let student = roster[(studentsTableView.indexPathForSelectedRow?.row)!]
                student.printStudent()
            }
        }
    }
    
    @IBAction func returnFromStudentInfo(segue: UIStoryboardSegue) {
        // Here you can receive the parameter(s) from secondVC
        let studentInfoView : StudentInfoController = segue.sourceViewController as! StudentInfoController
        if studentInfoView.newStudent {
            roster.addStudent(studentInfoView.student)
            roster.sortStudents()
        }
        else {
        let student = roster[(studentsTableView.indexPathForSelectedRow?.row)!]
            student.last_name = studentInfoView.lastNameText.text!
            student.first_name = studentInfoView.firstNameText.text!
            student.year = studentInfoView.yearText.text!
            student.notes = studentInfoView.notesText.text!
            student.picture = studentInfoView.studentPicButton.currentImage
        }
        roster.sortStudents() // in case name change would re-sort
        parentController.saveRosters() // save officially
        studentsTableView.reloadData()
    }
}
