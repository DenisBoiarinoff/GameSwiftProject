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

	@IBOutlet weak var titleRegion: UILabel!
	@IBOutlet weak var questionRegion: UILabel!

	@IBOutlet weak var answerRegion: UIImageView!

	@IBOutlet weak var letterRegion: UIView!
	
	@IBOutlet weak var coinsBtn: UIButton!

	weak var soundBox = SoundBox.soundBox

	private var viewCellStack : ViewCellStack = ViewCellStack()
	private var taskManager : TasksManager = TasksManager()
	private var currentTask : Task!

	private let NUMBER_OF_CELL  = 16;

	private let LETTER_LIST : [Character] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
	                                         "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
	                                         "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
	                                         "U", "V", "W", "X", "Y", "Z"]

	private var coins : Int = 0
	private var posibleAnswer : String = ""
	private var taskNum : Int = 0

	private var cellSize : Double = {
		let parentBounds = UIScreen.mainScreen().bounds
		let parentWidth = parentBounds.size.width
		return 0.5 * Double(parentWidth / 4) - 10
	}()
	private var cellFontSize : Double = {
		let parentBounds = UIScreen.mainScreen().bounds
		let parentWidth = parentBounds.size.width
		let cellSize = 0.5 * Double(parentWidth / 4) - 10
		return cellSize * 0.7
	}()
	private var titleFontSize : Double = {
		let parentBounds = UIScreen.mainScreen().bounds
		return Double(parentBounds.size.height) * 0.035
	}()

	private var dataArray = [Character]()

	private let inputBtnImg = "btn_input";
	private let selectedLetterBtnImg = "btn_letter";
	private let stepBackImg = "btn_return";
	private let btnHelpImg = "btn_hint";

	// MARK: - View Life Cycle

    override func viewDidLoad() -> Void {
        super.viewDidLoad()

		coinsBtn.setTitle( String(coins), forState: UIControlState.Normal)

		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(gameIsEnded),
		                                                 name: "TasksIsFinish",
		                                                 object: taskManager)

		for _ in 1...NUMBER_OF_CELL {
			dataArray.append("0")
		}

		titleRegion.text = "Task # "
    }

    override func didReceiveMemoryWarning() -> Void {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewWillAppear(animated: Bool) -> Void {
		super.viewWillAppear(animated)

		questionRegion.font = UIFont(name: "Arial-BoldMT", size: CGFloat(titleFontSize))
		titleRegion.font = UIFont(name: "Arial-BoldMT", size: CGFloat(titleFontSize))

		viewCellStack.clear()

		reloadTask()
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
			self.coinsBtn.setTitle(String(self.coins), forState: UIControlState.Normal)
			self.viewCellStack.clear()
		}))
		self.presentViewController(alert, animated: true, completion: nil)
	}

	func gameIsEnded(notification: NSNotification) -> Void {
		let alert = UIAlertController(title: "Sorry!!!",
		                              message: "game is over!",
		                              preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Back to Menu", style: UIAlertActionStyle.Default, handler:  {
			_ in
			self.navigationController?.popToRootViewControllerAnimated(true)
		}))

		self.presentViewController(alert, animated: true, completion: nil)
	}

	// MARK: - Optional Functons 

	private func reloadTask() -> Void {

		if currentTask == nil {
			currentTask = taskManager.getTask()
		}

		if (currentTask != nil) {

			taskNum += 1
			NSNotificationCenter.defaultCenter().addObserver(self,
			                                                 selector: #selector(taskWasSolved),
			                                                 name: "TaskIsSolved",
			                                                 object: currentTask)

			titleRegion.text = "Task # \(taskNum)"

			questionRegion.text = currentTask?.question
		    let answer = currentTask?.answer

			for i in 0...NUMBER_OF_CELL - 1 {
				let randInt = Int(arc4random()) % (Int(LETTER_LIST.count) - 1)
				let randChar : Character = LETTER_LIST[randInt]
				dataArray[i] = randChar
			}

			var letterPositionArray : [Int] = []
			letterPositionArray.append(7)
			dataArray[7] = " "
			letterPositionArray.append(15)
			dataArray[15] = " "
			while (answer?.characters.count)! + 2 != letterPositionArray.count {
				let randomInt = Int(arc4random())
				let randInt = randomInt % (NUMBER_OF_CELL - 1)
				let isPresent = letterPositionArray.contains(randInt)
				if !isPresent {
					letterPositionArray.append(randInt)
					let ix = answer!.startIndex
					let ix2 = ix.advancedBy(letterPositionArray.count - 3)
					dataArray[randInt] = answer![ix2]
				}
			}
			reloadLettersView()
			reloadAnswerView()
		}
	}

	private func reloadAnswerView() -> Void {
		for subview: UIView in answerRegion.subviews {
			if !(subview is UIImageView) {
				subview.removeFromSuperview()
			}
		}

		let numberOfLabels : Int = currentTask.answer.characters.count
		let indent = 10.0;
		let cellGroupWidth = Double(numberOfLabels) * Double(cellSize) + (Double(numberOfLabels) - 1) * indent
		let parentBounds = UIScreen.mainScreen().bounds
		let parentWidth = parentBounds.size.width
		let cellGroupLeading = (Double(parentWidth) - cellGroupWidth) / 2
		let parentHeight = parentBounds.size.height

		for i in 0 ..< numberOfLabels {
			let frameRect : CGRect = CGRectMake(CGFloat(cellGroupLeading + Double(i) * (cellSize + indent)),
			                                    CGFloat((Double(parentHeight) * 0.1 - cellSize) / 2),
			                                    CGFloat(cellSize),
												CGFloat(cellSize))

			answerRegion.addSubview(getCellWithImg(inputBtnImg, frameRect:frameRect, text:" ", andTag:100 + i))

		}
	}

	private func reloadLettersView() -> Void {

		for subview: UIView in letterRegion.subviews {
			subview.removeFromSuperview()
		}

		for j in 0...1 {
			for i in 0...((NUMBER_OF_CELL - 1)/2) {
				let frameRect : CGRect = CGRectMake(CGFloat(5 + Double(i) * (cellSize + 10.0)),
				                                    CGFloat(5 + Double(j) * (cellSize + 10.0)),
				                                    CGFloat(cellSize),
				                                    CGFloat(cellSize))

				var letterImgName : String
				if (i + (NUMBER_OF_CELL/2) * j) == 15 {
					letterImgName = stepBackImg
				} else if (i + (NUMBER_OF_CELL/2) * j) == 7 {
					letterImgName = btnHelpImg
				} else {
					letterImgName = selectedLetterBtnImg
				}

				letterRegion.addSubview(getBtnWithImg(letterImgName,
					                                frameRect: frameRect,
				                                 	title: String(dataArray[i + (NUMBER_OF_CELL/2) * j]),
					                                andTag: 200 + i + (NUMBER_OF_CELL / 2) * j))

			}
		}

	}

	private func helpPopup() -> Void {
		let alert = UIAlertController(title: "Problem!?",
		                              message: "Have you any problem!?\n We dont care!",
		                              preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "Back to task",
			                          style: UIAlertActionStyle.Default,
			                          handler: nil))

		self.presentViewController(alert, animated: true, completion: nil)
	}

	private func stepBack() -> Void {

		if posibleAnswer.characters.count != viewCellStack.count() {
			return
		}

		let lastLetterPosition: Int = posibleAnswer.characters.count
		if lastLetterPosition > 0 {
			posibleAnswer = String(posibleAnswer.characters.prefix(lastLetterPosition - 1))
			let lastFullView: UILabel! = answerRegion.viewWithTag(99 + viewCellStack.count()) as! UILabel
			if lastFullView != nil {
				let animationStartPositionFrame: CGRect = answerRegion.convertRect(lastFullView.frame, toView: view)
				let popedCell: UIButton! = viewCellStack.pop() as! UIButton
				let animationEndPositionFrame: CGRect = letterRegion.convertRect(popedCell.frame, toView: view)
				let animationLabel: UILabel = getCellWithImg(selectedLetterBtnImg,
				                                             frameRect: animationStartPositionFrame,
				                                             text: lastFullView.text!,
				                                             andTag: 0)
				view.addSubview(animationLabel)
				animationLabel.hidden = false

				lastFullView.text = " "

				let mirroredimage = UIImage(CGImage: UIImage(named: inputBtnImg)!.CGImage!, scale: 1.0, orientation: .DownMirrored)

				lastFullView.layer.backgroundColor =
					UIColor(patternImage: getImgFromImgContext(mirroredimage,
						inRect: CGRectMake(0, 0, lastFullView.frame.width, lastFullView.frame.height))).CGColor

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

	private func letterSelected(letterIndex: Int) {

		let btn : UIButton = letterRegion.viewWithTag(letterIndex) as! UIButton

		if viewCellStack.count() >= currentTask.answer.characters.count {
			return
		}

		viewCellStack.push(btn)

		let selectedLetter: String = (btn.titleLabel?.text)!
		let animationStartPositionFrame: CGRect = letterRegion.convertRect(btn.frame, toView: view)
		let lastClearLabel: UILabel = answerRegion.viewWithTag(99 + viewCellStack.count()) as! UILabel
		let animationEndPositionFrame: CGRect = answerRegion.convertRect(lastClearLabel.frame, toView: view)

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

	private func answerStringIsChanged() -> Void {
		let currentLength = posibleAnswer.characters.count
		let answerLength = currentTask.answer.characters.count

		for i in 0...answerLength - 1 {
			let label: UILabel? = answerRegion.viewWithTag(100 + i) as? UILabel
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

	private func getCellWithImg(imgName: String, frameRect frame: CGRect, text: String, andTag tag: Int) -> UILabel {

		let label = UILabel(frame: frame)

		label.text = " "
		label.tag = tag
		label.font = UIFont(name: "Arial-BoldMT", size: CGFloat(cellFontSize))
		label.textColor = UIColor.colorWithHexString("091161", alpha: 1)
		label.textAlignment = NSTextAlignment.Center

		let mirroredimage = UIImage(CGImage: UIImage(named: imgName)!.CGImage!, scale: 1.0, orientation: .DownMirrored)

		label.layer.backgroundColor = UIColor(patternImage: getImgFromImgContext(mirroredimage, inRect: CGRectMake(0, 0, frame.width, frame.height))).CGColor

		label.text = text

		return label
	}

	private func getBtnWithImg(imgName: String, frameRect frame: CGRect, title: String, andTag tag: Int) -> UIButton {

		let letter: UIButton = UIButton(frame: frame)

		letter.setTitle(title, forState: UIControlState.Normal)
		letter.tag = tag
		letter.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Center

		let mirroredimage = UIImage(CGImage: UIImage(named: imgName)!.CGImage!, scale: 1.0, orientation: .DownMirrored)

		letter.layer.backgroundColor = UIColor(patternImage: getImgFromImgContext(mirroredimage, inRect: CGRectMake(0, 0, frame.width, frame.height))).CGColor

		letter.titleLabel?.font = UIFont(name: "Arial-BoldMT", size: CGFloat(cellFontSize))
		letter.setTitleColor(UIColor.colorWithHexString("091161", alpha: 1), forState: UIControlState.Normal)

		letter.addTarget(self,
		                 action: #selector(letterBtnPressed),
		                 forControlEvents: UIControlEvents.TouchUpInside)

		return letter
	}

	private func cancelAnswerViewAnimation() -> Void {
		let num: Int = viewCellStack.count()
		for _ in 0...num - 1 {
			stepBack()
		}

	}

	private func getImgFromImgContext(img: UIImage, inRect rect: CGRect) -> UIImage {
		UIGraphicsBeginImageContext(rect.size)
		img.drawInRect(rect)
		let newImg = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImg
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
