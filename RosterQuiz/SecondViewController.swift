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

class SecondViewController: UIViewController {
    private let kKeychainItemName = "Drive API"
    private let kClientID = "795309004462-itm898hfu3gna8rnb1mjlv2jmaj8d6jd.apps.googleusercontent.com"
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLAuthScopeDriveFile]
    // private let scopes = [kGTLAuthScopeDriveMetadataReadonly]
    
    
    private let service = GTLServiceDrive()
    let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Drive API service
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.frame = view.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        
        view.addSubview(output);
        
        if let auth = GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: nil) {
            service.authorizer = auth
        }
        
    }
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
            fetchFiles()
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Construct a query to get names and IDs of 10 files using the Google Drive API
    func fetchFiles() {
        output.text = "Getting files..."
        let query = GTLQueryDrive.queryForFilesList()
        query.pageSize = 10
        //query.fields = "nextPageToken, files(id, name)"
        query.fields = "name = 'RosterQuiz_pics'"
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: #selector(SecondViewController.displayResultWithTicket(_:finishedWithObject:error:))
        )
    }
    
    // Parse results and display
    func displayResultWithTicket(ticket : GTLServiceTicket,
                                 finishedWithObject response : GTLDriveFileList,
                                                    error : NSError?) {
        
        if let error = error {
            showAlert("Error", message: error.localizedDescription)
            return
        }
        
        var filesString = ""
        
        if let files = response.files where !files.isEmpty {
            filesString += "Files:\n"
            for file in files as! [GTLDriveFile] {
                filesString += "\(file.name) (\(file.identifier))\n"
            }
        } else {
            filesString = "No files found."
        }
        
        output.text = filesString
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
            finishedSelector: #selector(SecondViewController.viewController(_:finishedWithAuth:error:))
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

