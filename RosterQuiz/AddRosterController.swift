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

class AddRosterController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var loadingFilesIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var rosterListTable: UITableView!
    private let kKeychainItemName = "Drive API"
    private let kClientID = "795309004462-itm898hfu3gna8rnb1mjlv2jmaj8d6jd.apps.googleusercontent.com"
    private let folderName = "RosterQuiz_Rosters"
    var rosterList : [String] = []
    let textCellIdentifier = "First Cell"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDriveReadonly]
    //private let scopes = [kGTLAuthScopeDriveMetadataReadonly]
    
    
    private let service = GTLServiceDrive()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        /*
        rosterText.layer.borderWidth = 0.5
        rosterText.layer.borderColor = UIColor.grayColor().CGColor
        rosterText.layer.cornerRadius = 5.0
        rosterText.text = ""
        */
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        rosterListTable.delegate = self;
        rosterListTable.dataSource = self;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loadRosterList(sender: UIButton) {
        // Construct a query to get names and IDs of 10 files using the Google Drive API
        loadingFilesIndicator.startAnimating()
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 1000 // max number in roster
        //query.fields = "nextPageToken, files(id, name)"
        //query.spaces = "drive"
        query.q = "name = '\(folderName)'"
        //query.q = "'0BxrnKK8LdJT0VGxVQXNiclhtWEU' in parents"
        //query.q = "'0BxrnKK8LdJT0QzJuTkhTb2hZNE0' in parents"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(AddRosterController.findFolderFromTicket(_:finishedWithObject:error:))
        )
    }
    
    // Parse results and display
    func findFolderFromTicket(ticket : GTLServiceTicket,
                                 finishedWithObject response : GTLDriveFileList,
                                                    error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        if let files = response.files where !files.isEmpty {
            for file in files as! [GTLDriveFile] {
                print("\(file.name) (\(file.identifier))")
                rosterList.append(file.name)
            }
            rosterListTable.reloadData()
        } else {
            showAlert("Error", message: "Could not find \(folderName) folder on your Google Drive!")
        }
        
        //output.text = filesString
    }
    
    
    // Creates the auth controller for authorizing access to Drive API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: nil,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: #selector(AddRosterController.viewController(_:finishedWithAuth:error:))
        )
    }
    
    // Handle completion of the authorization process, and update the Drive API
    // with the new credentials.
    func viewController(vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismissViewControllerAnimated(true, completion: nil)
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
    
    @IBAction func cancelButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    // table functions
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rosterList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = rosterList[row]
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Row: \(row)")
        
        //rosterList[row].printRoster()
        
    }
}

