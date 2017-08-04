//
//  PartOne.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/20/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

class PartOneView: UIViewController, ARSCNViewDelegate {
    
    /*
     ARKit core classes
    ARSCNView — a helper view that helps augment the real-time camera view with 3D content rendered by SceneKit. There are a couple of things this class does:
    Renders a live video stream from your device camera in the view as a background to your 3D scene
    The 3D coordinate system of ARKit matches the 3D coordinate system of SceneKit, so object rendered in this view will automatically match the augmented ARKit world view
    Automatically moves the virtual SceneKit 3D camera to match the 3D position tracked by ARKit, so there is no extra code needed to hook up the ARKit movement events to map to the SceneKit 3D rendering.
    ARSession — every Augmented Reality session requires an ARSession instance. It is responsible for controlling the camera, gathering all of the sensor data from the device etc to build this seamless experience. The ARSCNView instance already has an ARSession instance, you just need to configure it at startup.
    ARWorldTrackingSessionConfiguration — this class indicates to the ARSession that we want to use six degrees of freedom for tracking the user in the real world, roll, pitch, yaw and translation in X, Y and Z. This allows us to create AR experiences where you can not only rotate in the same spot to see augmented content, but also move around object in the 3D space. If you don’t need the translation part and the user will stay still as you project augmented content, you can use the ARSessionConfiguration class instead to initialize the ARSession instance.
    For part 1 of this series we only need these classes, there are many more but this is a good starting point. Going back to our project, we can see in the viewWillAppear method that the ARSession instance is initialized, the self.sceneView refers to a ARSCNView instance.
     */
    
    /*
 
     Drawing the Cube
     We are going to draw a 3D Cube using SceneKit. SceneKit has a couple of basic classes, SCNScene is a container for all your 3D content, you can add multiple pieces of 3D geometry to the scene, in various positions, rotations, scales etc.
     To add content to a scene, you first create some Geometry, geometry can be complex shapes, or simple ones like sphere, cube, plane etc. You then wrap the geometry in a scene node and add it to the scene. SceneKit will then traverse the scene graph and render the content.
     To add a scene and draw a cube we would add the following code inside the viewDidLoad method:
 
     
     
     
     The coordinates in ARKit roughly correspond to meters, so in this case we are creating a 10x10x10 centimeter box.
     The coordinate system for ARKit and SceneKit looks like the following:
     
     As you can see in the code code above the position the camera -0.5 units infront of the camera, since the camera faces in the negative Z direction.
     When the ARSession starts up the calculated camera position is initially set as X=0, Y=0, Z=0.
     If you now run the sample, you should see a small 3D cube floating in space that maintains it’s position when you move around, you should be able to walk all the way around, look under, above it.
     One quick tweak we will want to make is to add some default lighting in the 3D scene so that we can see the sides of the cubes, we can add some more advanced lighting later but for now we can just set the autoenablesDefaultLighting on the SCNScene instance:
     
 
     
     In the next vide we will start making our app a bit more interesting, adding some more complex objects, detecting planes in the scene and interacting with geometry in the scene, stay tuned …
 
 
 */
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
        
        let myScene = SCNScene() // Container to hold all of the 3D geometry
        
        sceneView.scene = myScene // Set the scene to the view
        
        
        let boxGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0) // The 3D cube geometry we want to draw
        
        let boxNode = SCNNode(geometry: boxGeometry) // The node that wraps the geometry so we can add it to the scene
        
        boxNode.position = SCNVector3Make(0, 0, -0.5) // Position the box just in front of the camera
        myScene.rootNode.addChildNode(boxNode) // rootNode is a special node, it is the starting point of all
        // the items in the 3D scene
        
        self.sceneView.autoenablesDefaultLighting = true
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let config = ARWorldTrackingSessionConfiguration() // Create a session configuration
        
        self.sceneView.session.run(config)  // Run the view's session
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.sceneView.session.pause()
        
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    
}
