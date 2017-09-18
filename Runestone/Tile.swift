//
//  Tile.swift
//  Runestone
//
//  Created by Ben Wheatley on 18/09/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import Foundation
import SpriteKit

class Tile: SKLabelNode {
	var type: TileType
	var realPosition: Int2DPosition?
	var highlighted: Bool = false {
		didSet {
			if highlighted {
				fontColor = UIColor.red
			} else {
				fontColor = UIColor.white
			}
		}
	}
	
	init(type: TileType) {
		self.type = type
		super.init()
		let c = Character(UnicodeScalar(type.rawValue+0x16A0)!)
		super.text = String(c)
		self.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
		self.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
