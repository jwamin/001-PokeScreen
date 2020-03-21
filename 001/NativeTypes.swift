//
//  NativeTypes.swift
//  001
//
//  Created by Joss Manger on 3/1/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Foundation

public struct Pokemon : Codable {
  
  var name: String
  var number: Int
  var sprite: Sprite
  
  enum CodingKeys : String, CodingKey {
    case number = "id"
    case name = "name"
    case sprite = "sprites"
  }
  
}

extension Pokemon : Hashable {
  public static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
    lhs.name == rhs.name && lhs.number == rhs.number
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(number)
  }
}

struct Sprite : Codable {
  var url: URL
  var image: Image?
  enum CodingKeys : String, CodingKey {
    case url = "front_default"
  }
}
