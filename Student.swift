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
    var google_drive_info : GTLDriveFile?
    var first_name : String = ""
    var last_name  : String = ""
    var year       : String = ""
    var picture    : UIImage? = nil
    var notes      : String = ""
    
    func addDetails(_ last : String, first : String, yr : String = "", pic : UIImage? = nil)
    {
        last_name = last
        first_name = first
        year = yr;
        picture = pic
    }
    
    func addPicture(_ pic : UIImage?)
    {
        picture = pic;
    }
    
    func addNameAndImage(_ last: String, first: String, img: UIImage?){
        last_name = last;
        first_name = first;
        picture = img;
    }
    
    func printStudent()
    {
        print("Name: \(last_name) \(first_name), Year: \(year)")
    }
    
    func commaName() -> String {
        return last_name + ", " + first_name
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(google_drive_info, forKey: "google_drive_info")
        aCoder.encode(last_name, forKey: "last_name")
        aCoder.encode(first_name, forKey: "first_name")
        aCoder.encode(year, forKey: "year")
        aCoder.encode(picture, forKey: "picture")
        aCoder.encode(notes, forKey: "notes")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let google_drive_info = aDecoder.decodeObject(forKey: "google_drive_info") as! GTLDriveFile?
        let last_name = aDecoder.decodeObject(forKey: "last_name") as! String
        let first_name = aDecoder.decodeObject(forKey: "first_name") as! String
        let year = aDecoder.decodeObject(forKey: "year") as! String
        let picture = aDecoder.decodeObject(forKey: "picture") as! UIImage?
        let notes = aDecoder.decodeObject(forKey: "notes") as! String
        
        // Must call designated initializer.
        self.init(google_drive_info: google_drive_info, last_name: last_name,
                  first_name : first_name, year: year, picture: picture, notes: notes)
    }
    
    override init() {
        // initial values in declaration
    }
    
    init?(google_drive_info: GTLDriveFile?, last_name: String,
          first_name : String, year: String, picture: UIImage?, notes: String) {
        // Initialize stored properties.
        self.google_drive_info = google_drive_info
        self.last_name = last_name
        self.first_name = first_name
        self.year = year
        self.picture = picture
        self.notes = notes
        super.init()
    }
}
