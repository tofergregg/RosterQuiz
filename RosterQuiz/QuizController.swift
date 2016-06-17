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
extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class QuizController : UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var studentImage: UIImageView!
    @IBOutlet weak var firstNameGuess: UITextField!
    @IBOutlet weak var correctNameLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    var buttonCount = 6;
    var choiceButtons : [UIButton] = []
    var roster : Roster?
    var studentToGuess : Student?
    var choices : [Student] = []
    var score = 0
    var totalGuesses = 0
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var insideView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if restorationIdentifier == "Multiple Choice Quiz" {
            print("Multiple Choice Quiz Loaded")
            choiceButtons.append(button0)
            button0.addTarget(self, action: #selector(userMadeChoice), forControlEvents: .TouchUpInside)
            // get original button0 frame
            //var buttonFrame = button0.frame
            var buttonFrame = CGRectMake(8,button0.frame.origin.y,304,button0.frame.height)
            for i in 1..<buttonCount {
                buttonFrame.origin.y += 30
                // why did it take me 8 hours to try and figure this out?
                // in the end I had to hard-code it, which is really stupid.
                // Apple, please make it easier to center these buttons!!!
                //buttonFrame.set
                let button = UIButton(type:UIButtonType.System) as UIButton
                button.tag = i
                button.frame = buttonFrame
                choiceButtons.append(button)
                //label.center = CGPointMake(160, 284)
                //label.frame.origin.x = studentImage.frame.origin.x
                //label.frame.origin.y = studentImage.frame.origin.y+studentImage.frame.height+26
                //label.center = CGPointMake(studentImage.frame.origin.x, studentImage.frame.origin.y+studentImage.frame.height+26)
                //button.textAlignment = NSTextAlignment.Natural
                //button.autoresizingMask = [.FlexibleRightMargin, .FlexibleBottomMargin]
                //button.translatesAutoresizingMaskIntoConstraints = false
                button.setTitle("Name \(i)", forState: .Normal)
                button.addTarget(self, action: #selector(userMadeChoice), forControlEvents: .TouchUpInside)
                //button.backgroundColor = UIColor.blueColor()
                //button0.backgroundColor = UIColor.blueColor()
                insideView.addSubview(button)
                //let xConstraint = NSLayoutConstraint(item: button, attribute: .CenterX, relatedBy: .Equal, toItem: studentImage, attribute: .CenterX, multiplier: 1, constant: 0)
                
                //NSLayoutConstraint.activateConstraints([xConstraint])
                //NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 530).active = true
                
                //NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: studentImage, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0).active = true
            }
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
        chooseImage()
        firstNameGuess.text = ""
        correctNameLabel.text = ""
        continueButton.hidden = true
        firstNameGuess.enabled = true
    }
    
    @IBAction func continueClicked(sender: UIButton!) {
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
    
    func getRandomChoices(){
        // populate the guesses
        choices = []
        choices.append(studentToGuess!)
        
        // populate with buttonCount-1 other students, without overlap
        for _ in 1..<buttonCount {
            var random = Int(arc4random_uniform(UInt32(roster!.count())))
            var student = roster![random]
            while choices.contains(student) {
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
                string:choices[i].commaName(),
                attributes:[:])
            choiceButtons[i].setAttributedTitle(attribStr, forState: .Normal)
            choiceButtons[i].enabled = true
        }
    }
    func userMadeChoice(sender:UIButton!){
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
                attributes:[NSStrikethroughStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue])
            
            sender.setAttributedTitle(attribStr, forState: .Normal)
            sender.enabled = false
            
            let scorePercent = round(Float(score) / Float(totalGuesses) * 10000) / 100
            scoreLabel.text = "Score: \(score)/\(totalGuesses)(\(scorePercent)%)"
            return
        }

        let scorePercent = round(Float(score) / Float(totalGuesses) * 10000) / 100
        scoreLabel.text = "Score: \(score)/\(totalGuesses)(\(scorePercent)%)"
        runMultipleChoiceQuiz()
    }
    
    @IBAction func userTypedName(sender: UITextField!) {
        print("checking...")
        continueButton.hidden = false
        firstNameGuess.enabled = false

        totalGuesses += 1
        if (sender!.text == studentToGuess?.first_name) {
            print("Correct!")
            correctNameLabel.text = "Correct! \(studentToGuess!.commaName())"
            score += 1
        }
        else {
            print("Incorrect")
            correctNameLabel.text = "Incorrect! \(studentToGuess!.commaName())"
        }
        let scorePercent = round(Float(score) / Float(totalGuesses) * 10000) / 100
        scoreLabel.text = "Score: \(score)/\(totalGuesses)(\(scorePercent)%)"
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstNameGuess {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        if restorationIdentifier == "Multiple Choice Quiz" {
            print("Multiple Choice Quiz Appeared")
        }
    }
    
}