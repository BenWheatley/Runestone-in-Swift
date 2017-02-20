//
//  RunestoneTests.swift
//  RunestoneTests
//
//  Created by Ben Wheatley on 08/02/2017.
//  Copyright © 2017 Ben Wheatley. All rights reserved.
//

import XCTest
@testable import Runestone

class RunestoneTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	// Use XCTAssert and related functions to verify your tests produce the correct results.
	
    func testGameModelCreation() {
		let model: GameModel? = GameModel()
		XCTAssert(model != nil)
    }
	
	func testGameModelIsEvenSize() {
		let model = GameModel()
		XCTAssert( (model.tileCount() % 2)==0 )
	}
	
	func testGameModelHasFourOfEachTile() {
		let model = GameModel()
		// For each tile, see how many tiles match the type of this tile. Including this tile (because it matches itself) there should be four in each list
		for t in model.tiles {
			let arrayOfMatchingTiles = model.tiles.filter({$0.type == t.type})
			XCTAssert( arrayOfMatchingTiles.count == 4 )
		}
	}
	
    func testPerformanceFastSearch() {
        self.measure {
			self.commonSpeedTest(fastOrPretty: GameModel.FastOrPretty.Fast)
        }
	}
	
	func testPerformancePrettySearch() {
		self.measure {
			self.commonSpeedTest(fastOrPretty: GameModel.FastOrPretty.Pretty)
		}
	}
	
	// Many repetitions needed, as search speed varies depending on random shuffling of tiles
	func commonSpeedTest(fastOrPretty: GameModel.FastOrPretty) {
		for _ in 0..<100 {
			let model = GameModel()
			for i in 0..<model.tiles.count-1 {
				for j in i+1..<model.tiles.count {
					_ = model.route(fastOrPretty: fastOrPretty, from: model.tiles[i], to: model.tiles[j])
				}
			}
		}
	}
	
}
