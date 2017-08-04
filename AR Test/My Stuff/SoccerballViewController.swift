//
//  SoccerballViewController.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/13/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class SoccerballViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var mySceneViewz: ARSCNView!
    
    override func viewDidLoad() {
        
        mySceneViewz.delegate = self
        mySceneViewz.showsStatistics = false
        let theScene = SCNScene(named: "")!
        mySceneViewz.scene = theScene
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let configuration = ARWorldTrackingSessionConfiguration()
        mySceneViewz.session.run(configuration)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        mySceneViewz.session.pause()
        
    }
    
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        
    }
    
    
}
