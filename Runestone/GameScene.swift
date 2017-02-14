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
	
	var lblTiles = SKLabelNode(text: "keyTilesRemaining".localize())
	
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
		
		let xOffset = CGFloat(gameModel.width-1)/2.0
		let yOffset = CGFloat(gameModel.height-1)/2.0
		
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
					gameModel.currentSelection.append(tile)
				} else {
					gameModel.deselect(tile:tile)
				}
			}
		}
		
		gameModel.processUserActions()
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
