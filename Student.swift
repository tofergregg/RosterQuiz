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

class Student : NSObject, NSCoding {
    var google_drive_info : GTLDriveFile!
    var first_name : String = ""
    var last_name  : String = ""
    var year       : String = ""
    var gender     : String = ""
    var picture    : UIImage! = nil
    var notes      : String = ""
    
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
        return last_name + ", " + first_name
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(google_drive_info, forKey: "google_drive_info")
        aCoder.encodeObject(last_name, forKey: "last_name")
        aCoder.encodeObject(first_name, forKey: "first_name")
        aCoder.encodeObject(year, forKey: "year")
        aCoder.encodeObject(gender, forKey: "gender")
        aCoder.encodeObject(picture, forKey: "picture")
        aCoder.encodeObject(notes, forKey: "notes")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let google_drive_info = aDecoder.decodeObjectForKey("google_drive_info") as! GTLDriveFile!
        let last_name = aDecoder.decodeObjectForKey("last_name") as! String
        let first_name = aDecoder.decodeObjectForKey("first_name") as! String
        let year = aDecoder.decodeObjectForKey("year") as! String
        let gender = aDecoder.decodeObjectForKey("gender") as! String
        let picture = aDecoder.decodeObjectForKey("picture") as! UIImage
        let notes = aDecoder.decodeObjectForKey("notes") as! String
        
        // Must call designated initializer.
        self.init(google_drive_info: google_drive_info, last_name: last_name,
                  first_name : first_name, year: year, gender: gender, picture: picture, notes: notes)
    }
    
    override init() {
        // initial values in declaration
    }
    
    init?(google_drive_info: GTLDriveFile, last_name: String,
          first_name : String, year: String, gender: String, picture: UIImage, notes: String) {
        // Initialize stored properties.
        self.google_drive_info = google_drive_info
        self.last_name = last_name
        self.first_name = first_name
        self.year = year
        self.gender = gender
        self.picture = picture
        self.notes = notes
        super.init()
    }
}
