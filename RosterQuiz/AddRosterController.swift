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
    fileprivate let kKeychainItemName = "Drive API"
    fileprivate let kClientID = "795309004462-itm898hfu3gna8rnb1mjlv2jmaj8d6jd.apps.googleusercontent.com"
    fileprivate let folderName = "RosterQuiz_Rosters"
    fileprivate var folderId = ""
    var rosterList : [GTLDriveFile] = []
    let textCellIdentifier = "First Cell"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    fileprivate let scopes = [kGTLAuthScopeDriveReadonly]
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
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychain(
            forName: kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        rosterListTable.delegate = self;
        rosterListTable.dataSource = self;
    }
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(_ animated: Bool) {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loadRosterList(_ sender: UIButton) {
        if let authorizer = service.authorizer,
            let canAuth = authorizer.canAuthorize , canAuth {
            startQuery()
        } else {
            present(
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
        query?.pageSize = 1000 // max number in roster
        //query.fields = "nextPageToken, files(id, name)"
        query?.spaces = "drive"
        query?.q = "name = '\(folderName)'"
        //query.q = "'0BxrnKK8LdJT0TGVhOEZ1WE5tMnM' in parents"
        service.executeQuery(
            query!,
            delegate: self,
            didFinish: #selector(AddRosterController.findFolderFromTicket(_:finishedWithObject:error:))
        )
    }
    
    // Parse results and display
    func findFolderFromTicket(_ ticket : GTLServiceTicket,
                                 finishedWithObject response : GTLDriveFileList,
                                                    error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        if let files = response.files , !files.isEmpty {
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
                query?.pageSize = 1000 // max number in roster
                //query.fields = "nextPageToken, files(id, name)"
                //query.spaces = "drive"
                query?.q = "'\(folderId)' in parents"
                service.executeQuery(
                    query!,
                    delegate: self,
                    didFinish: #selector(AddRosterController.findFilesFromTicket(_:finishedWithObject:error:))
                )
            }
        } else {
            showAlert("Error", message: "Could not find \(folderName) folder on your Google Drive!")
        }
        
        //output.text = filesString
    }
    
    // Parse results and display
    func findFilesFromTicket(_ ticket : GTLServiceTicket,
                              finishedWithObject response : GTLDriveFileList,
                                                 error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        if let files = response.files , !files.isEmpty {
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
    fileprivate func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joined(separator: " ")
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
    func viewController(_ vc : UIViewController,
                        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
        
        if let error = error {
            service.authorizer = nil
            showAlert("Authentication Error", message: error.localizedDescription)
            return
        }
        
        service.authorizer = authResult
        dismiss(animated: true, completion: nil)
        startQuery()
    }
    
    // Helper for showing an alert
    func showAlert(_ title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        loadingFilesIndicator.stopAnimating()
    }
    
    @IBAction func cancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {});
    }
    
    // table functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rosterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        
        let row = (indexPath as NSIndexPath).row
        cell.textLabel?.text = rosterList[row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "Show Students GDrive" {
            let destionationVC : LoadRosterFromGDrive = segue.destination as! LoadRosterFromGDrive
            
            destionationVC.parentController = self
            destionationVC.rosterFolder = rosterList[(rosterListTable.indexPathForSelectedRow! as NSIndexPath).row]
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //let row = indexPath.row
        //print("Row: \(row)")
    }
}

