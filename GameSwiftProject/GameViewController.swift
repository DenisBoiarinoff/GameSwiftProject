//
//  GameViewController.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 07.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import UIKit
import AudioToolbox

class GameViewController: UIViewController {

	let NUMBER_OF_LETTER  = 16;

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!

	@IBOutlet weak var answerView: UIImageView!
	@IBOutlet weak var letterView: UIView!
	
	@IBOutlet weak var coinsBtn: UIButton!

	weak var soundBox = SoundBox.soundBox

	var viewCellStack : ViewCellStack = ViewCellStack()
	var taskManager : TasksManager = TasksManager()
	var currentTask : Task!

	var soundURL: NSURL?
	var tapSoundID: SystemSoundID = 0
	var letterTapSoundID: SystemSoundID = 0
	var failSoundID: SystemSoundID = 0
	var successSoundID: SystemSoundID = 0

	var isSound: Bool = true

	var coins : Int = 0
	private var posibleAnswer : String!
	private var taskNum : Int = 0

	var cellSize : Double = 0
	var cellFontSize : Double = 0
	var titleFontSize : Double = 0

	private var dataArray = [Character]()

	private var headerText : String = "Task # "

	static private let letterList : [Character] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
	                                       "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
	                                       "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
	                                       "U", "V", "W", "X", "Y", "Z"]

	let inputBtnImg = "btn_input";
	let selectedLetterBtnImg = "btn_letter";
	let stepBackImg = "btn_return";
	let btnHelpImg = "btn_hint";

	// MARK: - View Life Cycle

    override func viewDidLoad() -> Void {
        super.viewDidLoad()

		coinsBtn.setTitle( String(coins), forState: UIControlState.Normal)

		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(gameIsEnded),
		                                                 name: "TasksIsFinish",
		                                                 object: taskManager)

		for _ in 1...NUMBER_OF_LETTER {
			dataArray.append("0")
		}

		titleLabel.text = "Task # "
    }

    override func didReceiveMemoryWarning() -> Void {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewWillAppear(animated: Bool) -> Void {
		super.viewWillAppear(animated)

		let parentBounds = UIScreen.mainScreen().bounds
		let parentWidth = parentBounds.size.width
		let letterViewHeight = parentWidth / 4
		cellSize = 0.5 * Double(letterViewHeight) - 10

		cellFontSize = cellSize * 0.7
		titleFontSize = Double(parentBounds.size.height) * 0.1 * 0.5 * 0.7

		questionLabel.font = UIFont(name: "Arial-BoldMT", size: CGFloat(titleFontSize))
		titleLabel.font = UIFont(name: "Arial-BoldMT", size: CGFloat(titleFontSize))

		posibleAnswer = ""
//		posibleAnswer.removeAll()

		viewCellStack.clear()

		reloadTask()
//		reloadAnswerView()
//		reloadLettersView()
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	// MARK: - Game Event Functions

	func taskWasSolved(notification: NSNotification) -> Void {

		soundBox?.playSoundWithName("success")

		NSNotificationCenter.defaultCenter().removeObserver(self, name: "TaskIsSolved", object: nil)
		self.currentTask = nil

		let alert = UIAlertController(title: "LeveL Complited",
		                              message: "Well done! You guessed thew word and received 10 coins!",
		                              preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Next Level", style: UIAlertActionStyle.Default, handler: {
			_ in
			self.reloadTask()
			self.coins += 10;
			self.coinsBtn.titleLabel?.text = String(self.coins)
			self.viewCellStack.clear()
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}

	func gameIsEnded(notification: NSNotification) -> Void {
		print ("get the message from TaskManager")
		let alert = UIAlertController(title: "Sorry!!!",
		                              message: "game is over!",
		                              preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Back to Menu", style: UIAlertActionStyle.Default, handler:  {
			_ in
			self.navigationController?.popToRootViewControllerAnimated(true)
		}))

		self.presentViewController(alert, animated: true, completion: nil)
		print ("get the message from TaskManager")
	}

	// MARK: - Optional Functons 

	func reloadTask() -> Void {

		if currentTask == nil {
			currentTask = taskManager.getTask()
			if currentTask != nil {
				taskNum += 1
				NSNotificationCenter.defaultCenter().addObserver(self,
				                                                 selector: #selector(taskWasSolved),
				                                                 name: "TaskIsSolved",
				                                                 object: currentTask)
//				reloadAnswerView()
			}


		}

		if (currentTask != nil) {

			headerText = "Task # \(taskNum)"
			titleLabel.text = headerText

			questionLabel.text = currentTask?.question
			//		let answer = Array(arrayLiteral: currentTask.answer)
			let answer = currentTask?.answer

			for i in 0...NUMBER_OF_LETTER - 1 {
				let randInt = Int(arc4random()) % (Int(GameViewController.letterList.count) - 1)
				let randChar : Character = GameViewController.letterList[randInt]
				dataArray[i] = randChar
			}

			var letterPositionArray : [Int] = []
			letterPositionArray.append(7)
			dataArray[7] = " "
			letterPositionArray.append(15)
			dataArray[15] = " "
			while (answer?.characters.count)! + 2 != letterPositionArray.count {
				let randomInt = Int(arc4random())
				print (randomInt, Int(GameViewController.letterList.count) - 1)
				let randInt = randomInt % (NUMBER_OF_LETTER - 1)
				print(randInt)
				let isPresent = letterPositionArray.contains(randInt)
				if !isPresent {
					letterPositionArray.append(randInt)
					//				dataArray[randInt] = answer[letterPositionArray.count - 3]
					let ix = answer!.startIndex
					let ix2 = ix.advancedBy(letterPositionArray.count - 3)
					//				let ix2 = advance(ix,letterPositionArray.count - 3)
					dataArray[randInt] = answer![ix2]
				}
			}
			reloadLettersView()
			reloadAnswerView()
		}
	}

	func reloadAnswerView() -> Void {
		for subview: UIView in answerView.subviews {
			if !(subview is UIImageView) {
				subview.removeFromSuperview()
			}
		}

		let numberOfLabels : Int = currentTask.answer.characters.count
		let indent = 10.0;
		let cellGroupWidth = Double(numberOfLabels) * Double(cellSize) + (Double(numberOfLabels) - 1) * indent
		print(cellGroupWidth)
		let parentBounds = UIScreen.mainScreen().bounds
		let parentWidth = parentBounds.size.width
		let cellGroupLeading = (Double(parentWidth) - cellGroupWidth) / 2
		let parentHeight = parentBounds.size.height

		for i in 0 ..< numberOfLabels {
			let frameRect : CGRect = CGRectMake(CGFloat(cellGroupLeading + Double(i) * (cellSize + indent)),
			                                    CGFloat((Double(parentHeight) * 0.1 - cellSize) / 2),
			                                    CGFloat(cellSize),
												CGFloat(cellSize))

			answerView.addSubview(getCellWithImg(inputBtnImg, frameRect:frameRect, text:" ", andTag:100 + i))

		}
	}

	func reloadLettersView() -> Void {

		for subview: UIView in letterView.subviews {
			subview.removeFromSuperview()
		}

		for j in 0...1 {
			for i in 0...((NUMBER_OF_LETTER - 1)/2) {
				print (i + (NUMBER_OF_LETTER/2) * j)
				let frameRect : CGRect = CGRectMake(CGFloat(5 + Double(i) * (cellSize + 10.0)),
				                                    CGFloat(5 + Double(j) * (cellSize + 10.0)),
				                                    CGFloat(cellSize),
				                                    CGFloat(cellSize))

				var letterImgName : String
				if (i + (NUMBER_OF_LETTER/2) * j) == 15 {
					letterImgName = stepBackImg
				} else if (i + (NUMBER_OF_LETTER/2) * j) == 7 {
					letterImgName = btnHelpImg
				} else {
					letterImgName = selectedLetterBtnImg
				}

				letterView.addSubview(getBtnWithImg(letterImgName,
					                                frameRect: frameRect,
				                                 	title: String(dataArray[i + (NUMBER_OF_LETTER/2) * j]),
					                                andTag: 200 + i + (NUMBER_OF_LETTER / 2) * j))

			}
		}

	}

	func helpPopup() -> Void {
		let alert = UIAlertController(title: "Problem!?",
		                              message: "Have you any problem!?\n We dont care!",
		                              preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Back to task",
			                          style: UIAlertActionStyle.Default,
			                          handler: nil))

		self.presentViewController(alert, animated: true, completion: nil)
	}

	func stepBack() -> Void {

		if posibleAnswer.characters.count != viewCellStack.count() {
			return
		}
		let lastLetterPosition: Int = posibleAnswer.characters.count
		if lastLetterPosition > 0 {
			posibleAnswer = String(posibleAnswer.characters.prefix(lastLetterPosition - 1))
			let lastFullView: UILabel! = answerView.viewWithTag(99 + viewCellStack.count()) as! UILabel
			if lastFullView != nil {
				let animationStartPositionFrame: CGRect = answerView.convertRect(lastFullView.frame, toView: view)
				let popedCell: UIButton! = viewCellStack.pop() as! UIButton
				let animationEndPositionFrame: CGRect = letterView.convertRect(popedCell.frame, toView: view)
				let animationLabel: UILabel = getCellWithImg(selectedLetterBtnImg,
				                                             frameRect: animationStartPositionFrame,
				                                             text: lastFullView.text!,
				                                             andTag: 0)
				view.addSubview(animationLabel)
				animationLabel.hidden = false

				lastFullView.text = " "

				let inputImg: UIImage = UIImage(named: inputBtnImg)!

				let mirroredimage = UIImage(CGImage: inputImg.CGImage!, scale: 1.0, orientation: .DownMirrored)
				let inputImgSize = lastFullView.frame.size

				UIGraphicsBeginImageContext(inputImgSize)
				mirroredimage.drawInRect(CGRectMake(0, 0, inputImgSize.width, inputImgSize.height))
				let newImg = UIGraphicsGetImageFromCurrentImageContext()
				UIGraphicsEndImageContext()

				lastFullView.layer.backgroundColor = UIColor(patternImage: newImg).CGColor

				UIView.animateWithDuration(0.3,
				                           delay: 0.1,
				                           options: UIViewAnimationOptions.CurveEaseInOut,
				                           animations: { () -> Void in
											   animationLabel.center = CGPointMake(animationEndPositionFrame.origin.x + animationEndPositionFrame.size.width/2,
												                                   animationEndPositionFrame.origin.y + animationEndPositionFrame.size.height/2)
					                       },
				                           completion: { (finished: Bool) -> Void in
											   popedCell.hidden = false
											   animationLabel.hidden = true
											   animationLabel.removeFromSuperview()
				                           })
			}
		}
	}

	func letterSelected(letterIndex: Int) {

		let btn : UIButton = letterView.viewWithTag(letterIndex) as! UIButton

		if viewCellStack.count() >= currentTask.answer.characters.count {
			return
		}

		viewCellStack.push(btn)

		let selectedLetter: String = (btn.titleLabel?.text)!

		let animationStartPositionFrame: CGRect = letterView.convertRect(btn.frame, toView: view)

		let lastClearLabel: UILabel = answerView.viewWithTag(99 + viewCellStack.count()) as! UILabel

		let animationEndPositionFrame: CGRect = answerView.convertRect(lastClearLabel.frame, toView: view)

		let animationLabel: UILabel = getCellWithImg(selectedLetterBtnImg,
		                                             frameRect: animationStartPositionFrame,
		                                             text: selectedLetter,
		                                             andTag: 0)
		view.addSubview(animationLabel)

		animationLabel.hidden = false

		btn.hidden = true

		UIView.animateWithDuration(1.0,
		                           delay: 0.1,
		                           options: UIViewAnimationOptions.CurveEaseInOut,
		                           animations: {
									   animationLabel.center = CGPointMake(animationEndPositionFrame.origin.x + animationEndPositionFrame.size.width/2,
										                                   animationEndPositionFrame.origin.y + animationEndPositionFrame.size.height/2)
			                       },
		                           completion: { (finished: Bool) -> Void in
									   animationLabel.hidden = true
									   self.posibleAnswer.appendContentsOf(selectedLetter)
									   self.answerStringIsChanged()
									   animationLabel.removeFromSuperview()
		                           })

	}

	func answerStringIsChanged() -> Void {
		let currentLength = posibleAnswer.characters.count
		let answerLength = currentTask.answer.characters.count

		for i in 0...answerLength - 1 {
			let label: UILabel? = answerView.viewWithTag(100 + i) as? UILabel
			if label != nil {
				if (label?.tag)! - 100 < currentLength {
					let index = posibleAnswer.startIndex.advancedBy(i)
					label?.text = String(posibleAnswer.characters[index])

					let letterImg = UIImage(named: selectedLetterBtnImg)

					let mirroredimage = UIImage(CGImage: letterImg!.CGImage!, scale: 1.0, orientation: .DownMirrored)
					let imgSize = label?.frame.size

					UIGraphicsBeginImageContext(imgSize!)
					mirroredimage.drawInRect(CGRectMake(0, 0, (imgSize?.width)!, (imgSize?.height)!))
					let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
					UIGraphicsEndImageContext()

					label?.layer.backgroundColor = UIColor(patternImage: newImage).CGColor
				}
			}
		}

		if posibleAnswer.characters.count >= currentTask.answer.characters.count {
			let isSolved = currentTask.verifyAnswer(posibleAnswer)
			if !isSolved {

				soundBox?.playSoundWithName("fail")

				let alert = UIAlertController(title: "Oh no!!!",
				                              message: "Wrong answer!",
				                              preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "Back to task",
					style: UIAlertActionStyle.Default,
					handler: nil))

				self.presentViewController(alert, animated: true, completion: nil)

			}

			cancelAnswerViewAnimation()
			viewCellStack.clear()
		}

	}

	func getCellWithImg(imgName: String, frameRect frame: CGRect, text: String, andTag tag: Int) -> UILabel {

		let label = UILabel(frame: frame)
		label.text = " "
		label.tag = tag
		label.font = UIFont(name: "Arial-BoldMT", size: CGFloat(cellFontSize))
		label.textColor = UIColor.colorWithHexString("091161", alpha: 1)
		label.textAlignment = NSTextAlignment.Center

		let letterImg = UIImage(named: imgName)
		let mirroredimage = UIImage(CGImage: letterImg!.CGImage!, scale: 1.0, orientation: .DownMirrored)
		let imgSize = label.frame.size

		UIGraphicsBeginImageContext(imgSize)
		mirroredimage.drawInRect(CGRectMake(0, 0, imgSize.width, imgSize.height))
		let newImg = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		label.layer.backgroundColor = UIColor(patternImage: newImg).CGColor
		label.text = text

		return label
	}

	func getBtnWithImg(imgName: String, frameRect frame: CGRect, title: String, andTag tag: Int) -> UIButton {

		let letter: UIButton = UIButton(frame: frame)

		letter.setTitle(title, forState: UIControlState.Normal)
		letter.tag = tag
		letter.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center

		let letterImg = UIImage(named: imgName)

		let mirroredimage = UIImage(CGImage: letterImg!.CGImage!, scale: 1.0, orientation: .DownMirrored)
		let letterImgSize = letter.frame.size;

		UIGraphicsBeginImageContext(letterImgSize)

		mirroredimage.drawInRect(CGRectMake(0, 0, letterImgSize.width, letterImgSize.height))
		let newImg = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		letter.layer.backgroundColor = UIColor(patternImage: newImg).CGColor

		letter.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: CGFloat(cellFontSize))
		letter.setTitleColor(UIColor.colorWithHexString("091161", alpha: 1), forState: UIControlState.Normal)

		letter.addTarget(self, action: #selector(letterBtnPressed), forControlEvents: UIControlEvents.TouchUpInside)

		return letter
	}

	func cancelAnswerViewAnimation() -> Void {
		let num: Int = viewCellStack.count()
		for _ in 0...num - 1 {
			stepBack()
		}

	}

	// MARK: - Buttons Actions

	@IBAction func toMainScreen(sender: AnyObject) {
		soundBox?.playSoundWithName("tap")

		self.navigationController?.popToRootViewControllerAnimated(true)
	}

	@IBAction func letterBtnPressed(sender: AnyObject) -> Void {
		soundBox?.playSoundWithName("letter_tap")

		let letterIndex: Int = sender.tag
		switch letterIndex {
		case 207:
			helpPopup()
		case 215:
			stepBack()
		default:
			letterSelected(letterIndex)
		}
	}

}
