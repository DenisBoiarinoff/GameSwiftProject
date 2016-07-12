//
//  SoundBox.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 12.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundBox {

	static let soundKeyArray = ["tap",
	                            "letter_tap",
	                            "fail",
	                            "success"]

	static let soundType = "wav"

	var soundsDictionary = [String:SystemSoundID]()

	var isSound : Bool = true

	// MARK: - Life Cycle

	init() {
		for name in SoundBox.soundKeyArray {
			if let filePath = NSBundle.mainBundle().pathForResource(name, ofType: SoundBox.soundType) {
				let soundURL = NSURL(fileURLWithPath: filePath)
				var soundID : SystemSoundID = 0
				AudioServicesCreateSystemSoundID(soundURL, &soundID)
				soundsDictionary[name] = soundID
			}

		}
	}

	deinit {
		for (soundName, soundID) in soundsDictionary {
			AudioServicesDisposeSystemSoundID(soundID)
			soundsDictionary[soundName] = nil
		}
	}

	// MARK: - Public Functions

	func setSoundOnOff(isSound: Bool) -> Bool {
		self.isSound = isSound
		return self.isSound
	}

	func switchSound() -> Bool {
		isSound = !isSound
		return isSound
	}

	func isSoundOn() -> Bool {
		return isSound
	}

	func playSoundWithName(name: String) {
		if isSoundOn() {
			AudioServicesPlaySystemSound(soundsDictionary[name]!)
		}
	}

}