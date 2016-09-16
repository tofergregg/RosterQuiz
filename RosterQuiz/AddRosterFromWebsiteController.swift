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
    override func viewDidAppear(_ animated: Bool) {
        alreadyLoading = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    
    @IBAction func loadRosterList(_ sender: UIButton!) {
        // dismiss keyboard
        self.view.endEditing(true)
        alreadyLoading = true;
        view.endEditing(true)
        loadingFilesIndicator.startAnimating()
        self.rosterList = [] // reset
        self.rosterListTable.reloadData()
        let url: URL = URL(string: "https://cs.stanford.edu/~cgregg/cgi-bin/run_python.cgi?script_to_run=../rosters/cgi-bin/list_rosters.cgi")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url)
        request.httpMethod = "POST"
        let bodyData = "name=\(username.text!)&pw=\(userPw.text!)"
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main)
        {
            (response, data, error) in
            if data != nil {
                let stringData = String(data: data!, encoding:String.Encoding.utf8) as String!
                print(stringData)
                if (stringData?.hasPrefix("User name and password do not match!"))! {
                    self.showAlert("Error!", message: stringData!)
                }
                else {
                    let rosterInfos = stringData?.components(separatedBy: "\n")
                    for r in rosterInfos! {
                        let parts = r.components(separatedBy: self.sentinel)
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
        cell.textLabel?.text = "\(rosterList[row].name) (\(rosterList[row].filename).pdf)"
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "Show Students Website" {
            let destionationVC : LoadRosterFromWebsite = segue.destination as! LoadRosterFromWebsite
            
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
