//
//  CollisionCategory.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/22/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let bottom = CollisionCategory(rawValue: 1 << 0)
    static let cube = CollisionCategory(rawValue: 1 << 1)
}
