//
//  BasketballViewController.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/12/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class BasketballViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var mySceneView: ARSCNView!
    
    override func viewDidLoad() {
        
        mySceneView.delegate = self // make sure you set the delegate to itself.
        mySceneView.showsStatistics = false // This is if you want to see FPS and stuff like that
        let scene = SCNScene(named: "art.scnassets/basketball.scn")! // I gotta figure out how to make a scn file. (creating the scene)
        mySceneView.scene = scene // Your setting the scene to the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let configuration = ARWorldTrackingSessionConfiguration() // create the session
        mySceneView.session.run(configuration) // This begins to run the session and you see the ball.
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        mySceneView.session.pause() // You paused the session and don't see it anymore.
        
    }
    
    override func didReceiveMemoryWarning() {
        
        
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
