//
//  GameViewController.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 07.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {


	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var questionLabel: UILabel!

	@IBOutlet weak var answerView: UIImageView!
	@IBOutlet weak var letterView: UIView!

	
	@IBOutlet weak var coinsBtn: UIButton!

	// MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	@IBAction func toMainScreen(sender: AnyObject) {
		self.navigationController?.popToRootViewControllerAnimated(true)
	}
}
