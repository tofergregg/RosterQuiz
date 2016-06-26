//
//  Roster.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation

class Roster : NSObject, NSCoding {
    var name : String = ""
    var students : [Student] = []
    
    convenience init(n : String) {
        self.init(name : n, students: [])!
    }
    
    func addStudent(student : Student){
        students.append(student)
    }
    
    func sortStudents() {
        students.sortInPlace({$0.last_name < $1.last_name})
    }
    func count() -> Int {
        return students.count
    }
    
    // define the bracket notation
    subscript(index : Int) -> Student {
        get {
            return students[index]
        }
        set {
            students[index] = newValue
        }
    }
    
    func csv_paste(pasted : String)
    {
        // pasted text should have the following form, separated by newlines:
        // last,first,year (year is optional).
        // /E.g.:
        // Gregg,Chris,Freshman
        let lines = pasted.componentsSeparatedByString("\n")
        for line in lines {
            let s = Student()
            let details = line.componentsSeparatedByString(",")
            
            if details.count == 2 {
                s.addDetails(details[0], first: details[1])
            }
            else if details.count == 3 {
                s.addDetails(details[0], first: details[1], yr: details[2])
            }
            else {
                // could not parse
                continue
            }
            students.append(s)
        }
        
    }
    func printRoster()
    {
        for student in students {
            student.printStudent()
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(students, forKey: "students")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey("name") as! String
        let students = aDecoder.decodeObjectForKey("students") as! [Student]
        
        // Must call designated initializer.
        self.init(name: name, students: students)
    }
    
    override init() {
        // initial values in declaration
    }
    
    init?(name: String, students: [Student]) {
        // Initialize stored properties.
        self.name = name
        self.students = students
        super.init()
    }
}
