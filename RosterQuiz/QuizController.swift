//
//  QuizController.swift
//  RosterQuiz
//
//  Created by Chris Gregg on 6/16/16.
//  Copyright © 2016 Chris Gregg. All rights reserved.
//

import Foundation
import UIKit

// add a shuffle algorithm
// from here: http://stackoverflow.com/a/24029847/561677
extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        let intCount : Int = count as! Int
        
        for i in 0..<intCount - 1 {
            let j = Int(arc4random_uniform(UInt32(intCount - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class QuizController : UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nextLetterHint: UIButton!
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var firstNameGuess: UITextField!
    @IBOutlet weak var correctNameLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    var buttonCount = 7;
    var choiceButtons : [UIButton] = []
    var roster : Roster?
    var studentToGuess : Student?
    var choices : [Student] = []
    var score = 0
    var totalGuesses = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var button0: UIButton!
    //@IBOutlet weak var insideView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if restorationIdentifier == "Multiple Choice Quiz" {
            print("Multiple Choice Quiz Loaded")
            if (roster!.count() < buttonCount) {
                buttonCount = roster!.count()
            }
            choiceButtons.append(button0)
            button0.addTarget(self, action: #selector(userMadeChoice), for: .touchUpInside)
            // get original button0 frame
            //var buttonFrame = button0.frame
            ////var buttonFrame = CGRectMake(8,button0.frame.origin.y,304,button0.frame.height)
            var buttonFrame = button0.frame
            // change button count if there are less than buttonCount number of users

            for i in 1..<buttonCount {
                buttonFrame.origin.y += 30
                // why did it take me 8 hours to try and figure this out?
                // in the end I had to hard-code it, which is really stupid.
                // Apple, please make it easier to center these buttons!!!
                //let button = UIButton(type:UIButtonType.System) as UIButton
                let button = UIButton()
                button.tag = i
                button.titleLabel!.font = button0.titleLabel?.font
                //button.frame = buttonFrame
                //label.center = CGPointMake(160, 284)
                //label.frame.origin.x = studentImage.frame.origin.x
                //label.frame.origin.y = studentImage.frame.origin.y+studentImage.frame.height+26
                //label.center = CGPointMake(studentImage.frame.origin.x, studentImage.frame.origin.y+studentImage.frame.height+26)
                //button.textAlignment = NSTextAlignment.Natural
                //button.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
                button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("Name \(i)", for: UIControlState())
                button.addTarget(self, action: #selector(userMadeChoice), for: .touchUpInside)
                //button.backgroundColor = UIColor.blueColor()
                button.setTitleColor(button0.titleColor(for: UIControlState()), for: UIControlState())
                //button0.backgroundColor = UIColor.blueColor()
                view.addSubview(button)
                // center horizontally
                var constraints = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[superview]-(<=1)-[button]",
                    options: NSLayoutFormatOptions.alignAllCenterX,
                    metrics: nil,
                    views: ["superview":view, "button":button])
                view.addConstraints(constraints)
                button.frame=CGRect(x: 0,y: buttonFrame.origin.y,width: 100,height: 30)
                
                // Center vertically
                // Each button should be 6 away from the previous button
                // But, we just align on the button already present
                constraints = NSLayoutConstraint.constraints(
                    withVisualFormat: "V:[superview]-6-[button]",
                    options: [],
                    metrics: nil,
                    views: ["superview":choiceButtons[i-1], "button":button])
                view.addConstraints(constraints)
                
                //button.frame.origin.y = 280
                choiceButtons.append(button)
                
                //let xConstraint = NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: studentImage, attribute: .CenterX, multiplier: 1, constant: 0)
                
                //NSLayoutConstraint.activateConstraints([xConstraint])
                //NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 530).active = true
                
                //NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: studentImage, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0).active = true
            }
            view.setNeedsLayout()
            view.layoutIfNeeded()
            runMultipleChoiceQuiz()
        }
        else if restorationIdentifier == "Free Response Quiz" {
            firstNameGuess.delegate = self
            runFreeResponseQuiz()
        }
    }
    
    func runMultipleChoiceQuiz() {
        chooseImage()
        getRandomChoices()
    }
    
    func runFreeResponseQuiz() {
        nextLetterHint.isHidden = false
        chooseImage()
        firstNameGuess.text = ""
        correctNameLabel.text = ""
        continueButton.isHidden = true
        firstNameGuess.isEnabled = true
    }
    
    @IBAction func continueClicked(_ sender: UIButton!) {
        runFreeResponseQuiz()
    }
    func chooseImage() {
        // select a random student to display
        var random = Int(arc4random_uniform(UInt32(roster!.count())))
        studentToGuess = roster![random]
        while studentToGuess!.picture == nil { // ignore students without pictures
            random = Int(arc4random_uniform(UInt32(roster!.count())))
            studentToGuess = roster![random]
        }
        studentImage.image = studentToGuess?.picture
    }
    
    func chooseAnother(_ student : Student) -> Bool {
        //while choices.contains(student) || student.first_name == studentToGuess?.first_name {
        if choices.contains(student) {
            return true // must keep choosing
        }
        
        if student.first_name == studentToGuess?.first_name {
            return true // keep choosing
        }
        
        for s in choices {
            if student.first_name == s.first_name {
                return true // keep choosing
            }
        }
        return false
    }
    
    func getRandomChoices(){
        // populate the guesses
        choices = []
        choices.append(studentToGuess!)
        
        // populate with buttonCount-1 other students, without overlap
        for _ in 1..<buttonCount {
            var random = Int(arc4random_uniform(UInt32(roster!.count())))
            var student = roster![random]
            // don't choose a student twice, and don't put the name of the actual
            // student twice.
            while chooseAnother(student) {
                random = Int(arc4random_uniform(UInt32(roster!.count())))
                student = roster![random]
            }
            choices.append(student)
        }
        // shuffle the choices
        choices.shuffleInPlace()
        // populate the buttons with the names
        for i in 0..<buttonCount {
            let attribStr = NSMutableAttributedString(
                string:choices[i].first_name,
                attributes:[:])
            choiceButtons[i].setAttributedTitle(attribStr, for: UIControlState())
            choiceButtons[i].isEnabled = true
        }
    }
    
    func firstDiff(_ s1 : String, s2 : String) -> Int {
        // returns -1 if the strings are the same
        // returns the index of the first character if they are different
        var i = 0
        for c in zip(s1.characters,s2.characters) {
            if c.0 != c.1 {
                break
            }
            i+=1
        }
        if i == s1.characters.count && s1.characters.count == s2.characters.count {
            return -1 // no differences
        }
        if i > s1.characters.count || i > s2.characters.count {
            return -1 // no differences
        }
        return i
    }
    
    func characterAtIndex(_ s : String, index: Int) -> Character? {
        // returns the character at the index
        var i = 0
        for c in s.characters{
            if i < index {
                i+=1
                continue
            }
            return c
        }
        return nil // too far!
    }
    
    @IBAction func provideNextLetter(_ sender: UIButton) {
        // If there is already a partial guess, provide the next letter if it is correct so far.
        // If it is incorrect so far, delete and provide first letter
        let upcaseGuess = firstNameGuess.text!.uppercased()
        let upcaseFirstName = (studentToGuess?.first_name.uppercased())! as String
        
        var fDiff = firstDiff(upcaseGuess, s2: upcaseFirstName)
        if fDiff != -1 {

            let fn = studentToGuess!.first_name

            // provide next letter
            if fDiff >= upcaseFirstName.characters.count {
                fDiff = upcaseFirstName.characters.count - 1
            }
            firstNameGuess.text = studentToGuess?.first_name[fn.startIndex...fn.characters.index(fn.startIndex, offsetBy: fDiff)]
            if fDiff == upcaseFirstName.characters.count-1 {
                userTypedName(nil)
            }
        }
        
    }
    
    func userMadeChoice(_ sender:UIButton!){
        print("Button \(sender.tag) chosen.")
        totalGuesses += 1
        // check if the choice was correct
        if choices[sender.tag] == studentToGuess {
            print("Correct!")
            score += 1
        }
        else {
            print("Incorrect!")
            //sender.backgroundColor = UIColor.redColor()
            let attribStr = NSMutableAttributedString(
                string:(sender.titleLabel?.text)!,
                attributes:[NSStrikethroughStyleAttributeName:NSUnderlineStyle.styleSingle.rawValue])
            
            sender.setAttributedTitle(attribStr, for: UIControlState())
            sender.isEnabled = false
            
            let scorePercent = round(Float(score) / Float(totalGuesses) * 10000) / 100
            scoreLabel.text = "Score: \(score)/\(totalGuesses)(\(scorePercent)%)"
            return
        }

        let scorePercent = round(Float(score) / Float(totalGuesses) * 10000) / 100
        scoreLabel.text = "Score: \(score)/\(totalGuesses)(\(scorePercent)%)"
        runMultipleChoiceQuiz()
    }
    
    @IBAction func userTypedName(_ sender: UITextField!) {
        print("checking...")
        // hide hint button
        nextLetterHint.isHidden = true
        continueButton.isHidden = false
        firstNameGuess.isEnabled = false

        totalGuesses += 1
        if (sender == nil) {
            // guess was provided by hint!
            correctNameLabel.text = studentToGuess!.commaName()
        }
        else {
            if (sender!.text?.uppercased() == studentToGuess?.first_name.uppercased()) {
                print("Correct!")
                correctNameLabel.text = "Correct! \(studentToGuess!.commaName())"
                score += 1
            }
            else {
                print("Incorrect")
                correctNameLabel.text = "Incorrect! \(studentToGuess!.commaName())"
            }
        }
        let scorePercent = round(Float(score) / Float(totalGuesses) * 10000) / 100
        scoreLabel.text = "Score: \(score)/\(totalGuesses)(\(scorePercent)%)"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameGuess {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if restorationIdentifier == "Multiple Choice Quiz" {
            print("Multiple Choice Quiz Appeared")
        }
    }
    
}
