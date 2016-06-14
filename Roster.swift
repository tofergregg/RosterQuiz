//
//  Roster.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/5/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation

class Roster {
    var name : String = ""
    var students : [Student] = []
    
    func addStudent(student : Student){
        students.append(student)
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
        // last,first,year,gender (year and gender are optional.
        // If the gender is missing, the year can still be used, but
        // if the year is missing, both must be missing). E.g.:
        // Gregg,Chris,Fr,M
        // or
        // Gregg,Chris,Fr
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
            else if details.count == 4 {
                s.addDetails(details[0], first: details[1], yr: details[2], gend: details[3])
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
}
