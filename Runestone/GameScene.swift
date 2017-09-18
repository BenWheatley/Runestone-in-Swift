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
let SCALE = CGFloat(0.002)

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
	private var lastUpdateTime : TimeInterval = 0
	
	var gameModel = GameModel()
	
	var lblTiles = SKLabelNode()
	var lblRemainingMoves = SKLabelNode()
	
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
		
		hardResetGameModel()
		
		for label in [lblTiles, lblRemainingMoves] {
			label.removeFromParent()
			label.color = UIColor.white
			label.setScale(SCALE)
			self.addChild(label)
		}
		lblTiles.position = CGPoint(x: 0, y: -0.4)
		lblRemainingMoves.position = CGPoint(x: 0, y: -0.45)
	}
	
	func hardResetGameModel(gameSize: GameModel.GameSize = .smallest) {
		for t in gameModel.tiles {
			t.removeFromParent()
		}
		
		gameModel = GameModel(size: gameSize)
		let xOffset = CGFloat(gameModel.width-1)/2.0
		let yOffset = CGFloat(gameModel.height-1)/2.0
		
		for tile in gameModel.tiles {
			if let pos = tile.realPosition {
				tile.removeFromParent()
				tile.position = CGPoint(x: TILE_WIDTH*(CGFloat(pos.x)-xOffset),
				                        y: TILE_HEIGHT*(CGFloat(pos.y)-yOffset)	)
				tile.setScale(SCALE)
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
		
		let tileCount = gameModel.tileCount()
		let moveCount = gameModel.remainingMovesCount()
		lblTiles.text = String.localizedStringWithFormat("keyTilesRemaining".localize(), String(tileCount))
		lblRemainingMoves.text = String.localizedStringWithFormat("keyMovesRemaining".localize(), String(moveCount))
		if tileCount == 0 {
			hardResetGameModel(gameSize: gameModel.getHarderGameSize())
		} else if moveCount == 0 {
			hardResetGameModel(gameSize: gameModel.getCurrentGameSize())
		}
		
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
