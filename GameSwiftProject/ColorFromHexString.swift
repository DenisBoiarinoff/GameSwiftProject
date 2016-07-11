//
//  ColorFromHexString.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 08.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {

	class func colorWithHexString(hexStr: String, alpha: CGFloat) -> UIColor {
		var hexInt : UInt32 = 0
		let scanner : NSScanner = NSScanner(string: hexStr)

		let skipChars = NSMutableCharacterSet(charactersInString: "#")
		scanner.charactersToBeSkipped = skipChars

		scanner.scanHexInt(&hexInt)

		return UIColor(
			red: CGFloat((hexInt & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((hexInt & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(hexInt & 0x0000FF) / 255.0,
			alpha: CGFloat(alpha)
		)

	}

}