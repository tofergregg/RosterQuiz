//
//  SecondViewController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import UIKit
import AeroGearHttp
import AeroGearOAuth2

class SecondViewController: UIViewController {
    var http: Http!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.http = Http(baseURL: nil, sessionConfig: NSURLSessionConfiguration.defaultSessionConfiguration(), requestSerializer: JsonRequestSerializer(), responseSerializer: StringResponseSerializer())
        self.http = Http()
        share()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func share(){
        let googleId = "795309004462-itm898hfu3gna8rnb1mjlv2jmaj8d6jd.apps.googleusercontent.com"
        //let googleId = "aa851f2153089dc8f1269370828accabf4d6ebde"
        let googleConfig = GoogleConfig(
            clientId: googleId,                               // [1] Define a Google configuration
            scopes:["https://www.googleapis.com/auth/drive"])            // [2] Specify scope
        
        let gdModule = AccountManager.addGoogleAccount(googleConfig)     // [3] Add it to AccountManager
        self.http.authzModule = gdModule                                 // [4] Inject the AuthzModule
        // into the HTTP layer object
        
        let param_list = ["q":"fullText+contains+'RosterQuiz_pics'"]
        //let param_list = Dictionary<String,String>()

        
        self.http.request(.POST,path:"https://www.googleapis.com/drive/v2/files",
            parameters: param_list,
            completionHandler: {(response, error) in
                if (error != nil) {
                    self.presentAlert("Error", message: error!.localizedDescription)
                } else {
                    // response is json
                    let responseDict = response as! Dictionary<String,AnyObject>
                    
                    print(responseDict["kind"] as! String)
                    print(responseDict["etag"] as! String)
                    print(responseDict["selfLink"] as! String)
                    if (responseDict["nextPageToken"] != nil) {
                        print(responseDict["nextPageToken"] as! String)
                    }
                    if (responseDict["nextLink"] != nil) {
                        print(responseDict["nextLink"] as! String)
                    }

                    self.presentAlert("Success", message: (response?.string)!)
                }
        })
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

