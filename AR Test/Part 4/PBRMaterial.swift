//
//  PBRMaterial.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/22/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

private var materials = [AnyHashable: Any]()

class PBRMaterial: NSObject {
    
    convenience override init() {
        self.init()
        materials = [AnyHashable: Any]()
    }
    
    
    class func materialNamed(_ name: String) -> SCNMaterial {
        var mat: SCNMaterial? = materials[name] as? SCNMaterial
        if mat != nil {
            return mat!
        }
        
        // var theMaterialsName = PlaneThree.currentMaterial()
        var theMaterialsName = "tron"
        
        mat = SCNMaterial()
        mat?.lightingModel = SCNMaterial.LightingModel.physicallyBased
        // mat?.diffuse.contents = UIImage(named: "art.scnassets/\(name)/\(name)-albedo.png")
        mat?.diffuse.contents = UIImage(named: "art.scnassets/\(theMaterialsName)-albedo.png")
//        mat?.roughness.contents = UIImage(named: "art.scnassets/\(theMaterialsName)-roughness.png")
//        mat?.metalness.contents = UIImage(named: "art.scnassets/\(theMaterialsName)-metal.png")
//        mat?.normal.contents = UIImage(named: "art.scnassets/\(theMaterialsName)-normal.png")
        mat?.diffuse.wrapS = .repeat
        mat?.diffuse.wrapT = .repeat
//        mat?.roughness.wrapS = .repeat
//        mat?.roughness.wrapT = .repeat
//        mat?.metalness.wrapS = .repeat
//        mat?.metalness.wrapT = .repeat
//        mat?.normal.wrapS = .repeat
//        mat?.normal.wrapT = .repeat
        materials[name] = mat
        return mat!
    }
    
    
    
}
