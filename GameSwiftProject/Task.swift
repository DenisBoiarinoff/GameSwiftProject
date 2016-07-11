//
//  Task.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 07.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Foundation

class Task : NSObject {

	let question : String
	let answer : String
	let coast : Int
	var isSolved : Bool = false

	init (question : String, answer : String, coast : Int) {
		self.question = question
		self.answer = answer
		self.coast = coast
	}


	func verifyAnswer(posibleAnswer: String) -> Bool {
		if (posibleAnswer == answer) {
			isSolved = true
			notifyObserversAboutSolving()
		}
		return isSolved
	}

	func getCoast() -> Int {
		if (isSolved) {
			return coast
		} else {
			return 0
		}
	}

	func solveTask(posibleAnswer: String) -> Int {
		if (verifyAnswer(posibleAnswer)) {
			return coast
		}
		return 0
	}

	func notifyObserversAboutSolving() -> Void {
		NSNotificationCenter.defaultCenter().postNotificationName("TaskIsSolved", object: self)
	}

}