//
//  MainViewController.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 07.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import UIKit
import AudioToolbox


class MainViewController: UIViewController {

	var gameViewController : GameViewController!
	var isSound : Bool = true

	var soundURL: NSURL?
	var soundID:SystemSoundID = 0

	@IBOutlet weak var titleLabel: UILabel!

	// MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

		titleLabel.adjustsFontSizeToFitWidth = true

		if let filePath = NSBundle.mainBundle().pathForResource("tap", ofType: "wav") {
			print("sound");
			soundURL = NSURL(fileURLWithPath: filePath)
			AudioServicesCreateSystemSoundID(soundURL!, &soundID)
		}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	deinit {
		AudioServicesDisposeSystemSoundID(soundID)
	}

	// MARK: - Buttons Actions

	@IBAction func soundSwitchAction(sender: AnyObject) {
		if let btn = sender as? UIButton {
			print("btn")
			isSound = !isSound
			btn.selected = !isSound
		}
	}

	func toPlayController() -> Void {
		if (gameViewController == nil) {
			gameViewController = GameViewController();
		}

		gameViewController.isSound = self.isSound
		self.navigationController?.pushViewController(gameViewController, animated: true)
	}

	@IBAction func btnsActions(sender: AnyObject) {
		if isSound {
			AudioServicesPlaySystemSound(soundID);
		}
		
		switch sender.tag {
		case 11:
			toPlayController()
		default:
			print("Not implemented yet")
		}
	}
	

}
