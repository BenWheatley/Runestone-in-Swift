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
	
	/// Possible types of the tile. Naming this 'Type' would cause a problem, and while I could call it `Type`, the error message said to only do so if another name was unavoidable.
	enum TileType: Int {
		case Blank = 0
		case Blocking = 1
		case A = 2
		case B = 3
		case C = 4
		case D = 5
		case E = 6
		case F = 7
		case G = 8
		case H = 9
		case I = 10
		case J = 11
		case K = 12
		case L = 13
		case M = 14
		case N = 15
		case O = 16
		case P = 17
		case Q = 18
		case R = 19
		case S = 20
		case T = 21
		case U = 22
		case V = 23
		case W = 24
		case X = 25
	}
	
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
