//
//  _01Tests.swift
//  001Tests
//
//  Created by Joss Manger on 3/21/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import XCTest
@testable import _01

class _01Tests: XCTestCase {

  var loader: PokemonLoader!
  var images = Array<Image>()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
      loader = PokemonLoader()

      
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
      images.removeAll()
      loader = nil
      PokemonLoader.emptyCache()
    }

    func testImagesCount() {
      
      let imageLoadExpectation = XCTestExpectation()
      
      loader.loadAll { (images) in
            self.images = images
            imageLoadExpectation.fulfill()
      }
      
      wait(for: [imageLoadExpectation], timeout: 15)

      assert(self.images.count == MAX)

    }
  
  func testEmptyCache(){
    
    images.removeAll()
    
    XCTAssert(try! FileManager.default.contentsOfDirectory(at: PokemonLoader.directory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).count == 0)
    
  }

}
