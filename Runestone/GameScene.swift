//
//  GameScene.swift
//  Runestone
//
//  Created by Ben Wheatley on 08/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import SpriteKit
import GameplayKit

let TILE_WIDTH = CGFloat(0.10)
let TILE_HEIGHT = CGFloat(0.10)

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
	var gameModel = GameModel()
	var currentSelection = Array<Tile>()
	
    private var lastUpdateTime : TimeInterval = 0
	
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
	
	enum Direction {
		case North
		case East
		case South
		case West
	}
	
	enum FastOrPretty {
		case Fast
		case Pretty
	}
	
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
	
	func route(from: Int2DPosition, to: Int2DPosition, direction: Direction, remainingBends: Int) -> [Int2DPosition]? {
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
		
		if gameModel.routable(location: nextFrom)==false {
			if (nextFrom.x==to.x && nextFrom.y==to.y) {
				return [to]
			} else {
				return nil
			}
		}
		
		for nextDirection in [Direction.North, Direction.South, Direction.East, Direction.West] {
			return route(from: nextFrom, to: to,
			             direction: nextDirection,
			             remainingBends: (direction==nextDirection) ? remainingBends : remainingBends-1)
		}
		return nil
	}
	
    func touchDown(atPoint pos : CGPoint) {
		let touchedNodes = self.nodes(at: pos)
		
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
