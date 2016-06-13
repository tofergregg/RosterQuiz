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

struct StudentData {
    var google_drive_info : GTLDriveFile?
    var last_name : String
    var first_name : String
    var img : UIImage?
    
    func underscore_name() -> String {
        return last_name + "_" + first_name
    }
    
    func comma_name() -> String {
        return last_name + ", " + first_name
    }
}

class LoadRosterFromGDrive: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var parentController : AddRosterController!
    
    var loadingFilesIndicator : UIActivityIndicatorView!
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var rosterTable: UITableView!
    var rosterFolder : GTLDriveFile!
    var allStudents : [StudentData] = []
    var rosterCSVFilename = "roster.csv"
    var rosterCSVId : GTLDriveFile!
    var imageCount = 0
    
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
                    rosterCSVId = file
                }
                else if (file.mimeType.containsString("image/")) {
                    var student = StudentData(google_drive_info : nil, last_name : "",first_name : "",  img : nil)

                    // change name to Last,First (okay b/c we will search later by id)
                    // strip out period for extension
                    let fullname = file.name.componentsSeparatedByString(".")[0] // assuming there is an extension
                    let name_parts = fullname.componentsSeparatedByString("_")
                    student.last_name = name_parts[0]
                    student.first_name = name_parts[1]
                
                    print("\(student.last_name), \(student.first_name), id:\(file.identifier)")
                    // add to the array
                    student.google_drive_info = file
                    allStudents.append(student)

                }
            }
        }
        // sort the array by name
        allStudents.sortInPlace({$0.last_name < $1.last_name})
        
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
        return allStudents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("student cell", forIndexPath: indexPath)
        let row = indexPath.row
        if (allStudents[row].img != nil) {
            cell.imageView!.image = allStudents[row].img
        }
        else {
            cell.imageView!.image = UIImage(named:"User-100")
        }
        cell.textLabel?.text = allStudents[indexPath.row].comma_name()
        return cell
    }
    @IBAction func downloadRoster(sender: UIButton) {
        // download the first file
        
    }
    
    func populateImages() {
        // download the first file
        loadingFilesIndicator.startAnimating()
        downloadImages(0)
    }

    
    func downloadImages(studentNum : Int){
        if (studentNum < allStudents.count) {
            self.studentImage.hidden = false
            let url = "https://www.googleapis.com/drive/v3/files/\(allStudents[studentNum].google_drive_info!.identifier)?alt=media"
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
            // done downloading images, load csv if it exists
            if ((rosterCSVId) != nil) {
                let url = "https://www.googleapis.com/drive/v3/files/\(rosterCSVId.identifier)?alt=media"
                let fetcher = GTMSessionFetcher(URLString:url)
                fetcher.authorizer = parentController.service.authorizer
                fetcher.beginFetchWithCompletionHandler(handleCSVDownload)
            }
            else {
                loadingFilesIndicator.stopAnimating()
                self.studentImage.hidden = true
            }
        }
    }
    
    func handleDownload(studentNum:Int) -> (NSData?, NSError?) -> Void {
        return { (data: NSData?, error: NSError?) -> Void in
            // received image
            print(self.allStudents[studentNum].comma_name())
            print(data!.length)
            self.allStudents[studentNum].img = UIImage(data:data!,scale:1.0)
            self.studentImage.image = self.allStudents[studentNum].img
            self.studentImage.setNeedsDisplay()
            self.rosterTable.reloadData()
        }
    }
    
    func handleCSVDownload(data: NSData?, error: NSError?) -> Void {
            // received csv file
            let csv = String(data: data!, encoding:NSUTF8StringEncoding)
            print(csv)
            loadingFilesIndicator.stopAnimating()
            self.studentImage.hidden = true

    }
}

