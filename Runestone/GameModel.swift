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
	var currentSelection = Array<Tile>()
	
	init(width: Int = 4, height: Int = 5) {
		self.width = width
		self.height = height
		
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
	
	/// Returns the number of non-blank, non-blocking tiles in this game
	func tileCount() -> Int {
		return tiles.filter({![TileType.Blank, TileType.Blocking].contains($0.type)}).count
	}
	
	/// Returns the number of possible moves given the current board state
	func remainingMovesCount() -> Int {
		var count = 0
		for i in 0..<tiles.count-1 {
			for j in i+1..<tiles.count {
				if route(fastOrPretty: .Pretty, from: tiles[i], to: tiles[j]) != nil {
					count = count + 1
				}
			}
		}
		return count
	}
	
	/**
	- parameter location: Location to test
	- returns: Is the location **both** inside the game space **and** blank?
	*/
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
	
	/// If the user has selected enough tiles, remove them or cancel selection as appropriate
	func processUserActions() {
		// If we have enough selected to remove anything, have a go at removing things
		if currentSelection.count == 2 {
			tryToMatchAndRemoveTiles(currentSelection[0], currentSelection[1])
		} else if currentSelection.count > 2 {
			// If more than than two tiles are selected, there has been a problem!
			for tile in tiles {
				deselect(tile:tile)
			}
		}
	}
	
	/// Deselects a tile and removes it from the list of selected tiles
	func deselect(tile:Tile) {
		tile.highlighted = false
		if let index = currentSelection.index(of: tile) {
			currentSelection.remove(at: index)
		}
	}
	
	/**
	Takes to tiles and if:
	1) they match
	**and**
	2) a route exists between them
	
	it removes the tiles from the game. If they cannot be removed, deselects the second tile.
	*/
	func tryToMatchAndRemoveTiles(_ firstTile: Tile, _ secondTile: Tile) {
		if (route(fastOrPretty:.Pretty, from:firstTile, to:secondTile) != nil) {
			for t in [firstTile, secondTile] {
				t.removeFromParent()
				t.type = TileType.Blank
			}
			for tile in tiles {
				deselect(tile:tile)
			}
		} else {
			deselect(tile:currentSelection[1])
		}
	}
	
	/// Set of directions within the game.
	enum Direction {
		case North
		case East
		case South
		case West
	}
	
	/// Set of search options within the game.
	enum FastOrPretty {
		case Fast
		case Pretty
	}
	
	/** Searches a route between two tiles. Returns nil if the tile pair cannot be removed for whatever reason.
	
	- parameter fastOrPretty: "Pretty" routes use the smallest number of bends, for example two tiles next to each other is a zero-bend path;
	You don't want to use a "pretty" search every frame on every tile, or at least you *didn't* when this was running on an iPhone 4.
	
	- parameter from: The origin tile. Will fail to return a route if this tile is not removable, or is a different type than *to*.
	- parameter to: The destination tile. Will fail to return a route if this tile is not removable, or is a different type than *from*.
	
	- returns: Optional array of Int2DPosition representing the steps on the route; nil if no route exists
	*/
	func route(fastOrPretty: FastOrPretty, from: Tile, to: Tile) -> [Int2DPosition]? {
		// Rapid exit if either of [from, to] tiles is blank or blocking
		for t in [from, to] {
			if [.Blank, .Blocking].contains(t.type) {
				return nil
			}
		}
		// Rapid exit if types do not match
		if from.type != to.type {
			return nil
		}
		
		let minRemainingBends = ( fastOrPretty==FastOrPretty.Fast ? 2 : 1 )
		
		for remainingBends in minRemainingBends..<2 {
			for direction in [Direction.North, Direction.East, Direction.South, Direction.West] {
				let result = route(from: from.realPosition!, to: to.realPosition!, direction: direction, remainingBends: remainingBends)
				if (result != nil) {
					return result
				}
			}
		}
		
		return nil
	}
	
	/** Recursive route finder, not to be called publicly.
	
	- parameter from: The origin tile
	- parameter to: The destination tile
	- parameter direction: The initial direction to be moving in from the origin tile
	- parameter remainingBends: How many more times the route is allowed to bend
	
	- returns: Optional array of Int2DPosition representing the steps on the route; nil if no route exists with the specified requirements.
	*/
	private func route(from: Int2DPosition, to: Int2DPosition, direction: Direction, remainingBends: Int) -> [Int2DPosition]? {
		// If we have turned too often, return nil
		if remainingBends<0 {
			return nil
		}
		
		var nextFrom = from
		switch direction {
		case .North:
			nextFrom.y -= 1
		case .East:
			nextFrom.x += 1
		case .South:
			nextFrom.y += 1
		case .West:
			nextFrom.x -= 1
		}
		
		// If the next place we're going to look at is the destination, just return the destination as the last step on the route to the destination
		if (nextFrom.x==to.x && nextFrom.y==to.y) {
			return [to]
		}
		
		// If there is no route, return nil
		if routable(location: nextFrom)==false {
			return nil
		}
		
		// For each direction, recursively route from there to the destination. If the attempt succeeds, add the place we started from to the start of the route, and pop one level of the recursion
		for nextDirection in [Direction.North, Direction.South, Direction.East, Direction.West] {
			if let route = route(from: nextFrom, to: to,
			                     direction: nextDirection,
			                     remainingBends: (direction==nextDirection) ? remainingBends : remainingBends-1) {
				return [from] + route
			}
		}
		
		// There was no route in any direction from here, so return nil
		return nil
	}
}
