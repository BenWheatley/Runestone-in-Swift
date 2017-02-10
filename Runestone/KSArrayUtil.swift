//
//  KSArrayUtil.swift
//  Runestone
//
//  Created by Ben Wheatley on 08/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import Foundation

extension Array {
	mutating func shuffle() {
		for indexToSwitch in 0..<self.count {
			let range = UInt32( self.count - indexToSwitch )
			let indexToSwitchWith = Int( arc4random_uniform(range) )
			if indexToSwitch != indexToSwitchWith {
				swap(&self[indexToSwitch], &self[indexToSwitchWith])
			}
		}
	}
}
