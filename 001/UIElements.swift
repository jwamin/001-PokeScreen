//
//  UIElements.swift
//  001
//
//  Created by Joss Manger on 3/1/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import Foundation

#if os(OSX)
import Cocoa
#else
import UIKit
#endif

class BlurViewWithDeinit : VisualEffectView {
  deinit{
    print("deinited")
  }
}
