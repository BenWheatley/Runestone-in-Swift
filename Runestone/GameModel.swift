//
//  GameModel.swift
//  Runestone
//
//  Created by Ben Wheatley on 08/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

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

class Tile: SKLabelNode {
	var type: TileType
	var realPosition: Int2DPosition?
	var highlighted = false
	
	init(type: TileType) {
		self.type = type
		super.init()
		let c = Character(UnicodeScalar(type.rawValue+0x16A0)!)
		super.text = String(c)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

struct Int2DPosition {
	var x: Int
	var y: Int
}

class GameModel {
	var width: Int
	var height: Int
	var tiles: [Tile]
	
	init() {
		width = 4
		height = 5
		
		// Create all tiles
		tiles = [Tile]()
		
		var progress = TileType.A
		var subProgress = 0
		
		for _ in 0..<height*width {
			tiles.append(Tile(type:progress))
			subProgress += 1
			if subProgress%4==0 {
				if let nextProgress = TileType( rawValue:(progress.rawValue+1) ) {
					progress = nextProgress
				} else {
					progress = TileType.Blank
				}
			}
		}
		
		// Shuffle all tiles
		tiles.shuffle()
		
		for y in 0..<height {
			for x in 0..<width {
				let i = y*width + x
				tiles[i].realPosition = Int2DPosition(x: x, y: y)
				tiles[i].horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center
				tiles[i].verticalAlignmentMode = SKLabelVerticalAlignmentMode.center
			}
		}
	}
	
	func routable(location: Int2DPosition) -> Bool {
		if location.x < -1 || location.y < -1 || location.x > width || location.y > height {
			return false
		}
		if location.x < 0 || location.y < 0 || location.x == width || location.y == height {
			return true
		}
		let index = location.y*width + location.x
		return tiles[index].type==TileType.Blank
	}
}
