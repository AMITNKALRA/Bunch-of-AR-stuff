//
//  PartFour.swift
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
 
 In this article we are going to insert more realistic looking virtual content in to the scene. We can achieve this by using more detailed models using a technique called Physically Based Rendering (PBR) and also a more accurate representation of lighting in the scene.
 To see the updates, check out the video below, instead of just plane solid boring cubes we now have added some PBR based materials that give us a much more realistic object that seems to fit into the real world, with variable lighting and reflections.
 
 
 If you haven’t read the other articles in the series, you can find a list here.
 Scene Lighting
 One of the main aims of Augmented Reality is to mix virtual content with the real world. Sometimes the content we add may be stylized and not look “real” but other times we want to insert content that looks and feels like it is part of the actual space we are interacting with.
 Intensity
 In order to achieve a high level of realism, lighting the scene is very important. Trying to model the real-world lighting as closely as possible in the virtual scene will make content you insert feel more real.
 For example, if you are in a dimly lit room and insert a 3D model which is lit using a bright light it’s going to look totally out of place and vice versa, a dimly lit 3D object in a bright room is going to feel out of place.
 
 So let’s start from the beginning and build up to higher and higher levels of realism. First, if your virtual scene has no lights, then just as in the real world all of the content will be black, there is no light to reflect of the object surfaces. If we turn off the lights in our scene and insert some cubes you will see the following result:
 
 Now we need to add some lights to our scene, in 3D graphics there are various different kinds of lights you can add to a scene:
 
 Ambient — simulates an equal amount of light hitting the object from all directions. As you can see since light hits the object equally from every direction there are no shadows.
 Directional — directional light has a direction but no source location, just imagine an infinite place emitting light from the surface.
 Omni — also known as a spot light. This is a light that has direction (like directional) but also a position. This is useful if you want to perform calculations like how intense the light is based on the distance of the geometry from the light source.
 Spot — spot light is like omni, but as well as direction and position, a spot light falls off in intensity in a cone shape, just like a spot light on your desk.
 There are some other types of lights but we don’t need to use those right now, for more info you can read the SceneKit documentation for SCNLight.
 autoenablesDefaultLighting
 SceneKit SCNView has a property called autoenablesDefaultLighting if you set this to true, SceneKit will add an Onmi directional light to the scene, located from the position of the camera and pointing in the direction of the camera, this is a good starting point and it is enabled by default on your project (that is what has been lighting all the cubes in the previous articles in this series) until you add your own light sources. A couple of problems with this easy settings are:
 The intensity of the light is always 1000 which means “normal” so again placing content in different lighting situations will not look right.
 The light has a changing direction, so as you walk around an object it will always look like the light is coming from your point of view (like you are holding a torch infront of you) which isn’t the case normally, most scenes have static lighting so your model will look unnatural as you move around.
 
 automaticallyUpdatesLighting
 ARKit’s ARSCNView has a property called automaticallyUpdatesLighting which the documentation says will automatically add lights to the scene based on the estimated light intensity. Sounds great, but as far as I can tell it does nothing, setting this in various combinations with other properties didn’t seem to do anything, not sure if it is a bug in this release of the SDK or if I am doing something wrong (more likely), but it doesn’t matter since we can get estimated lighting another way which we will do now.
 lightEstimationEnabled
 The ARSessionConfiguration class has a lightEstimationEnabled property, setting this to true, inside every captured ARFrame, we will get a lightEstimate value that we can use to render the scene.
 With this information we can take the lightEstimate every frame and modify the intensity of the lights in our scene to mimic the ambient light intensity of the real world scene which helps the too bright/ too dim issue mentioned above.
 Lighting
 First let’s add a light to the scene, we will add a spot light that is pointing directly down and insert it into the scene a few meters above the origin. This roughly simulates the environment I am in making the videos in my house where I have spot lights in the ceiling. To add a spot light you:
 
 As well as a spot light we also add an ambient light, this is because in the real world there are usually multiple light sources and light bouncing off wall and other physical objects that provide light to all sides of an object. The process is similar to above, I’ll omit it from here. When we do this we can now insert a piece of geometry and have it feel more like it is actually part of the scene.
 Light Estimation
 Finally, we mentioned lightEstimation, ARKit can analyze the scene and estimate the ambient light intensity. It will returns a value, 1000 representing “neutral” values below that are darker and values above are brighter. To enable light estimation, you need to set the lightEstimationEnabled property to true in your scene configuration:
 
 Once you do this, you can then implement the following method in the ARSCNViewDelegate protocol and modify the intensity of the spot light and ambient light we added to the scene:
 
 Now this is very cool, watch the video below, you can see how when I dim down the lights in my house the virtual cube also gets darker as the virtual lights are dimmed! Then it gets brighter as the lights get brighter.
 
 The takeaway from this is that getting the lighting to match the real world is tricky, but we have a useful blunt tool in the form of lighting estimation that can help us with some realism. I think the general guideline here is that ideally you make sure your users are using your app in a well lit environment that has consistent lighting that can be modeled easily.
 Physically Based Rendering
 Ok, so we have the concept of basic lighting, we will throw 99% of that away :) Instead of trying to add lights to our scene and handle the complexity, we are going to keep the lighting estimation functionality but texture our geometry using a technique called Physically Based Rendering.
 Some examples of objects rendered using this technique are shown below:
 
 I’m not going to try to explain all the details of this process in this article because there are many excellent resources, but the basic concept is that when you texture your object you provide information that includes:
 Albedo — this is the base color of the model. It maps to the diffuse component of your material, it is the material texture without any baked in lighting or shadow information.
 Roughness — describes how rough the material will be, the rougher surfaces show dimmer reflections, smoother materials show brighter specular reflections.
 Metalness — a rough equivalent to how shiny a material will be.
 See https://www.marmoset.co/posts/tag/pbr/page/5/ for a much more detailed explanation.
 For our purposes we just want to render our cubes and planes with more realism, for that I grabbed some textures from http://freepbr.com/ and rendered the materials using them:
 
 You need to set the lightingModelName of the material to SCNLightingModelPhysicallyBased and set the various material types.
 The final important part is that you have to tell your SCNScene you are using PBR lighting, when you do this the light source for the scene actually comes from an image you specify, for example I used this image:
 
 So the lighting of your geometry is taken from this image, think of the image being projected all around the geometry as a background then SceneKit is using this background to figure out how the geometry is being lit.
 
 
 The final part is taking the light estimation value we get from ARKit and applying it to the intensity of this environment image. ARKit returns a value of 1000 to represent neutral lighting, so less that that is darker and more is brighter. The lighting environment value takes a value of 1.0 for neutral, so we need to scale the value we get from ARKit:
 
 
 UI Improvements
 I changed the UI so now if you press and hold with a single finger on a plane, it will change the material, same for the cubes, press and hold to change the material of the cube. Press and hold with two fingers to cause an explosion.
 I also added a toggle to stop plane detection once you are happy with the planes you have found, and a settings screen to turn on/off various debug items.
 As always, you can find the code for this project here: https://github.com/markdaws/arkit-by-example
 Next
 So far we wrote the app assuming the happy path, that nothing will go wrong, but in the real world especially with tracking we know that is not always the case. There are a number of scenarios we need to handle when it comes to ARKit to make our app more robust, in the next article we will take a step back and handle the error and degradation cases.
 
 
 
 */

