//
//  InsertingCubes.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 7/10/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

private var currentMaterialIndex: Int = 0

class Cubes: SCNNode {
    
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
    
    
    func initAtPosition(_ position: SCNVector3, with material: SCNMaterial, _ hitResult: ARHitTestResult) -> Cubes {
        
        // let hitResult = ARHitTestResult()
        
        // Right now we just insert a simple cube, later we will improve these to be more
        // interesting and have better texture and shading
        let dimension: Float = 0.2
        let cube = SCNBox(width: CGFloat(dimension), height: CGFloat(dimension), length: CGFloat(dimension), chamferRadius: CGFloat(0))
        let node = SCNNode(geometry: cube)
        // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
        // using the physics engine
        let insertionYOffset: Float = 0.5
        let position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        node.position = position
        addChildNode(node)
        
        return Cubes.init()
    }
    
    func insertTheName(_ hitResult: ARHitTestResult) {
        // Right now we just insert a simple cube, later we will improve these to be more
        // interesting and have better texture and shading
        let dimension: Float = 0.2
        let cube = SCNBox(width: CGFloat(dimension), height: CGFloat(dimension), length: CGFloat(dimension), chamferRadius: CGFloat(0))
        let node = SCNNode(geometry: cube)
        // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
        // using the physics engine
        let insertionYOffset: Float = 0.5
        let position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        node.position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        //sceneView.scene.rootNode.addChildNode(node)
        //boxes.append(node)
        
    }
    
    func changeMaterial() {
        // Static, all future cubes use this to have the same material
        currentMaterialIndex = (currentMaterialIndex + 1) % 4
        childNodes.first?.geometry?.materials = [Cubes.currentMaterial()]
    }
}
