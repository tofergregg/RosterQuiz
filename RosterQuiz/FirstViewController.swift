//
//  FirstViewController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var rosterTableView: UITableView!
    @IBOutlet weak var addRosterButton: UIBarButtonItem!
    var rosters : [Roster] = []
    let textCellIdentifier = "TextCell"
    var selectedRow : Int = 0
    var makingNewRoster = false
    var rosterNameTextField : UITextField? // used when creating blank roster
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTableView.delegate = self
        rosterTableView.dataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        let possibleRosters = loadRosters()
        if (possibleRosters != nil) {
            rosters = possibleRosters!
        }
        rosterTableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        if makingNewRoster {
            makingNewRoster = false; // reset
            // ask for Roster name
            let alert = UIAlertController(title: "Add Blank Roster", message: "Please name the roster.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: addNewRoster))
            alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
                textField.placeholder = "Roster name"
                self.rosterNameTextField = textField
            })
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    func addNewRoster(action : UIAlertAction) {
        print("Creating new roster named '" + (rosterNameTextField?.text)! + "'")
        let roster = Roster(n: (rosterNameTextField?.text)!)
        rosters.append(roster)
        rosterTableView.reloadData()
        saveRosters()
    }
    
    @IBAction func returnFromAddRoster(segue: UIStoryboardSegue) {
        // Here you can receive the parameter(s) from secondVC
        if let addRoster : LoadRosterFromGDrive = segue.sourceViewController as? LoadRosterFromGDrive {
            rosters.append(addRoster.roster)
        }
        else if let addRoster : LoadRosterFromWebsite = segue.sourceViewController as? LoadRosterFromWebsite {
            rosters.append(addRoster.roster)
        }
        rosterTableView.reloadData()
        // save the rosters
        saveRosters()
    }
    
    @IBAction func returnAndMakeBlankRoster(segue: UIStoryboardSegue) {
        // can't do much here because we want an alert, which must
        // happen after the view is loaded
        makingNewRoster = true;
    }
    
    func saveRosters(){
        // save in the background so we don't stop the app
        // (will this potentially cause a problem if the user stops the app in the middle
        // of a save? probably.)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
            let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("rosters")
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.rosters, toFile: ArchiveURL.path!)
            
            dispatch_async(dispatch_get_main_queue()) {
                // UI updates must be on main thread
                if (!isSuccessfulSave) {
                    print("Could not save rosters!")
                }
            }
        }
    }
    
    func loadRosters() -> [Roster]? {
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("rosters")
        return NSKeyedUnarchiver.unarchiveObjectWithFile(ArchiveURL.path!) as? [Roster]
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rosters.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = rosters[row].name
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let row = indexPath.row
            print("Row: \(row)")
            
            rosters[row].printRoster()
            
            selectedRow = row

            performSegueWithIdentifier("Show Roster Segue", sender: self)
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
            rosters.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            saveRosters()
        }
        else {
            print("not deleting")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "Show Roster Segue" {
            let destinationVC : ShowRosterController = segue.destinationViewController as! ShowRosterController

            destinationVC.roster = rosters[selectedRow]
            destinationVC.parentController = self
        }

    }
    
}

