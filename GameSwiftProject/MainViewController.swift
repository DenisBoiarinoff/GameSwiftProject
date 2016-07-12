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

	weak var soundBox = SoundBox.soundBox

	@IBOutlet weak var titleLabel: UILabel!

	// MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

		titleLabel.adjustsFontSizeToFitWidth = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	deinit {
	}

	// MARK: - Buttons Actions

	@IBAction func soundSwitchAction(sender: AnyObject) {
		if let btn = sender as? UIButton {
			btn.selected = !soundBox!.switchSound()
		}
	}

	func toPlayController() -> Void {
		if (gameViewController == nil) {
			gameViewController = GameViewController();
		}

		self.navigationController?.pushViewController(gameViewController, animated: true)
	}

	@IBAction func btnsActions(sender: AnyObject) {

		soundBox!.playSoundWithName("tap")

		switch sender.tag {
		case 11:
			toPlayController()
		default:
			print("Not implemented yet")
		}
	}
	

}
