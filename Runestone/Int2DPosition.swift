//
//  Int2DPosition.swift
//  Runestone
//
//  Created by Ben Wheatley on 18/09/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import Foundation

// Has to be a class instead of a struct because of ObjC compatibility
@objc
class Int2DPosition: NSObject {
	var x: Int
	var y: Int
	init(x: Int, y: Int) {
		(self.x, self.y) = (x, y)
	}
}
