//
//  ConfigViewController.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 6/22/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class ConfigViewController: UITableViewController {
    
    @IBOutlet weak var featurePoints: UISwitch!
    @IBOutlet weak var worldOrigin: UISwitch!
    @IBOutlet weak var physicsBodies: UISwitch!
    @IBOutlet weak var statistics: UISwitch!
    
    var newClass = Config()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the initial values
        
        featurePoints.isOn = newClass.isShowFeaturePoints
        worldOrigin.isOn = newClass.isShowWorldOrigin
        statistics.isOn = newClass.isShowStatistics
        physicsBodies.isOn = newClass.isShowPhysicsBodies
    }
    
}
