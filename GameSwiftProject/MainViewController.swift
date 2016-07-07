//
//  MainViewController.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 07.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	var gameViewController : GameViewController!

	@IBOutlet weak var titleLabel: UILabel!

	// MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - Buttons Actions

	@IBAction func soundSwitchAction(sender: AnyObject) {
	}

	@IBAction func toPlayController(sender: AnyObject) {

		if (gameViewController == nil) {
			gameViewController = GameViewController();
		}

		self.navigationController?.pushViewController(gameViewController, animated: true)
		
	}
}
