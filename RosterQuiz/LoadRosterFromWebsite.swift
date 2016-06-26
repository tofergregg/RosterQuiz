//
//  LoadRosterFromWebsite.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/18/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation

import UIKit

class LoadRosterFromWebsite: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var parentController : AddRosterFromWebsiteController!
    
    var loadingFilesIndicator : UIActivityIndicatorView!
    
    var roster = Roster()
    var images : [String] = []
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var rosterTable: UITableView!
    @IBOutlet weak var clickToAddButton: UIButton!
    var rosterFolder : RosterInfo!
    var rosterCSVFilename = "roster.csv"
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
        navigationItem.title = rosterFolder.name
        clickToAddButton.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        roster.name = rosterFolder.name
        loadImageNames()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImageNames(){
        // load the list of images
        let url: NSURL = NSURL(string: "https://www.eecs.tufts.edu/~cgregg/rosters/cgi-bin/getImageList.cgi")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        let folderName = rosterFolder.name+parentController.sentinel+rosterFolder.filename
        let bodyData = "name=\(parentController.username.text!)&imgFolder=\(folderName)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
        {
            (response, data, error) in
            if data != nil {
                let stringData = String(data: data!, encoding:NSUTF8StringEncoding) as String!
                print(stringData)
                if stringData.hasPrefix("User name and password do not match!") {
                    self.showAlert("Error!", message: stringData)
                }
                else {
                    var rosterInfos = stringData.componentsSeparatedByString("\n")
                    // there will be an extra because of the last line
                    rosterInfos.removeLast()
                    for r in rosterInfos {
                        let parts = r.componentsSeparatedByString(".jpg")
                        if parts.count == 2 {
                            self.images.append(r) // for later
                            let nameParts = parts[0].componentsSeparatedByString("_")
                            let s = Student()
                            s.last_name = nameParts[0]
                            s.first_name = nameParts[1]
                            self.roster.addStudent(s)
                        }
                    }
                    self.rosterTable.reloadData()
                }
                self.loadingFilesIndicator.stopAnimating()
                self.populateImages()
            }
        }
    }
    
    func populateImages() {
        // download the first file
        loadingFilesIndicator.startAnimating()
        imageCount = 0
        loadingErrors = 0
        downloadImages(0)
    }
    
    // load the actual images
    func downloadImages(studentNum : Int){
        if (studentNum < roster.count()) {
            self.studentImage.hidden = false
            let url: NSURL = NSURL(string: "https://www.eecs.tufts.edu/~cgregg/rosters/cgi-bin/retrieveImageByFolder.cgi")!
            let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
            request.HTTPMethod = "POST"
            let folderName = rosterFolder.name+parentController.sentinel+rosterFolder.filename
            let bodyData = "name=\(parentController.username.text!)&imgFolder=\(folderName)&imgName=\(images[studentNum])"
            request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:handleDownload(studentNum))
            
            // download next student after delay
            // cannot have more than 10 requests / second, so we will do 8 for a bit of buffer room
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), Int64(NSEC_PER_SEC) / 8)
            dispatch_after(time, dispatch_get_main_queue()) {
                self.downloadImages(studentNum + 1)
            }
        }
    }
    
    func handleDownload(studentNum:Int) -> (NSURLResponse?, NSData?, NSError?) -> Void {
        return { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            // received image
            print(self.roster[studentNum].commaName())
            if ((error) != nil) {
                self.loadingErrors += 1
            }
            if (data != nil) {
                print(String(data:data!, encoding:NSUTF8StringEncoding))
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
                self.clickToAddButton.enabled = true

                if (self.loadingErrors > 0) {
                    self.showAlert("Errors loading roster",
                                   message: "There were \(self.loadingErrors) errors loading the roster. You may want to try again later.")
                }
                self.loadingFilesIndicator.stopAnimating()
                self.roster.sortStudents()
                self.rosterTable.reloadData()
                // done downloading images, load csv if it exists
                /*
                if ((self.rosterCSVId) != nil) {
                    let url = "https://www.googleapis.com/drive/v3/files/\(self.rosterCSVId!.identifier)?alt=media"
                    let fetcher = GTMSessionFetcher(URLString:url)
                    fetcher.authorizer = self.parentController.service.authorizer
                    fetcher.beginFetchWithCompletionHandler(self.handleCSVDownload)
                }
                else {
                    self.loadingFilesIndicator.stopAnimating()
                    self.studentImage.hidden = true
                }*/
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
        // last,first,year(e.g."Sophomore")
        // year is optional
        let lines = csv.componentsSeparatedByString("\n")
        for line in lines {
            var last : String = "", first: String = ""
            var year : String = ""
            let details = line.componentsSeparatedByString(",")
            if (details.count > 1) {
                last = details[0]
                first = details[1]
                if (details.count > 2){
                    year = details[2]
                }
                print(last+first+year)
                var found = false
                for i in 0 ..< roster.count() {
                    let student = roster[i]
                    if (student.last_name == last && student.first_name == first) {
                        student.year = year
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
                    new_student.notes = ""
                    roster.addStudent(new_student)
                    roster.sortStudents()
                    rosterTable.reloadData()
                }
            }
        }
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

