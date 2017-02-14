//
//  GameScene.swift
//  Runestone
//
//  Created by Ben Wheatley on 08/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import SpriteKit
import GameplayKit

// For games like this, I think it's better to have each tile be a fixed fraction of screen size, so the coordinate space is [0,0]-[1,1] rather than [0,0]-[pointWidth,pointHeight]
// Layout constants
let TILE_WIDTH = CGFloat(0.10)
let TILE_HEIGHT = CGFloat(0.10)

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
	private var lastUpdateTime : TimeInterval = 0
	
	var gameModel = GameModel()
	var currentSelection = Array<Tile>()
	
	var lblTiles = SKLabelNode(text: "keyTilesRemaining".localize())
	
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
		self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
		
		let xOffset = CGFloat(gameModel.width-1)/2.0
		let yOffset = CGFloat(gameModel.height-1)/2.0
		
		self.size = CGSize(width: 1, height: 1)
		
		for tile in gameModel.tiles {
			if let pos = tile.realPosition {
				tile.removeFromParent()
				tile.position = CGPoint(x: TILE_WIDTH*(CGFloat(pos.x)-xOffset),
				                        y: TILE_HEIGHT*(CGFloat(pos.y)-yOffset)	)
				tile.setScale(0.002)
				self.addChild(tile)
			}
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
		if firstTile.type == secondTile.type && (route(fastOrPretty:.Pretty, from:firstTile, to:secondTile) != nil) {
			firstTile.removeFromParent()
			secondTile.removeFromParent()
			firstTile.type = TileType.Blank
			secondTile.type = TileType.Blank
			for tile in gameModel.tiles {
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
	
	/** Searches a route between two tiles.
	
	- parameter fastOrPretty: "Pretty" routes use the smallest number of bends, for example two tiles next to each other is a zero-bend path;
	You don't want to use a "pretty" search every frame on every tile, or at least you *didn't* when this was running on an iPhone 4.
	
	- parameter from: The origin tile
	- parameter to: The destination tile
	
	- returns: Optional array of Int2DPosition representing the steps on the route; nil if no route exists
	*/
	func route(fastOrPretty: FastOrPretty, from: Tile, to: Tile) -> [Int2DPosition]? {
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
		if gameModel.routable(location: nextFrom)==false {
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
	
    func touchDown(atPoint pos : CGPoint) {
		let touchedNodes = self.nodes(at: pos)
		
		// Make the touched nodes bounce, mark them as selected and tint them red so the user knows what's up
		for node in touchedNodes {
			if let tile = node as? Tile {
				let scale = SKAction.scale(by: 1.2, duration: 0.15)
				let action = SKAction.sequence([scale, scale.reversed()])
				tile.run(action)
				tile.highlighted = !tile.highlighted
				if (tile.highlighted) {
					tile.fontColor = UIColor.red
					currentSelection.append(tile)
				} else {
					deselect(tile:tile)
				}
			}
		}
		
		if currentSelection.count == 2 {
			tryToMatchAndRemoveTiles(currentSelection[0], currentSelection[1])
		} else if currentSelection.count > 2 {
			// If it's greater than 2 there has been a problem!
			for tile in gameModel.tiles {
				deselect(tile:tile)
			}
		}
    }
	
	/// Deselects a tile (internal state, ought to be refactored…) and removes it from the list of selected tiles
	func deselect(tile:Tile) {
		tile.fontColor = UIColor.white
		if let index = currentSelection.index(of: tile) {
			currentSelection.remove(at: index)
		}
	}
	
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
		
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
