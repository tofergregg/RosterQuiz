//
//  LoadRosterFromWebsite.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/18/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit

struct RosterInfo {
    var name : String
    var filename : String
}

class AddRosterFromWebsiteController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var loadingFilesIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var rosterListTable: UITableView!
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var userPw: UITextField!
    
    var rosterList : [RosterInfo] = []
    
    var alreadyLoading = false
    
    let textCellIdentifier = "First Cell"
    let sentinel = "_S__S_"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rosterListTable.delegate = self;
        rosterListTable.dataSource = self;
        username.delegate = self;
        userPw.delegate = self;
    }
    
    // When the view appears, ensure that the Drive API service is authorized
    // and perform API calls
    override func viewDidAppear(animated: Bool) {
        alreadyLoading = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if !alreadyLoading {
            if textField == userPw {
                loadRosterList(nil)
            }
            else if textField == username {
                userPw.becomeFirstResponder()
            }
        }
        else {
            alreadyLoading = false
        }
    }
    
    @IBAction func loadRosterList(sender: UIButton!) {
        // dismiss keyboard
        self.view.endEditing(true)
        alreadyLoading = true;
        view.endEditing(true)
        loadingFilesIndicator.startAnimating()
        self.rosterList = [] // reset
        self.rosterListTable.reloadData()
        let url: NSURL = NSURL(string: "https://cs.stanford.edu/~cgregg/cgi-bin/run_python.cgi?script_to_run=../rosters/cgi-bin/list_rosters.cgi")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:url)
        request.HTTPMethod = "POST"
        let bodyData = "name=\(username.text!)&pw=\(userPw.text!)"
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
                    let rosterInfos = stringData.componentsSeparatedByString("\n")
                    for r in rosterInfos {
                        let parts = r.componentsSeparatedByString(self.sentinel)
                        if parts.count == 2 {
                            let rosterInfo = RosterInfo(name:parts[0],filename:parts[1])
                            self.rosterList.append(rosterInfo)
                        }
                    }
                    self.rosterListTable.reloadData()
                }
                self.loadingFilesIndicator.stopAnimating()
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
        cell.textLabel?.text = "\(rosterList[row].name) (\(rosterList[row].filename).pdf)"
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "Show Students Website" {
            let destionationVC : LoadRosterFromWebsite = segue.destinationViewController as! LoadRosterFromWebsite
            
            destionationVC.parentController = self
            destionationVC.rosterFolder = rosterList[rosterListTable.indexPathForSelectedRow!.row]
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        //let row = indexPath.row
        //print("Row: \(row)")
    }
}
