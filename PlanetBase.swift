//
//  PlanetBase.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 4/11/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

// As the player makes progress on the planet, the buildings are built
class PlanetBase {
    
    var dome:SKSpriteNode!
    var lab: SKSpriteNode!
    var hangar: SKSpriteNode!
    var ground_road: SKSpriteNode!
    var leftBoxes: SKSpriteNode!
    var topBoxes: SKSpriteNode!
    var rightBoxes: SKSpriteNode!
    
    var baseStates: [String: Int]?
    var _scale: CGFloat!
    var _offset:CGFloat!
    
    var domeNumber:Int!
    var hangarNumber:Int!
    var labNumber:Int!
    var numberArray:[Int] = []
    
    var parentScene:GameScene!
    
    init(base_states: [String: Int], scene: GameScene) {
        self.baseStates = base_states
        self.parentScene = scene
    }
    
    // Adds all the buildings for the base, as well as the boxes
    func initBase(scale: CGFloat) {
        domeNumber = baseStates!["dome-"]
        var domeString = "dome-" + "\(domeNumber!)"
        var domeTexture:SKTexture?
        
        domeTexture = SKTexture(imageNamed: domeString)
        
        hangarNumber = baseStates!["hangar-"]
        var hangarString = "hangar-" + "\(hangarNumber!)"
        var hangarTexture:SKTexture?
        
        hangarTexture = SKTexture(imageNamed: hangarString)
        
        labNumber = baseStates!["lab-"]
        var labString = "lab-" + "\(labNumber!)"
        var labTexture: SKTexture?
        
        labTexture = SKTexture(imageNamed: labString)
        
        var leftBoxesString = "leftBoxes-\(parentScene.gameData.currentPlanet!)"
        var topBoxesString = "topBoxes-\(parentScene.gameData.currentPlanet!)"
        var rightBoxesString = "rightBoxes-\(parentScene.gameData.currentPlanet!)"
        
        var leftBoxesTexture = SKTexture(imageNamed: leftBoxesString)
        var topBoxesTexture = SKTexture(imageNamed: topBoxesString)
        var rightBoxesTexture = SKTexture(imageNamed: rightBoxesString)
        
        ground_road = SKSpriteNode(imageNamed: "planet_ground")
        ground_road.anchorPoint = CGPointMake(0.5, 0)
        
        if scale != 0.81 {
            _offset = ground_road.size.height * 0.13
        }
        else {
            _offset = ground_road.size.height * 0.1
        }
        
        ground_road.setScale(scale)
        ground_road.position = CGPointMake(parentScene.frame.midX, _offset)
        ground_road.zPosition = -2
        parentScene.addChild(ground_road)
        
        dome = SKSpriteNode(texture: domeTexture)
        dome.setScale(scale)
        dome.zPosition = 20
        dome.position = CGPointMake(ground_road.position.x + 1, ground_road.size.height/2 - (ground_road.size.height * 0.22) + _offset)
        parentScene.addChild(dome)
        
        lab = SKSpriteNode(texture: labTexture)
        lab.setScale(scale)
        lab.zPosition = 20
        lab.position = CGPointMake(ground_road.position.x + (ground_road.size.width * 0.36), ground_road.size.height/2 + (ground_road.size.height * 0.35) + _offset)
        parentScene.addChild(lab)
        
        hangar = SKSpriteNode(texture: hangarTexture)
        hangar.setScale(scale)
        hangar.zPosition = 20
        hangar.position = CGPointMake(ground_road.position.x - (ground_road.size.width * 0.33), ground_road.size.height/2 + (ground_road.size.height * 0.44) + _offset)
        parentScene.addChild(hangar)
        
        leftBoxes = SKSpriteNode(texture: leftBoxesTexture)
        leftBoxes.setScale(scale)
        leftBoxes.zPosition = 25
        
        topBoxes = SKSpriteNode(texture: topBoxesTexture)
        topBoxes.setScale(scale)
        topBoxes.zPosition = 25

        rightBoxes = SKSpriteNode(texture: rightBoxesTexture)
        rightBoxes.setScale(scale)
        rightBoxes.zPosition = 25

        switch parentScene.gameData.currentPlanet! {
            case "firstPlanet":
                leftBoxes.position = CGPointMake(hangar.position.x + 10, dome.position.y + 10)
                topBoxes.position = CGPointMake(ground_road.position.x, lab.position.y)
                rightBoxes.anchorPoint = CGPointMake(0, 0)
                rightBoxes.position = CGPointMake(lab.position.x + 5, dome.position.y + _offset)
            default:
                println("Error")
            
        }
        /*
        parentScene.addChild(leftBoxes)
        parentScene.addChild(rightBoxes)
        parentScene.addChild(topBoxes)
        */
        // Temporary solution
        numberArray.append(domeNumber)
        numberArray.append(hangarNumber)
        numberArray.append(labNumber)
    }
    
    // Sets up the spacemen based on what planet this is
    func initSpacemen(scale: CGFloat) {
        var controller = SpacemenController(planet: parentScene.gameData.currentPlanet!, base: self, scale: scale)
        //controller.addSpacemen()
    }
    
    // Return the position the platform should be in
    func getCorrectPosition() -> CGPoint {
        return CGPointMake(parentScene.frame.midX + ground_road.size.width * 0.007, (ground_road.frame.height/2) + (ground_road.size.height * 0.3) + _offset)
    }
    
    // For every 10%, a new sprite is chosen for each building, or some buildings
    func update(inout baseStatesDictionary: [String: Int]) {
        var rand:Int!
        
        do {
            rand = Int(arc4random_uniform(3))
        } while numberArray[rand] == 4
        
        switch rand {
        case 0:
            var string = "dome-\((++numberArray[0]))"
            dome.texture = SKTexture(imageNamed: string)
            baseStatesDictionary.updateValue((numberArray[0]), forKey: "dome-")
        case 1:
            var string = "hangar-\(++(numberArray[1]))"
            hangar.texture = SKTexture(imageNamed: string)
            baseStatesDictionary.updateValue((numberArray[1]), forKey: "hangar-")
        default:
            var string = "lab-\((++numberArray[2]))"
            lab.texture = SKTexture(imageNamed: string)
            baseStatesDictionary.updateValue((numberArray[2]), forKey: "lab-")
        }
        
        // TODO: Provide a way to just save the new planet data, NOT everything
        //var ret = parentScene!.saveGameData()
        //println("Saved? \(ret)")
    }
    
}