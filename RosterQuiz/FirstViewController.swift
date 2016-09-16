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
    
    override func viewDidAppear(_ animated: Bool) {
        if makingNewRoster {
            makingNewRoster = false; // reset
            // ask for Roster name
            let alert = UIAlertController(title: "Add Blank Roster", message: "Please name the roster.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: addNewRoster))
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
                textField.placeholder = "Roster name"
                self.rosterNameTextField = textField
            })
            self.present(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Dispose of any resources that can be recreated.
    }
    
    func addNewRoster(_ action : UIAlertAction) {
        print("Creating new roster named '" + (rosterNameTextField?.text)! + "'")
        let roster = Roster(n: (rosterNameTextField?.text)!)
        rosters.append(roster)
        rosterTableView.reloadData()
        saveRosters()
    }
    
    @IBAction func returnFromAddRoster(_ segue: UIStoryboardSegue) {
        // Here you can receive the parameter(s) from secondVC
        if let addRoster : LoadRosterFromGDrive = segue.source as? LoadRosterFromGDrive {
            rosters.append(addRoster.roster)
        }
        else if let addRoster : LoadRosterFromWebsite = segue.source as? LoadRosterFromWebsite {
            rosters.append(addRoster.roster)
        }
        rosterTableView.reloadData()
        // save the rosters
        saveRosters()
    }
    
    @IBAction func returnAndMakeBlankRoster(_ segue: UIStoryboardSegue) {
        // can't do much here because we want an alert, which must
        // happen after the view is loaded
        makingNewRoster = true;
    }
    
    func saveRosters(){
        // save in the background so we don't stop the app
        // (will this potentially cause a problem if the user stops the app in the middle
        // of a save? probably.)
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
            let ArchiveURL = DocumentsDirectory.appendingPathComponent("rosters")
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.rosters, toFile: ArchiveURL.path)
            DispatchQueue.main.async {
                // UI updates must be on main thread
                if (!isSuccessfulSave) {
                    print("Could not save rosters!")
                }
            }
        }
    }
    
    func loadRosters() -> [Roster]? {
        let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
        let ArchiveURL = DocumentsDirectory.appendingPathComponent("rosters")
        return NSKeyedUnarchiver.unarchiveObject(withFile: ArchiveURL.path) as? [Roster]
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rosters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = rosters[row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let row = (indexPath as NSIndexPath).row
            print("Row: \(row)")
            
            rosters[row].printRoster()
            
            selectedRow = row

            performSegue(withIdentifier: "Show Roster Segue", sender: self)
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
            rosters.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveRosters()
        }
        else {
            print("not deleting")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "Show Roster Segue" {
            let destinationVC : ShowRosterController = segue.destination as! ShowRosterController

            destinationVC.roster = rosters[selectedRow]
            destinationVC.parentController = self
        }

    }
    
}

