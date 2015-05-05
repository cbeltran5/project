//
//  SpacemenController.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 4/26/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

class SpacemenController {

    private struct Spaceman {
        var state: Int              // IDLE | DIG | WELD | WRENCH
        var position: CGPoint       //
        var anchorPoint: CGPoint    //
        var scale: CGFloat          //
        var xScale: CGFloat         //
    }
    
    var planet: String!
    var base: PlanetBase!
    var scale: CGFloat!
    var spacemenFrames = [String: [SKTexture]]()
    
    init(planet: String, base: PlanetBase, scale: CGFloat) {
        self.planet = planet
        self.base = base
        self.scale = scale
        
        var digAtlas = SKTextureAtlas(named: "spaceman-1.atlas")
        var idleAtlas = SKTextureAtlas(named: "spaceman-0.atlas")
        var weldAtlas = SKTextureAtlas(named: "spaceman-2.atlas")
        var wrenchAtlas = SKTextureAtlas(named: "spaceman-3.atlas")
        
        // Initialize all the texture frames that we'll need to animate the spacemen
        for index in 0...3 {
            var atlas:SKTextureAtlas
            var title:String
            switch index {
            case 0:
                title = "idle-"
                atlas = idleAtlas
            case 1:
                title = "digging-"
                atlas = digAtlas
            case 2:
                title = "welding-"
                atlas = weldAtlas
            default:
                title = "wrench-"
                atlas = wrenchAtlas
            }
            
            var framesArray: [SKTexture] = []
            for index in 0...(atlas.textureNames.count/2)-1 {
                var string = title + "\(index+1)"
                
                framesArray.append(atlas.textureNamed(string))
            }
            
            var key = "spaceman-\(index)"
            spacemenFrames[key] = framesArray
        }
    }
    
    // One enormous function to create and add spacemen with pre-determined positions to the scene :c
    func addSpacemen() {
        
        switch planet {
            case "firstPlanet":
                var spacemen = getFirstPlanetData()
                putOnScreen(&spacemen)
            case "secondPlanet":
                var spacemen = []
            
            default:
                var spacemen = []
        }
    }
    
    private func putOnScreen(inout spacemen: [Spaceman]) {
        var amount = spacemen.count / 3
        var atLeast = UInt32(spacemen.count - Int(amount))
        
        var total = Int(arc4random_uniform(atLeast)) + amount
        spacemen.shuffle()
        
        for index in 0...spacemen.count - 1 { //total-1 {
            var spaceman = spacemen[index]
            var type = "spaceman-\(spaceman.state)"
            var node = SKSpriteNode(texture: spacemenFrames[type]![0])
            node.xScale = spaceman.xScale
            node.anchorPoint = spaceman.anchorPoint
            node.position = spaceman.position
            node.setScale(scale + 0.3)
            node.zPosition = 30
            node.runAction(SKAction.repeatActionForever(SKAction.animateWithTextures(spacemenFrames[type]!, timePerFrame: 0.2, resize: false, restore: false)))
            base.parentScene.addChild(node)
            println("Spaceman-\(spaceman.state), position:\(spaceman.position), xScale:\(spaceman.xScale)")
        }
        
    }
    
    private func getFirstPlanetData() -> [Spaceman] {
        
        var reversed:CGFloat = -1
        var not_reversed: CGFloat = 1
        
        var dig_or_idle1 = Int(arc4random_uniform(2))
        var dig_or_idle2 = Int(arc4random_uniform(2))
        var dig_or_idle3 = Int(arc4random_uniform(2))
        var weld_or_wrench = Int(arc4random_uniform(2)) + 2
        var weld_or_wrench2 = Int(arc4random_uniform(2)) + 2
        var weld_or_wrench3 = Int(arc4random_uniform(2)) + 2
        var weld_or_wrench4: Int
        
        if base.hangarNumber == 0 || base.hangarNumber == 1 {
            weld_or_wrench4 = 0
        }
        else {
            weld_or_wrench4 = Int(arc4random_uniform(2)) + 2
        }
        
        var spacemen =
            [Spaceman(state: dig_or_idle1, position: CGPointMake(base.hangar.position.x, base.dome.position.y), anchorPoint: CGPointMake(0.5, 0), scale: scale, xScale: not_reversed),
            Spaceman(state: dig_or_idle2, position: CGPointMake(base.lab.position.x, base.ground_road.size.height/2), anchorPoint: CGPointMake(0, 0), scale: scale, xScale: reversed),
            Spaceman(state: dig_or_idle3, position: CGPointMake(base.lab.position.x + base.lab.size.width/2, base.dome.position.y + 5), anchorPoint: CGPointMake(1, 1), scale: scale, xScale: not_reversed),
            Spaceman(state: weld_or_wrench4, position: CGPointMake(base.leftBoxes.position.x - base.leftBoxes.frame.size.width/2, base.rightBoxes.position.y +  base.rightBoxes.size.height/2), anchorPoint: CGPointMake(1,0), scale: scale, xScale: not_reversed),
            Spaceman(state: weld_or_wrench, position: CGPointMake(base.dome.position.x - base.dome.size.width/4, base.lab.position.y - base.lab.frame.size.height/2 + base._offset/4), anchorPoint: CGPointMake(1, 1), scale: scale, xScale: reversed),
            Spaceman(state: 0, position: CGPointMake(base.ground_road.position.x + base.dome.size.width/2, base.dome.position.y - base.dome.frame.size.height/2), anchorPoint: CGPointMake(0, 0.5), scale: scale, xScale: reversed),
            Spaceman(state: weld_or_wrench3, position: CGPointMake(base.ground_road.position.x - base.dome.size.width/2, base.dome.position.y - base.dome.size.height/2 + base._offset/2), anchorPoint: CGPointMake(0.5, 0.5), scale: scale, xScale: reversed),
            Spaceman(state: 0, position: CGPointMake(base.ground_road.position.x - base.dome.frame.size.width/4, base.rightBoxes.position.y + base.rightBoxes.size.height/2), anchorPoint: CGPointMake(1, 0), scale: scale, xScale: not_reversed)]
        
        return spacemen
    }
    
}