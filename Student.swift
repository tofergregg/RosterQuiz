//
//  Student.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit
import GoogleAPIClient

class Student {
    var google_drive_info : GTLDriveFile!
    var first_name : String = ""
    var last_name  : String = ""
    var year       : String = ""
    var gender     : String = ""
    var picture    : UIImage! = nil
    
    func addDetails(last : String, first : String, yr : String = "", gend : String = "", pic : UIImage! = nil)
    {
        last_name = last
        first_name = first
        gender = gend
        year = yr;
        picture = pic
    }
    
    func addPicture(pic : UIImage)
    {
        picture = pic;
    }
    
    func addNameAndImage(last: String, first: String, img: UIImage){
        last_name = last;
        first_name = first;
        picture = img;
    }
    
    func printStudent()
    {
        print("Name: \(last_name) \(first_name), Year: \(year), Gender: \(gender)")
    }
    
    func commaName() -> String {
        return last_name + " ," + first_name
    }

}