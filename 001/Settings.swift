//
//  Settings.swift
//  001
//
//  Created by Joss Manger on 3/1/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#if os(OSX)
import Cocoa
typealias Color = NSColor
public typealias Image = NSImage
typealias ViewController = NSViewController
typealias View = NSView
typealias Rect = NSRect
typealias VisualEffectView = NSVisualEffectView
#else
import UIKit
typealias Color = UIColor
public typealias Image = UIImage
typealias ViewController = UIViewController
typealias View = UIView
typealias Rect = CGRect
typealias VisualEffectView = UIVisualEffectView
#endif

public typealias Pokedex = Set<Pokemon>

let DEBUG = false
let nodeNumber: Int = 50

let colors:[Color] = [
  Color.red,
  Color.orange,
  Color.yellow,
  Color.green,
  Color.blue,
  Color.purple
]

let MAX = 151
