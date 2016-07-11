//
//  TasksManager.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 08.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Foundation


class TasksManager : NSObject {

	var currentTaskNumber : Int = 0
	var numberOfTasks : Int = 0
	var taskArray : [Task] = []

	func getTask() -> Task? {
		if (taskArray.count == 0) {
			initTaskArray();
		}
		if (currentTaskNumber < numberOfTasks) {
			NSNotificationCenter.defaultCenter().addObserver(self,
			                                                 selector:#selector(taskWasSolved),
			                                                 name: "TaskIsSolved",
			                                                 object: taskArray[currentTaskNumber])
/*-----------------------------------------------------------------------------------------------*/
//			NSNotificationCenter.defaultCenter().addObserver(self,
//			                                                 selector:"taskWasSolved:",
//			                                                 name: "TaskIsSolved",
//			                                                 object: taskArray[currentTaskNumber])

			return taskArray[currentTaskNumber]
		} else {
			notifyObserversAboutEndOfGame()
			return nil
		}
	}

	func initTaskArray() -> Void {
		let task1 : Task = Task(question: "Task 1", answer: "123", coast: 10)
		let task2 : Task = Task(question: "No Question", answer: "NO", coast: 11)
		let task3 : Task = Task(question: "Task 3", answer: "3", coast: 12)
		let task4 : Task = Task(question: "TasK 4", answer: "4444", coast: 14)

		taskArray += [task1, task2, task3, task4]
		numberOfTasks = taskArray.count
		currentTaskNumber = 0
	}

	func notifyObserversAboutEndOfGame() -> Void {
		print ("sent message from TaskManager")
		NSNotificationCenter.defaultCenter().removeObserver(self)

		NSNotificationCenter.defaultCenter().postNotificationName("TasksIsFinish", object: self)
	}

	func taskWasSolved(notification: NSNotification) -> Void {
		NSNotificationCenter.defaultCenter().removeObserver(self)
		currentTaskNumber += 1
	}

}