//
//  PenguinViewController.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/13/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class PenguinViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var penguinSceneView: ARSCNView!
    
    override func viewDidLoad() {
        
        penguinSceneView.delegate = self
        penguinSceneView.showsStatistics = false
        
        let myScene = SCNScene(named: "art.scnassets/Penguin.scn")!
        
        penguinSceneView.scene = myScene
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let congif = ARWorldTrackingSessionConfiguration()
        
        penguinSceneView.session.run(congif)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        penguinSceneView.session.pause()
        
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        
    }
    
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        
    }
    
    
    func sessionWasInterrupted(_ session: ARSession) {
        
        
    }
    
    
}
