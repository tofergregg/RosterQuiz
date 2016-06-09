//
//  LoadRosterFromGDrive.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/9/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
//
//  SecondViewController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit
import GoogleAPIClient
import GTMOAuth2

class LoadRosterFromGDrive: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var parentController : AddRosterController!
    
    var loadingFilesIndicator : UIActivityIndicatorView!
    
    @IBOutlet weak var rosterTable: UITableView!
    var rosterFolder : GTLDriveFile!
    var allStudents : [GTLDriveFile] = []
    var rosterCSVFilename = "roster.csv"
    var rosterFile : GTLDriveFile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTable.delegate = self
        rosterTable.dataSource = self
        loadingFilesIndicator = UIActivityIndicatorView()
        //uiBusy.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        loadingFilesIndicator.color = UIColor.blackColor()
        loadingFilesIndicator.hidesWhenStopped = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingFilesIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        startQuery()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startQuery(){
        // Construct a query to get names and IDs of 10 files using the Google Drive API
        loadingFilesIndicator.startAnimating()
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 1000 // max number in roster
        //query.fields = "nextPageToken, files(id, name)"
        query.spaces = "drive"
        query.q = "'\(rosterFolder.identifier)' in parents and trashed = false"
        //query.q = "'0BxrnKK8LdJT0QzJuTkhTb2hZNE0' in parents"
        parentController.service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(LoadRosterFromGDrive.findFolderFromTicket(_:finishedWithObject:error:))
        )
    }
    
    // Parse results and display
    func findFolderFromTicket(ticket : GTLServiceTicket,
                              finishedWithObject response : GTLDriveFileList,
                                                 error : NSError?) {
        
        if let error = error {
            parentController.showAlert("Error", message: error.localizedDescription)
            return
        }
        
        if let files = response.files where !files.isEmpty {
            for file in files as! [GTLDriveFile] {
                // check if the file is the csv file
                if (file.name == rosterCSVFilename) {
                    rosterFile = file
                }
                else if (file.mimeType == "image/jpeg") {
                    // change name to Last,First (okay b/c we will search later by id)
                    // strip out period for extension
                    let fullname = file.name.componentsSeparatedByString(".")[0] // assuming there is an extension
                    file.name = fullname.stringByReplacingOccurrencesOfString("_", withString: ",")
                    
                    // add to the array
                    allStudents.append(file)

                }
                
            }
        }
        // sort the array by name
        allStudents.sortInPlace({$0.name < $1.name})
        
        // reload the table and stop the indicator
        rosterTable.reloadData()
        loadingFilesIndicator.stopAnimating()
        
        //output.text = filesString
    }


    // table functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStudents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("student cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = allStudents[indexPath.row].name
        return cell
    }
}