class PartFourView: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, SCNPhysicsContactDelegate {
    
    var planes = [UUID: PlaneThree]()
    var cubes = [Cube]()
    var config: Config?
    var arConfig: ARWorldTrackingSessionConfiguration?
    
    let rawValue: Int = 0
    
    let bottom = CollisionCategory(rawValue: 1 << 0)
    let cube = CollisionCategory(rawValue: 1 << 1)
    
    let bottomMaterial = SCNMaterial()
    var boxes = [Any]()
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupLights()
        setupPhysics()
        setupRecognizers()
        // Create a ARSession confi object we can re-use
        arConfig = ARWorldTrackingSessionConfiguration()
        arConfig?.isLightEstimationEnabled = true
        arConfig?.planeDetection = ARWorldTrackingSessionConfiguration.PlaneDetection.horizontal
        let config = Config()
        config.isShowStatistics = false
        config.isShowWorldOrigin = true
        config.isShowFeaturePoints = true
        config.isShowPhysicsBodies = false
        config.isDetectPlanes = true
        self.config = config
        updateConfig()
        // Stop the screen from dimming while we are using the app
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // Run the view's session
        sceneView.session.run(arConfig!)
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
        planes = [AnyHashable: Any]() as! [UUID : PlaneThree]
        // A list of all the cubes being rendered in the scene
        cubes = [Any]() as! [Cube]
        // Make things look pretty :)
        sceneView.antialiasingMode = .multisampling4X
        // This is the object that we add all of our geometry to, if you want
        // to render something you need to add it here
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    func setupPhysics() {
        // For our physics interactions, we place a large node a couple of meters below the world
        // origin, after an explosion, if the geometry we added has fallen onto this surface which
        // is place way below all of the surfaces we would have detected via ARKit then we consider
        // this geometry to have fallen out of the world and remove it
        let bottomPlane = SCNBox(width: 1000, height: 0.5, length: 1000, chamferRadius: 0)
        
        // Make it transparent so you can't see it
        bottomMaterial.diffuse.contents = UIColor(white: CGFloat(1.0), alpha: CGFloat(0.0))
        bottomPlane.materials = [bottomMaterial]
        let bottomNode = SCNNode(geometry: bottomPlane)
        // Place it way below the world origin to catch all falling cubes
        bottomNode.position = SCNVector3Make(0, -10, 0)
        bottomNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        bottomNode.physicsBody?.categoryBitMask = CollisionCategory.bottom.rawValue
        bottomNode.physicsBody?.contactTestBitMask = CollisionCategory.cube.rawValue
        let scene: SCNScene? = sceneView.scene
        scene?.rootNode.addChildNode(bottomNode)
        scene?.physicsWorld.contactDelegate = self
    }
    
