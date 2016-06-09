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
    private var folderId = ""
    var rosterList : [GTLDriveFile] = []
    let textCellIdentifier = "First Cell"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDriveReadonly]
    //private let scopes = [kGTLAuthScopeDriveMetadataReadonly]
    
    
    let service = GTLServiceDrive()

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
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loadRosterList(sender: UIButton) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            startQuery()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    func startQuery(){
        // Construct a query to get names and IDs of 10 files using the Google Drive API
        loadingFilesIndicator.startAnimating()
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 1000 // max number in roster
        //query.fields = "nextPageToken, files(id, name)"
        query.spaces = "drive"
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
            if (files.count != 1) {
                showAlert("Error", message:"It seems that you have more than one folder named \(folderName)")
            }
            else {
                let file = files[0] as! GTLDriveFile
                print("\(file.name) (\(file.identifier))")
                //rosterList.append(file.name)
                folderId = file.identifier
                
                // find all files
                let query = GTLQueryDrive.queryForFilesList()
                query.pageSize = 1000 // max number in roster
                //query.fields = "nextPageToken, files(id, name)"
                //query.spaces = "drive"
                query.q = "'\(folderId)' in parents"
                service.executeQuery(
                    query,
                    delegate: self,
                    didFinishSelector: #selector(AddRosterController.findFilesFromTicket(_:finishedWithObject:error:))
                )
            }
        } else {
            showAlert("Error", message: "Could not find \(folderName) folder on your Google Drive!")
        }
        
        //output.text = filesString
    }
    
    // Parse results and display
    func findFilesFromTicket(ticket : GTLServiceTicket,
                              finishedWithObject response : GTLDriveFileList,
                                                 error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        if let files = response.files where !files.isEmpty {
            rosterList.removeAll()
            for file in files as! [GTLDriveFile] {
                print("\(file.name) (\(file.identifier))\n")
                rosterList.append(file)
            }
            rosterListTable.reloadData()
            loadingFilesIndicator.stopAnimating()
            
        } else {
            showAlert("Error", message: "Could not find any of the roster files on your Google Drive!")
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
        startQuery()
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
        cell.textLabel?.text = rosterList[row].name
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "Show Students" {
            let destionationVC : LoadRosterFromGDrive = segue.destinationViewController as! LoadRosterFromGDrive
            
            destionationVC.parentController = self
            destionationVC.rosterFolder = rosterList[rosterListTable.indexPathForSelectedRow!.row]
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //let row = indexPath.row
        //print("Row: \(row)")
    }
    
    func loadRosterFromGDrive(rosterFolder:GTLDriveFile){
        // load the roster into new table.
        
    }
}

