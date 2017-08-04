//
//  PartThree.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/20/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

/*
 
 
 ARKit by Example — Part 3: Adding geometry and physics fun
 In the last article we used ARKit to detect horizontal planes in the real world, then visualized those planes. In this article we are now going to start adding virtual content to our AR experience and start interacting with the planes that were detected.
 By the end of this article we will be able to drop cubes into the world, apply realistic physics to the cubes so they interact with one another and also create mini shock waves to make the cubes fly around a bit.
 Here is a video showing the app in action, you can see how first we capture the horizontal planes, then we add some 3D cubes to interact with the scene and then finally cause some mini explosions to make the cubes jump around
 
 Hit Testing
 As you saw in the first tutorial we can insert virtual 3D content at any X,Y,Z position and it will render and track in the real world. Now that we have plane detection we want to add content that interacts with those planes. This will make the app look like there are object on top of your table, chairs, floor etc.
 In this app, when the user single taps on the screen, we perform a hit test, this involves taking the 2D screen coordinates and firing a Ray from the camera origin through the 2D screen point (which has a 3D position on the projection plane) and into the scene. If the ray intersects with any plane we get a hit result, we then take the 3D coordinate where the ray and plane intersected and place our content at that 3D position.
 The code for this is pretty simple, ARSCNView contains a hitTest method, you pass in the screen coordinates and it takes care of projecting a ray in 3D through that point from the camera origin and returning results:
 
 Given a ARHitTestResult, we can get the world coordinate where the ray/plane intersection took place and place some virtual content at that location. For this article we will just insert a simple cube, later we will make the objects look more realistic:
 
 Adding some physics
 AR is suppose to augment the real world, so in order to make our objects feel a bit more realistic, we will add some physics to give then a feeling of weight.
 As you can see in the code above we give each cube a physicsBody that indicates the to SceneKit physics engine that this geometry should be controlled by the physics engine. We then also give each plane that ARKit detects a physicsBody also so that the cubes can interact with the planes (see the Plane.m class in the github repo for more exact details).
 Stopping plane detection
 Once we have mapped our world and have a number of planes we don’t want ARKit to keep giving us new planes and potentially updating existing planes, since this may affect geometry we have already added to the world.
 In this app if the user holds down two fingers for a second then we hide all of the planes and turn off Plane detection. To do that you update the planeDetection property of the ARSession configuration and re-run the session. By default the session will maintain the same coordinate system and any anchors that were found:
 
 In the next article we will take a small step back and look at robustifying some of the code we already wrote adding some UI controls to enable/disable features. We will also play around with lighting and textures to make the inserted geometry seem more realistic.
 
 
 
 */

private var currentMaterialIndex: Int = 0

class PartThreeView: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate {
    @IBOutlet var sceneView: ARSCNView!
    
    let rawValue: Int = 0
    
    let bottom = CollisionCategory(rawValue: 1 << 0)
    let cube = CollisionCategory(rawValue: 1 << 1)
    
    var planes = [AnyHashable: Any]()
    var boxes = [Any]()
    var theCubes = [Cubes]()
    
    let bottomMaterial = SCNMaterial()
    
    let changingTheMats = materialTypes()
    
    let dimension: Float = 0.2
    
   // let cube = SCNBox(width: CGFloat(dimension), height: CGFloat(dimension), length: CGFloat(dimension), chamferRadius: CGFloat(0))
    
