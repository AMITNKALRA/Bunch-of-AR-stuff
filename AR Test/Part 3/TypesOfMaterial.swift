//
//  TypesOfMaterial.swift
//  AR Test
//
//  Created by Amit Nivedan Kalra on 7/10/17.
//  Copyright © 2017 Amit Nivedan Kalra. All rights reserved.
//

import Foundation


struct materialTypes {
    
    let theList = ["Hay"] /// ["tron-albedo.png", "oakfloor2-albedo.png", "sculptedfloorboards-albedo.png", "granitesmooth-albedo.png", "rustediron-streaks-albedo.png", "carvedlimestoneground-albedo.png", "old-textured-fabric-albedo.png"]
    
    
    func gettingRandomMaterial() -> String {
        
        
        let firstPart = UInt32(theList.count)
        let secondPart = arc4random_uniform(firstPart)
        let thirdPart = Int(secondPart)
        
        
        return theList[thirdPart]
        
        
    }
    
    
}
