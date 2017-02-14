//
//  KSArrayUtil.swift
//  Runestone
//
//  Created by Ben Wheatley on 08/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import Foundation

extension Array {
	/**
	Shuffles (as in a deck of cards) this array. Modifies existing array, does not return a duplicate.
	
	Each element of the array is swapped at random with another element. No guarantees whatsoever are provided regarding the resulting order, so derangements are unlikely.
	*/
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