    let theShape = SCNBox()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    func setupScene() {
        // Setup the ARSCNViewDelegate - this gives us callbacks to handle new
        // geometry creation
        sceneView.delegate = self
        // A dictionary of all the current planes being rendered in the scene
        planes = [AnyHashable: Any]()
        // Contains a list of all the boxes rendered in the scene
        boxes = [Any]()
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        // Turn on debug options to show the world origin and also render all
        // of the feature points ARKit is tracking
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        // Add this to see bounding geometry for physics interactions
        //SCNDebugOptionShowPhysicsShapes;
        let scene = SCNScene()
        sceneView.scene = scene
        // For our physics interactions, we place a large node a couple of meters below the world
        // origin, after an explosion, if the geometry we added has fallen onto this surface which
        // is place way below all of the surfaces we would have detected via ARKit then we consider
        // this geometry to have fallen out of the world and remove it
        let bottomPlane = SCNBox(width: 1000, height: 0.5, length: 1000, chamferRadius: 0)
        let bottomMaterial = SCNMaterial()
        bottomMaterial.diffuse.contents = UIColor(white: CGFloat(1.0), alpha: CGFloat(0.0))
        bottomPlane.materials = [bottomMaterial]
        let bottomNode = SCNNode(geometry: bottomPlane)
        bottomNode.position = SCNVector3Make(0, -10, 0)
        bottomNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        bottomNode.physicsBody?.categoryBitMask = CollisionCategory.bottom.rawValue
        bottomNode.physicsBody?.contactTestBitMask = CollisionCategory.cube.rawValue
        sceneView.scene.rootNode.addChildNode(bottomNode)
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    func setupSession() {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        // Specify that we do want to track horizontal planes. Setting this will cause the ARSCNViewDelegate
        // methods to be called when scenes are detected
        configuration.planeDetection = ARWorldTrackingSessionConfiguration.PlaneDetection.horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func setupRecognizers() {
        // Single tap will insert a new piece of geometry into the scene
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(from:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Press and hold will cause an explosion causing geometry in the local vicinity of the explosion to move
        let explosionGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changingTheMat))
        explosionGestureRecognizer.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(explosionGestureRecognizer)
        let hidePlanesGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleHold))
        hidePlanesGestureRecognizer.minimumPressDuration = 1
        hidePlanesGestureRecognizer.numberOfTouchesRequired = 2
        sceneView.addGestureRecognizer(hidePlanesGestureRecognizer)
    }
    
    @objc func handleTap(from recognizer: UITapGestureRecognizer) {
        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
        let tapPoint: CGPoint = recognizer.location(in: sceneView)
        let result : [ARHitTestResult] = sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        // If the intersection ray passes through any plane geometry they will be returned, with the planes
        // ordered by distance from the camera
        if result.count == 0 {
            return
        }
        // If there are multiple hits, just pick the closest plane
        let hitResult: ARHitTestResult? = result.first
        insertName(hitResult!)
    }
    
    @objc func handleHold(from recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began {
            return
        }
        // Perform a hit test using the screen coordinates to see if the user pressed on
        // a plane.
        let holdPoint: CGPoint = recognizer.location(in: sceneView)
        let result : [ARHitTestResult] = sceneView.hitTest(holdPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        if result.count == 0 {
            return
        }
        let hitResult: ARHitTestResult? = result.first
        DispatchQueue.main.async(execute: {() -> Void in
            self.explode(hitResult!)
        })
    }
    
    @objc func handleHidePlane(from recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began {
            return
        }
        // Hide all the planes
        
        for _ in planes {
            
            let thisThing = ARWorldTrackingSessionConfiguration()
            thisThing.planeDetection = []
            
        }
        
//        for planeId: UUID in planes {
//            planes[planeId].hide()
//        }
        // Stop detecting new planes or updating existing ones.
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = []
        sceneView.session.run(configuration)
    }
    
    @objc func changingTheMat(from recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state != .began {
            return
        }
        
        let holdPoint: CGPoint = recognizer.location(in: sceneView)
        let result: [SCNHitTestResult]? = sceneView.hitTest(holdPoint, options: [SCNHitTestOption.boundingBoxOnly: true, SCNHitTestOption.firstFoundOnly: true])
        if result?.count == 0 {
            return
        }
        let hitResult: SCNHitTestResult? = result?.first
        let node: SCNNode? = hitResult?.node
        
        // We add all the geometry as children of the Plane/Cube SCNNode object, so we can
        // get the parent and see what type of geometry this is
        let parentNode: SCNNode? = node?.parent
        
        if (parentNode is PlaneTwo) {
            
            currentMaterialIndex = (currentMaterialIndex + 1) % 5
            (parentNode as? PlaneTwo)?.changeMaterial()
            
        }
        
        var material = SCNMaterial()
        let img = UIImage(named: "\(changingTheMats.gettingRandomMaterial())")
        material.diffuse.contents = img
        
        theShape.insertMaterial(material, at: 0)
        
        
    }
    
    func explode(_ hitResult: ARHitTestResult) {
        // For an explosion, we take the world position of the explosion and the position of each piece of geometry
        // in the world. We then take the distance between those two points, the closer to the explosion point the
        // geometry is the stronger the force of the explosion.
        // The hitResult will be a point on the plane, we move the explosion down a little bit below the
        // plane so that the goemetry fly upwards off the plane
        let explosionYOffset: Float = 0.1
        let position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y - explosionYOffset), Float(hitResult.worldTransform.columns.3.z))
        
        // We need to find all of the geometry affected by the explosion, ideally we would have some
        // spatial data structure like an octree to efficiently find all geometry close to the explosion
        // but since we don't have many items, we can just loop through all of the current geoemtry
        for cubeNode in boxes {
            // The distance between the explosion and the geometry
            var distance: SCNVector3 = SCNVector3Make((cubeNode as AnyObject).worldPosition.x - position.x, (cubeNode as AnyObject).worldPosition.y - position.y, (cubeNode as AnyObject).worldPosition.z - position.z)
            let len: Float = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
            // Set the maximum distance that the explosion will be felt, anything further than 2 meters from
            // the explosion will not be affected by any forces
            let maxDistance: Float = 2
            var scale: Float = max(0, (maxDistance - len))
            // Scale the force of the explosion
            scale = scale * scale * 2
            // Scale the distance vector to the appropriate scale
            distance.x = distance.x / len * scale
            distance.y = distance.y / len * scale
            distance.z = distance.z / len * scale
            // Apply a force to the geometry. We apply the force at one of the corners of the cube
            // to make it spin more, vs just at the center
            (cubeNode as! SCNNode).physicsBody?.applyForce(distance, at: SCNVector3Make(0.05, 0.05, 0.05), asImpulse: true)
        }
    }
    
    
    func insertName(_ hitResult: ARHitTestResult) {
        // Right now we just insert a simple cube, later we will improve these to be more
        // interesting and have better texture and shading
        theShape.width = CGFloat(dimension)
        theShape.height = CGFloat(dimension)
        theShape.length = CGFloat(dimension)
        theShape.chamferRadius = CGFloat(3)
        
        let material = SCNMaterial()
        let img = UIImage(named: "art.scnassets/tron-albedo.png")
        material.diffuse.contents = img
        
        theShape.insertMaterial(material, at: 0)
        
        let node = SCNNode(geometry: theShape)
        // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
        // using the physics engine
        
        let insertionYOffset: Float = 0.5
        let position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        node.position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        // setTextureScale()
        // changeMaterial()
        sceneView.scene.rootNode.addChildNode(node)
        boxes.append(node)
        
        
    }

    
    @objc func changingTheShapeMat(from recognizer: UILongPressGestureRecognizer) {
        
        if recognizer.state != .began {
            return
        }
        
        let holdPoint: CGPoint = recognizer.location(in: sceneView)
        let result: [SCNHitTestResult]? = sceneView.hitTest(holdPoint, options: [SCNHitTestOption.boundingBoxOnly: true, SCNHitTestOption.firstFoundOnly: true])
        if result?.count == 0 {
            return
        }
        let hitResult: SCNHitTestResult? = result?.first
        let node: SCNNode? = hitResult?.node
        
        // We add all the geometry as children of the Plane/Cube SCNNode object, so we can
        // get the parent and see what type of geometry this is
        let parentNode: SCNNode? = node?.parent
        
        if (parentNode is Cubes) {
            
            (parentNode as? Cubes)?.changeMaterial()
            
        }
        
    }
    
    
    // MARK: - SCNPhysicsContactDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // Here we detect a collision between pieces of geometry in the world, if one of the pieces
        // of geometry is the bottom plane it means the geometry has fallen out of the world. just remove it
        //let contactMask: CollisionCategory? = [contact.nodeA.physicsBody?.categoryBitMask, contact.nodeB.physicsBody?.categoryBitMask]
        let contactMask = [contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask]
        
       // if contactMask == [bottom as! Int, cube as! Int] { // CRASHES HAPPEN HERE!!!
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bottom.rawValue {
                contact.nodeB.removeFromParentNode()
            }
            else {
                contact.nodeA.removeFromParentNode()
            }
        }
   // }
    
    // MARK: - ARSCNViewDelegate
    /**
     Implement this to provide a custom node for the given anchor.
     
     @discussion This node will automatically be added to the scene graph.
     If this method is not implemented, a node will be automatically created.
     If nil is returned the anchor will be ignored.
     @param renderer The renderer that will render the scene.
     @param anchor The added anchor.
     @return Node that will be mapped to the anchor or nil.
     */
    //- (nullable SCNNode *)renderer:(id <SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    //  return nil;
    //}
    /**
     Called when a new node has been mapped to the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that maps to the anchor.
     @param anchor The added anchor.
     */
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !(anchor is ARPlaneAnchor) {
            return
        }
        // When a new plane is detected we create a new SceneKit plane to visualize it in 3D
        let plane = PlaneTwo(anchor: (anchor as? ARPlaneAnchor)!, isHidden: false)
        planes[anchor.identifier] = plane
        node.addChildNode(plane)
    }
    
    /**
     Called when a node has been updated with data from the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that was updated.
     @param anchor The anchor that was updated.
     */
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let plane: Plane? = (planes[anchor.identifier] as? Plane)
        if plane == nil {
            return
        }
        // When an anchor is updated we need to also update our 3D geometry too. For example
        // the width and height of the plane detection may have changed so we need to update
        // our SceneKit geometry to match that
        plane?.update((anchor as? ARPlaneAnchor)!)
    }
    
    /**
     Called when a mapped node has been removed from the scene graph for the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that was removed.
     @param anchor The anchor that was removed.
     */
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // Nodes will be removed if planes multiple individual planes that are detected to all be
        // part of a larger plane are merged.
        planes.removeValue(forKey: anchor.identifier)
    }
    
    /**
     Called when a node will be updated with data from the given anchor.
     
     @param renderer The renderer that will render the scene.
     @param node The node that will be updated.
     @param anchor The anchor that was updated.
     */
    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