    func setupLights() {
        // Turn off all the default lights SceneKit adds since we are handling it ourselves
        sceneView.autoenablesDefaultLighting = false
        sceneView.automaticallyUpdatesLighting = false
        let env = UIImage(named: "art.scnassets/Environment/spherical.jpg")
        sceneView.scene.lightingEnvironment.contents = env
        //TODO: wantsHdr
    }
    
    func setupRecognizers() {
        // Single tap will insert a new piece of geometry into the scene
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.placingCubes))
        tapGestureRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        // Press and hold will open a config menu for the selected geometry
        let materialGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changingTheMats))
        materialGestureRecognizer.minimumPressDuration = 0.5
        sceneView.addGestureRecognizer(materialGestureRecognizer)
        // Press and hold with two fingers causes an explosion
        let explodeGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.explodeTheCubes))
        explodeGestureRecognizer.minimumPressDuration = 1
        explodeGestureRecognizer.numberOfTouchesRequired = 2
        sceneView.addGestureRecognizer(explodeGestureRecognizer)
    }
    
    
    @objc func placingCubes(from recognizer: UITapGestureRecognizer) {
        // Take the screen space tap coordinates and pass them to the hitTest method on the ARSCNView instance
        let tapPoint: CGPoint = recognizer.location(in: sceneView)
        let result: [ARHitTestResult] = sceneView.hitTest(tapPoint, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        // If the intersection ray passes through any plane geometry they will be returned, with the planes
        // ordered by distance from the camera
        if result.count == 0 {
            return
        }
        // If there are multiple hits, just pick the closest plane
        let hitResult: ARHitTestResult? = result.first
        insertCube(hitResult!)
    } // come back
    
    @objc func explodeTheCubes(from recognizer: UILongPressGestureRecognizer) {
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

    
    @objc func changingTheMats(from recognizer: UILongPressGestureRecognizer) {
        if recognizer.state != .began {
            return
        }
        // Perform a hit test using the screen coordinates to see if the user pressed on
        // any 3D geometry in the scene, if so we will open a config menu for that
        // geometry to customize the appearance
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
        
        if (parentNode is PlaneThree) {
            
            (parentNode as? PlaneThree)?.changeMaterial()
            
        }
        
        if (parentNode is Cube) {
            
            (parentNode as? Cube)?.changeMaterial()
            
        }
        
        
    }
    
    func hidePlanes() {
        
        for _ in planes {
            
            let thisThing = ARWorldTrackingSessionConfiguration()
            thisThing.planeDetection = []
            
            
        }
    }
    
    func disableTracking(_ disabled: Bool) {
        // Stop detecting new planes or updating existing ones.
        if disabled {
            arConfig?.planeDetection = []
        }
        else {
            arConfig?.planeDetection = ARWorldTrackingSessionConfiguration.PlaneDetection.horizontal
        }
        sceneView.session.run(arConfig!)
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
        for cubeNode: SCNNode in cubes {
            // The distance between the explosion and the geometry
            var distance: SCNVector3 = SCNVector3Make((cubeNode as AnyObject).worldPosition.x - position.x, (cubeNode as AnyObject).worldPosition.y - position.y, (cubeNode as AnyObject).worldPosition.z - position.z)
            let len: Float = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
            // Set the maximum distance that the explosion will be felt, anything further than 2 meters from
            // the explosion will not be affected by any forces
            let maxDistance: Float = 2
            var scale: Float = max(0, (maxDistance - len))
            // Scale the force of the explosion
            scale = scale * scale * 5
            // Scale the distance vector to the appropriate scale
            distance.x = distance.x / len * scale
            distance.y = distance.y / len * scale
            distance.z = distance.z / len * scale
            // Apply a force to the geometry. We apply the force at one of the corners of the cube
            // to make it spin more, vs just at the center
            cubeNode.physicsBody?.applyForce(distance, at: SCNVector3Make(0.05, 0.05, 0.05), asImpulse: true)
        }
    }
    
    @objc func insertShape(_ hitResult: ARHitTestResult) {
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
        // using the physics engine
        let insertionYOffset: Float = 0.5
        let position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        let cube = Cube().initAtPosition(position, with: bottomMaterial)
        cubes.append(cube)
        sceneView.scene.rootNode.addChildNode(cube)
        
        
        print("will check when i wake up if this is even working???")
    }
    
    func insertCube(_ hitResult: ARHitTestResult) {
        
        // Right now we just insert a simple cube, later we will improve these to be more
        // interesting and have better texture and shading
        let dimension: Float = 0.1
        let cube = SCNBox(width: CGFloat(dimension), height: CGFloat(dimension), length: CGFloat(dimension), chamferRadius: CGFloat(0))
        let node = SCNNode(geometry: cube)
        // The physicsBody tells SceneKit this geometry should be manipulated by the physics engine
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.mass = 2.0
        node.physicsBody?.categoryBitMask = CollisionCategory.cube.rawValue
        // We insert the geometry slightly above the point the user tapped, so that it drops onto the plane
        // using the physics engine
        let insertionYOffset: Float = 0.5
        node.position = SCNVector3Make(Float(hitResult.worldTransform.columns.3.x), Float(hitResult.worldTransform.columns.3.y + insertionYOffset), Float(hitResult.worldTransform.columns.3.z))
        sceneView.scene.rootNode.addChildNode(node)
        boxes.append(node)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Called just before we transition to the config screen
        let configController: ConfigViewController? = (segue.destination as? ConfigViewController)
        // NOTE: I am using a popover so that we do't get the viewWillAppear method called when
        // we close the popover, if that gets called (like if you did a modal settings page), then
        // the session configuration is updated and we lose tracking. By default it shouldn't but
        // it still seems to.
        configController?.modalPresentationStyle = .popover
        configController?.popoverPresentationController?.delegate = self
        configController?.newClass = config!
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .popover
    }
    
    @IBAction func settingsUnwind(_ segue: UIStoryboardSegue) {
        // Called after we navigate back from the config screen
        let configView: ConfigViewController? = (segue.source as? ConfigViewController)
        let config: Config? = self.config
        
        config?.isShowPhysicsBodies = ((configView?.physicsBodies.onImage) != nil)
        config?.isShowFeaturePoints = ((configView?.featurePoints.onImage) != nil)
        config?.isShowWorldOrigin = ((configView?.worldOrigin.onImage) != nil)
        config?.isShowStatistics = ((configView?.statistics.onImage) != nil)
        
        updateConfig()
    }
    
    @IBAction func detectPlanesChanged(_ sender: Any) {
        let enabled: Bool? = (sender as? UISwitch)?.isOn
        if enabled == config?.isDetectPlanes {
            return
        }
        config?.isDetectPlanes = enabled!
        if enabled != nil {
            disableTracking(false)
        }
        else {
            disableTracking(true)
        }
    }
    
    func updateConfig() {
        var opts: SCNDebugOptions = SCNDebugOptions()
        let config: Config? = self.config
        if (config?.isShowWorldOrigin)! {
            opts = ARSCNDebugOptions.showWorldOrigin
        }
        if (config?.isShowFeaturePoints)! {
            opts = ARSCNDebugOptions.showFeaturePoints
        }
        if (config?.isShowPhysicsBodies)! {
            opts = SCNDebugOptions.showPhysicsShapes
        }
        sceneView.debugOptions = opts
        if (config?.isShowStatistics)! {
            sceneView.showsStatistics = true
        }
        else {
            sceneView.showsStatistics = false
        }
    }
    
    // MARK: - SCNPhysicsContactDelegate
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        // Here we detect a collision between pieces of geometry in the world, if one of the pieces
        // of geometry is the bottom plane it means the geometry has fallen out of the world. just remove it
        let contactMask = [contact.nodeA.physicsBody!.categoryBitMask, contact.nodeB.physicsBody!.categoryBitMask]
//        if contactMask == [bottom as! Int, cube as! Int] {
            if contact.nodeA.physicsBody?.categoryBitMask == CollisionCategory.bottom.rawValue {
                contact.nodeB.removeFromParentNode()
            }
            else {
                contact.nodeA.removeFromParentNode()
            }
        }
//    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let estimate: ARLightEstimate? = sceneView.session.currentFrame?.lightEstimate
        if estimate == nil {
            return
        }
        // A value of 1000 is considered neutral, lighting environment intensity normalizes
        // 1.0 to neutral so we need to scale the ambientIntensity value
        let intensity: CGFloat? = (estimate?.ambientIntensity)! / 1000.0
        sceneView.scene.lightingEnvironment.intensity = intensity!
    }
    
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
        let plane = PlaneThree(anchor: (anchor as? ARPlaneAnchor)!, isHidden: false, with: PlaneThree.currentMaterial())
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
