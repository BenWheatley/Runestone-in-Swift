//
//  KSStringUtil.swift
//  Runestone
//
//  Created by Ben Wheatley on 14/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import Foundation

extension String {
	/**
	Returns a localized version of this string, having treated this string as a localization key
	*/
	func localize() -> String {
		return NSLocalizedString(self, comment: "")
	}
}
