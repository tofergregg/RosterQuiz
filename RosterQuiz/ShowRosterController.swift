//
//  ShowRoster.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/6/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit

class ShowRosterController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var rosterName: UILabel!
    @IBOutlet weak var studentsTableView: UITableView!
    
    var roster : Roster!
    let textCellIdentifier = "StudentCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterName.text = roster.name
        studentsTableView.delegate = self
        studentsTableView.dataSource = self

        // Do any additional setup after loading the view, typically from a nib.
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
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        /*
        let row = indexPath.row
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let destination = storyboard.instantiateViewControllerWithIdentifier("Show Roster Controller") as! ShowRosterController
        navigationController?.pushViewController(destination, animated: true)
        performSegueWithIdentifier("Show Roster Segue", sender: self)*/
        
    }
    
}
