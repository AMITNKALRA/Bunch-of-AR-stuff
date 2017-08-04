//
//  PartTwo.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/20/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import SceneKit

/*
 
 In our first hello world ARKit app we setup our project and rendered a single virtual 3D cube which would render in the real world and track as you moved around.
 In this article, we will look at extracting 3D geometry from the real world and visualizing it. Detecting geometry is very important for Augmented Reality apps because if you want to be able to feel like you are interacting with the real world you need to know that the user clicked on a table top, or is looking at the floor, or another surface to get life-like 3D interactions. Once we have the plane detection completed in this article, in a future article we will use them to place virtual objects in the real world.
 ARKit can detect horizontal planes (I suspect in the future ARKit will detect more complex 3D geometry but we will probably have to wait for a depth sensing camera for that, iPhone8 maybe…). Once we detect a plane, we will visualize it to show the scale and orientation of the plane. To see it all in action, watch the video below:
 
 
 Computer Vision Concepts
 Before we dive in to the code, it is useful to know at a high level what’s happening beneath the covers in ARKit, because this technology is not perfect and there are certain situations where it will break down and affect the performance of your app.
 The aim of Augmented Reality is to be able to insert virtual content in to the real world at specific points and have that virtual content track as you move around the real world. With ARKit the basic process for this involves reading video frames from the iOS device camera, for each frame the image is processed and feature points are extracted. Features can be many things, but you want to try to detect interesting features in the image that you can track across multiple frames. A feature may be the corner of an object or the edge of a textured piece of fabric etc. There are many ways to generate these features, you can read more on that across the web (e.g. search for SIFT) but for our purpose it’s enough to know that there are many features extracted per image which can be uniquely identified.
 Once you have the features for an image, you can then track the features across multiple frames, as the user moves around the world, you can take these corresponding points and estimate 3D pose information, such as the current camera position and the positions of the features. As the user moves around more and we get more and more features, these 3D pose estimations improve.
 For plane detection, once you have a number of feature points in 3D you can then try to fit planes to those points and find the best match in terms of scale, orientation and position. ARKit is constantly analyzing the 3D feature points and reporting all the planes it finds back to us in the code.
 Below is a screenshot from my phone looking at the arm of my sofa. As you can see the fabric has good texture, plenty of interesting and unique features that can be tracked, each cross is a unique feature found by ARKit.
 
 
 This is important because for ARKit to detect features you have to be looking at content that has lots of interesting features to detect. Things that would cause poor feature extraction are:
 Poor lighting — not enough light or too much light with shiny specular highlights. Try and avoid environments with poor lighting.
 Lack of texture — if you point your camera at a white wall there is really nothing unique to extract, ARKit won’t be able to find or track you. Try to avoid looking at areas of solid colors, shiny surfaces etc.
 Fast movement — this is subjective for ARKit, normally if you are only using images to detect and estimate 3D poses, if you move the camera too fast you will end up with blurry images that will cause tracking to fail. However ARKit uses something called Visual-Inertial Odometry so as well as the image information ARKit uses the devices motion sensors to estimate where the user has turned. This makes ARKit very robust in terms of tracking.
 In another article we will test out different environments to see how the tracking performs.
 Adding Debug Visualizations
 Before we start, it’s useful to add some debugging information to the application, namely rendering the world origin reported from ARKit and then also rendering the feature points ARKit has detected, that will be useful to let you know that you are in an area that is tracking well or not. To do this we can turn on the debug options on our ARSCNView instance
 
 Detecting plane geometry
 In ARKit you can specify that you want to detect horizontal planes by setting the planeDetection property on your session configuration object. This value can be set to either ARPlaneDetectionHorizontal or ARPlaneDetectionNone.
 Once you set that property, you will start getting callbacks to delegate methods for the ARSCNViewDelegate protocol. There are a number of methods there, the first we will use is:
 
 This method gets called each time ARKit detects what it considers to be a new plane. We get two pieces of information, node and anchor. The SCNNode instance is a SceneKit node that ARKit has created, it has some properties set like the orientation and position, then we get an anchor instance, this tells use more information about the particular anchor that has been found, such as the size and center of the plane.
 The anchor instance is actually an ARPlaneAnchor type, from that we can get the extent and center information for the plane.
 
 Rendering the plane
 With the above information we can now draw a SceneKit 3D plane in the virtual world. To do this we create a Plane class that inherits from SCNNode. In the constructor method we create the plane and size it accordingly:
 
 
 Now that we have our Plane class, back in the ARSCNViewDelegate callback method, we can create our new plane when ARKit reports a new Anchor:
 
 Updating the plane
 If you run the above code, as you walk around you will see new planes rendering in the virtual world, however the planes do not grow properly as you move around. ARKit is constantly analyzing the scene and as it finds that a Plane is bigger/smaller than it thought it updates the planes extent values. So we also need to update the Plane SceneKit is already rendering.
 We get this updated information from another ARSCNViewDelegate method:
 
 Now that we have got the plane rendering and updating, we can take a look in the app. I added a Tron style grid texture to the SCNPlane geometry, I have omitted it here but you can look in the source code.
 Extraction Results
 Below are some screen shots of the planes detected from the video above as I walked around part of my house:
 This is an island in my kitchen, ARKit did a good job finding the extents and orientating the plane correctly to match the raised surface
 
 Here is a shot looking at the floor, as you can see as you move around ARKit is constantly surfacing new planes, this is interesting because if you are developing an app, the user will first have to move around in a space before they can place content, it will be important to provide good visual clues to the user when the geometry is good enough to use.
 
 
 Recognition takeaways
 Here are some points I found from plane detection:
 Don’t expect a plane to align perfectly to a surface, as you can see from the video, planes are detected but the orientation might be off, so if you are developing an AR app that wants to get the geometry really accurate for a good effect you might be disappointed.
 Edges are not great, as well as alignment the actual extend of the planes is sometimes too small or large, don’t try to make an app that requires perfect alignment
 Tracking is really robust and fast. As you can see as I walk around the planes track to the real world really well, I’m moving the camera pretty fast and it still looks great
 I was impressed by the feature extraction, even in low light and from a distance of about 12–15 feet away ARKit still extracted some planes.
 
 
 Next
 In the next article we will use the planes to start placing 3D objects in the real world and also look more into robustification of the app.
 
 
 */

class PartTwoView: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var planes = [AnyHashable: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
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
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        // Turn on debug options to show the world origin and also render all
        // of the feature points ARKit is tracking
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        let scene = SCNScene()
        sceneView.scene = scene
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
        let plane = Plane(anchor: (anchor as? ARPlaneAnchor)!)
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
    
    func session(_ session: ARSession, didFailWithError error: Error?) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}
    

