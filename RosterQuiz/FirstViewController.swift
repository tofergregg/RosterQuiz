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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnFromAddRoster(segue: UIStoryboardSegue) {
        // Here you can receive the parameter(s) from secondVC
        let addRoster : LoadRosterFromGDrive = segue.sourceViewController as! LoadRosterFromGDrive
        rosters.append(addRoster.roster)
        rosterTableView.reloadData()
        // save the rosters
        saveRosters()
    }
    
    func saveRosters(){
        let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("rosters")
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(rosters, toFile: ArchiveURL.path!)
        if (!isSuccessfulSave) {
            print("Could not save rosters!")
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "Show Roster Segue" {
            let destinationVC : ShowRosterController = segue.destinationViewController as! ShowRosterController

            destinationVC.roster = rosters[selectedRow]
            destinationVC.parentController = self
        }

    }
    
}

