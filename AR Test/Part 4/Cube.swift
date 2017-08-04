//
//  Cube.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/22/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

private var currentMaterialIndex: Int = 0

class Cube: SCNNode {
    
    class func currentMaterial() -> SCNMaterial {
        var materialName: String?
        switch currentMaterialIndex {
        case 0:
            materialName = "rustediron-streaks"
        case 1:
            materialName = "carvedlimestoneground"
        case 2:
            materialName = "granitesmooth"
        case 3:
            materialName = "old-textured-fabric"
        default:
            materialName = "tron"
            
        }
        
        return PBRMaterial.materialNamed(materialName!)
    }
    
    
//     func currentMaterial() -> String {
//        var materialName: String?
//        switch currentMaterialIndex {
//        case 0:
//            materialName = "rustediron-streaks-albedo.png"
//        case 1:
//            materialName = "carvedlimestoneground-albdo.png"
//        case 2:
//            materialName = "granitesmooth-albedo.png"
//        case 3:
//            materialName = "old-textured-fabric-albedo.png"
//        default:
//
//            print("k")
//        }
//
//        return materialName!
//    }
    
    func initAtPosition(_ position: SCNVector3, with material: SCNMaterial) -> Cube {
        
        
        let dimension: Float = 0.2
        let cube = SCNBox(width: CGFloat(dimension), height: CGFloat(dimension), length: CGFloat(dimension), chamferRadius: CGFloat(0))
        cube.materials = [material]
        let node = SCNNode(geometry: cube)
        // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        
        node.position = position
        addChildNode(node)
        
        return Cube.init()
    }
    
    func changeMaterial() {
        // Static, all future cubes use this to have the same material
        currentMaterialIndex = (currentMaterialIndex + 1) % 4
        childNodes.first?.geometry?.materials = [Cube.currentMaterial()]
    }
    
}
