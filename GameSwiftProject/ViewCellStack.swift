//
//  ViewCellStack.swift
//  GameSwiftProject
//
//  Created by Rhinoda3 on 08.07.16.
//  Copyright © 2016 Rhinoda. All rights reserved.
//

import Foundation
import UIKit

struct ViewCellStack {
	var items = [UIView]()

	mutating func push(item: UIView) -> Void {
		items.append(item)
	}

	mutating func pop() -> UIView {
		let view = items.last
		items.removeLast()
		return view!
	}

	mutating func clear() -> Void {
		items.removeAll()
	}

	func count() -> Int {
		return items.count
	}

	func lastView() -> UIView? {
		let view : UIView? = items.last
//		if (items.count > 0) {
//			view = items[items.count - 1]
//		}
		return view
	}

}