//
//  OtherPlane.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/22/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit


class PlaneTwo: SCNNode {
    var anchor: ARPlaneAnchor?
    var planeGeometry: SCNBox!
    
    let changingTheMats = materialTypes()
    
    init(anchor: ARPlaneAnchor, isHidden hidden: Bool) {
        super.init()
        self.anchor = anchor
        let width: Float = anchor.extent.x
        let length: Float = anchor.extent.z
        // Using a SCNBox and not SCNPlane to make it easy for the geometry we add to the
        // scene to interact with the plane.
        // For the physics engine to work properly give the plane some height so we get interactions
        // between the plane and the gometry we add to the scene
        let planeHeight: Float = 0.01
        planeGeometry = SCNBox(width: CGFloat(width), height: CGFloat(planeHeight), length: CGFloat(length), chamferRadius: 0)
        // Instead of just visualizing the grid as a gray plane, we will render
        // it in some Tron style colours.
        let material = SCNMaterial()
        // let img = UIImage(named: "art.scnassets/\(changingTheMats.gettingRandomMaterial())") // causes a new plane to be different every time
        let img = UIImage(named: "art.scnassets/tron-albedo.png")
        material.diffuse.contents = img
        // Since we are using a cube, we only want to render the tron grid
        // on the top face, make the other sides transparent
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: CGFloat(1.0), alpha: CGFloat(0.0))
        if hidden {
            planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
        }
        else {
            planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, material, transparentMaterial]
        }
        let planeNode = SCNNode(geometry: planeGeometry)
        // Since our plane has some height, move it down to be at the actual surface
        planeNode.position = SCNVector3Make(0, -planeHeight / 2, 0)
        // Give the plane a physics body so that items we add to the scene interact with it
        //planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(planeGeometry, options: nil))
        planeNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: planeGeometry!, options: nil))
        setTextureScale()
        addChildNode(planeNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ anchor: ARPlaneAnchor) {
        // As the user moves around the extend and location of the plane
        // may be updated. We need to update our 3D geometry to match the
        // new parameters of the plane.
        planeGeometry.width = CGFloat(anchor.extent.x)
        planeGeometry.height = CGFloat(anchor.extent.z)
        // When the plane is first created it's center is 0,0,0 and the nodes
        // transform contains the translation parameters. As the plane is updated
        // the planes translation remains the same but it's center is updated so
        // we need to update the 3D geometry position
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        let node = childNodes.first
        let newPlaneGeometry = planeGeometry
        //self.physicsBody = nil;
        // node?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: SCNGeometry(coder: planeGeometry), options: []))
        // node?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(planeGeometry, options: []))
        node?.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: newPlaneGeometry!, options: [:]))
        
        setTextureScale()
    }
    
    func setTextureScale() {
        let width: CGFloat = planeGeometry!.width
        let height: CGFloat = planeGeometry!.length
        // As the width/height of the plane updates, we want our tron grid material to
        // cover the entire plane, repeating the texture over and over. Also if the
        // grid is less than 1 unit, we don't want to squash the texture to fit, so
        // scaling updates the texture co-ordinates to crop the texture in that case
        let material: SCNMaterial? = planeGeometry?.materials[4]
        material?.diffuse.contentsTransform = SCNMatrix4MakeScale(Float(width), Float(height), Float(1))
        material?.diffuse.wrapS = .repeat
        material?.diffuse.wrapT = .repeat
    }
    
    func changeMaterial() {
        
       // var material: SCNMaterial? = PlaneThree.currentMaterial()
        var material: SCNMaterial? = SCNMaterial()
        var img = UIImage(named: "art.scnassets/\(changingTheMats.gettingRandomMaterial())")
        material?.diffuse.contents = img
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: CGFloat(1.0), alpha: CGFloat(0.0))
        if material == nil {
            material = transparentMaterial
        }
        let transform: SCNMatrix4 = planeGeometry.materials[4].diffuse.contentsTransform
        material?.diffuse.contentsTransform = transform
        material?.roughness.contentsTransform = transform
        material?.metalness.contentsTransform = transform
        material?.normal.contentsTransform = transform
        planeGeometry.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, material!, transparentMaterial]
        
        
    }
    
    func hide() {
        let transparentMaterial = SCNMaterial()
        transparentMaterial.diffuse.contents = UIColor(white: CGFloat(1.0), alpha: CGFloat(0.0))
        planeGeometry?.materials = [transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial, transparentMaterial]
    }


}
