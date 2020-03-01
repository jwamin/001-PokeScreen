//
//  Extensions.swift
//  001
//
//  Created by Joss Manger on 3/1/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import CoreGraphics

// MARK: Float Extension

public extension Float {
  
  /// Returns a random floating point number between 0.0 and 1.0, inclusive.
  static var random: Float {
    return Float(arc4random()) / 0xFFFFFFFF
  }
  
  /// Random float between 0 and n-1.
  ///
  /// - Parameter n:  Interval max
  /// - Returns:      Returns a random float point number between 0 and n max
  static func random(min: Float, max: Float) -> CGFloat {
    return CGFloat(Float.random * (max - min) + min)
  }
}

public extension Array {
  var randomIndex:Int{
    return Int(arc4random_uniform(UInt32(self.count)))
  }
}
