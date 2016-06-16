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
    
    var roster = Roster()
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var rosterTable: UITableView!
    var rosterFolder : GTLDriveFile!
    var rosterCSVFilename = "roster.csv"
    var rosterCSVId : GTLDriveFile?
    var imageCount = 0
    var loadingErrors = 0
    
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
        roster.name = rosterFolder.name
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
                    rosterCSVId = file
                }
                else if (file.mimeType.containsString("image/")) {
                    let student = Student()
                    
                    // change name to Last,First (okay b/c we will search later by id)
                    // strip out period for extension
                    let fullname = file.name.componentsSeparatedByString(".")[0] // assuming there is an extension
                    let name_parts = fullname.componentsSeparatedByString("_")
                    student.last_name = name_parts[0]
                    student.first_name = name_parts[1]
                
                    print("\(student.last_name), \(student.first_name), id:\(file.identifier)")
                    // add to the array
                    student.google_drive_info = file
                    roster.addStudent(student)
                }
            }
        }
        
        // reload the table and stop the indicator
        rosterTable.reloadData()
        
        // load images
        populateImages()
        
        //output.text = filesString
    }


    // table functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roster.count()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("student cell", forIndexPath: indexPath)
        let row = indexPath.row
        if (roster[row].picture != nil) {
            cell.imageView!.image = roster[row].picture
        }
        else {
            cell.imageView!.image = UIImage(named:"User-100")
        }
        cell.textLabel?.text = roster[indexPath.row].commaName()
        return cell
    }
    
    func populateImages() {
        // download the first file
        loadingFilesIndicator.startAnimating()
        imageCount = 0
        loadingErrors = 0
        downloadImages(0)
    }

    
    func downloadImages(studentNum : Int){
        if (studentNum < roster.count()) {
            self.studentImage.hidden = false
            let url = "https://www.googleapis.com/drive/v3/files/\(roster[studentNum].google_drive_info!.identifier)?alt=media"
            let fetcher = GTMSessionFetcher(URLString:url)
            fetcher.authorizer = parentController.service.authorizer
            fetcher.beginFetchWithCompletionHandler(handleDownload(studentNum))
            // download next student after delay
            
            // cannot have more than 10 requests / second, so we will do 8 for a bit of buffer room
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(NSEC_PER_SEC) / 8)
            dispatch_after(time, dispatch_get_main_queue()) {
                self.downloadImages(studentNum + 1)
            }
        }
        else {

        }
    }
    
    func handleDownload(studentNum:Int) -> (NSData?, NSError?) -> Void {
        return { (data: NSData?, error: NSError?) -> Void in
            // received image
            print(self.roster[studentNum].commaName())
            if ((error) != nil) {
                self.loadingErrors += 1
            }
            if (data != nil) {
                print(data!.length)
                self.roster[studentNum].picture = UIImage(data:data!,scale:1.0)
                self.studentImage.image = self.roster[studentNum].picture
                self.studentImage.setNeedsDisplay()
                self.rosterTable.reloadData()
                // race condition possible here...
            }
            self.imageCount += 1
            if (self.imageCount == self.roster.count()) { // received all images, update with csv data
                self.studentImage.hidden = true
                if (self.loadingErrors > 0) {
                    self.showAlert("Errors loading roster",
                              message: "There were \(self.loadingErrors) errors loading the roster. You may want to try again later.")
                }
                // done downloading images, load csv if it exists
                if ((self.rosterCSVId) != nil) {
                    let url = "https://www.googleapis.com/drive/v3/files/\(self.rosterCSVId!.identifier)?alt=media"
                    let fetcher = GTMSessionFetcher(URLString:url)
                    fetcher.authorizer = self.parentController.service.authorizer
                    fetcher.beginFetchWithCompletionHandler(self.handleCSVDownload)
                }
                else {
                    self.loadingFilesIndicator.stopAnimating()
                    self.studentImage.hidden = true
                }
            }
        }
    }
    
    func handleCSVDownload(data: NSData?, error: NSError?) -> Void {
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
            // received csv file
            let csv = String(data: data!, encoding:NSUTF8StringEncoding)!
            self.loadingFilesIndicator.stopAnimating()

            print(csv)
            addToRoster(csv)
        
    }
    
    func addToRoster(csv : String){
        // csv should have the following form:
        // last,first,year(e.g."Sophomore"),gender(e.g."M")
        // year and gender are optional
        let lines = csv.componentsSeparatedByString("\n")
        for line in lines {
            var last : String = "", first: String = ""
            var year : String = "", gender : String = ""
            let details = line.componentsSeparatedByString(",")
            if (details.count > 1) {
                last = details[0]
                first = details[1]
                if (details.count > 2){
                    year = details[2]
                }
                if (details.count > 3) {
                    gender = details[3]
                }
                print(last+first+year+gender)
                var found = false
                for i in 0 ..< roster.count() {
                    let student = roster[i]
                    if (student.last_name == last && student.first_name == first) {
                        student.year = year
                        student.gender = gender
                        student.notes = ""
                        found = true
                        break
                    }
                }
                if (!found){
                    // put the student in the roster without a picture
                    let new_student = Student()
                    new_student.google_drive_info = nil
                    new_student.last_name = last
                    new_student.first_name = first
                    new_student.year = year
                    new_student.gender = gender
                    new_student.notes = ""
                    roster.addStudent(new_student)
                    rosterTable.reloadData()
                }
            }
        }
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
        )
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
        loadingFilesIndicator.stopAnimating()
    }
}

