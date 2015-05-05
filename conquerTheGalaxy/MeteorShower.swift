//
//  MeteorShower.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/27/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

// MeteorShower takes care of the process of spawning Meteors, removing them if or if they 
// explode, runnning waves of meteors, and waiting for a period of time before beginning
// the next wave
// @param progression tells the class what kinds of waves to spawn and how much
//        health each meteor should have (an int range from 0 - 100)
// @param parentScene is the scene which this class belongs to
// @param previousWaitTime is there to ensure there's no repeat
// @param breakCount is there to give the player a break after... 5 waves
class MeteorShower {
    
    // Three unique masks to identify the bodies that come into contact
    enum ColliderType:UInt32 {
        case Meteor = 0x01
        case Projectile = 0x02
        case Dome = 0x04
        case FieldNode = 0x08
        //case Consumable = 0x10
    }
 
    // MARK: Properties
    var progression: Int!
    var parentScene: SKScene!
    var previousWaitTime: NSTimeInterval = 0
    var breakCount = Int()
    let textureAtlas = SKTextureAtlas(named: "meteors.atlas")
    let tailAtlas = SKTextureAtlas(named: "meteor_tail.atlas")
    var _scale:CGFloat!
    var is_iphone_4:Bool!
    
    init(progression: Int, parentScene: SKScene, scale: CGFloat, is_i4: Bool) {
        self.progression = progression
        self.parentScene = parentScene
        self._scale = scale
        self.is_iphone_4 = is_i4
    }
    
    // Mark: Logic Functions
    
    // Begins a wave of asteroids
    // Chooses a health for all the meteors in this wave
    // Chooses the amount of sequences of meteors spawns to occur
    //
    // Chooses the rate at which the meteors spawn
    // Makes a call to waitForNextWave once the wave ends
    func beginWave() {
        var health = chooseHealth()
        var amountOfSequences = chooseAmount()
        var rate = chooseRateofSpawn()
        
        var spawnAction = chooseTypeOfSpawn(health, amount: amountOfSequences);
        
        var waitAction = SKAction.waitForDuration(rate)
        var actionSequence = SKAction.repeatAction(SKAction.sequence([spawnAction, waitAction]), count: amountOfSequences)
        
        println("Beginning wave with health: \(health), amount: \(amountOfSequences), rate: \(rate)")
        self.parentScene.runAction(actionSequence, completion: { self.waitForNextWave() })
    }
    
    // Waits for a certain amount of time before the next wave can begin
    func waitForNextWave() {
        var waitTime = chooseWaitTime()
        println("Waiting for \(waitTime) sec...")
        var waitAction = SKAction.waitForDuration(waitTime)
        self.parentScene.runAction(waitAction, completion: { self.beginWave() })
    }
    
    // Creates a Meteor object
    // The meteor runs an action which is to move across the screen, and then remove itself
    // Each meteor's health is determined by the player's progression
    // Each meteor spawned has a chance at being a normal, silver, gold, or platinum
    // asteroid. It's much more likely to get a normal asteroid than a platinum asteroid.
    // This function pretty much takes care of choosing the meteor's position, texture, and
    func spawnMeteor(health: Double) {
        
        var node = SKNode()
        
        var currencyString = chooseCurrency()
        var textureString = chooseTexture(currencyString)
        var meteorTexture = textureAtlas.textureNamed(textureString)
        var meteor = Meteor(texture: meteorTexture, color: nil, size: meteorTexture.size(), health: health, currencyType: currencyString, pN: node)
        meteor.setScale(_scale)
        meteor.zPosition = 10
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: meteorTexture.size().width*0.4)
        meteor.physicsBody?.categoryBitMask = ColliderType.Meteor.rawValue
        meteor.physicsBody?.contactTestBitMask = ColliderType.Projectile.rawValue
        meteor.physicsBody?.collisionBitMask = 0
        meteor.physicsBody?.affectedByGravity = false
        meteor.physicsBody?.allowsRotation = true
        
//        // Field node
//        let fieldNode = SKFieldNode.radialGravityField()
//        fieldNode.strength = 10
//        fieldNode.region = SKRegion(radius: Float(meteor.size.width * 5))
//        fieldNode.categoryBitMask = ColliderType.FieldNode.rawValue
//        fieldNode.enabled = true
//        meteor.addChild(fieldNode)
        
        // Path to follow
        var y = chooseYPosition(is_iphone_4)
        var beginPosition = CGPointMake(self.parentScene.frame.maxX + meteor.size.width, y)
        var endPosition = CGPointMake(parentScene.frame.minX - meteor.size.width*2, y)
        var controlPoint = CGPointMake(parentScene.frame.midX, y + 50)
        var path = UIBezierPath()
        path.moveToPoint(beginPosition)
        path.addQuadCurveToPoint(endPosition, controlPoint: controlPoint)
        path.moveToPoint(beginPosition)
        var meteorSpeed = chooseSpeed()
        
        node.position = beginPosition
        
        // Particle stuff
        let rand = arc4random_uniform(5) + 1
        let particleTextureString = "meteor_tail-\(rand)"
        let emitterPath:NSString = NSBundle.mainBundle().pathForResource("FireDefault", ofType: "sks")!
        let emitterNode = NSKeyedUnarchiver.unarchiveObjectWithFile(emitterPath as String) as! SKEmitterNode
        //emitterNode.targetNode = parentScene
        //emitterNode.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [1.0, 0.9, 0.8, 0.6, 0.4, 0.3, 0.2, 0.1], times: [0.9, 0.8, 0.7, 0.6, 0.4, 0.3, 0.2, 0.1])
        //emitterNode.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0.9, 0.8, 0.6, 0.4, 0.3, 0.2, 0.1], times: [0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0])
        //emitterNode.particleAlphaSequence = SKKeyframeSequence(keyframeValues: [0.8, 0.6, 0.4, 0.2, 0], times: [0.7, 0.725, 0.75, 0.775, 0.8])
        emitterNode.particlePosition = CGPointMake(meteor.size.width/3, 0)
        //emitterNode.particleTexture = SKTexture(imageNamed: particleTextureString)
        emitterNode.particleZPositionRange = 1

        node.addChild(emitterNode)
        node.addChild(meteor)
        
        meteor.travelAndRotate(path, meteorSpeed: meteorSpeed, angle: chooseAngleToRotate())
        parentScene.addChild(node)
        var pathToTravelAction = SKAction.followPath(path.CGPath, asOffset: false, orientToPath: false, duration: meteorSpeed)
        node.runAction(pathToTravelAction, completion: { node.removeFromParent() })
        
    }
    
    // MARK: -
    
    // Returns a string describing the kind of currency this meteor drops
    // Chances:
    // Platinum: 1/11
    // Gold: 2/11
    // Silver: 3/11
    // None: 5/11
    func chooseCurrency() -> String {
        var currencyPicker = Int(arc4random_uniform(11))
        
        switch currencyPicker {
        case 0...4:
            return "plain"
        case 5...7:
            return "silver"
        case 8...9:
            return "gold"
        case 10:
            return "platinum"
        default:
            return "plain"
        }
    }
    
    func chooseSpeed() -> NSTimeInterval {
        var number:UInt32
        switch progression {
        case 0...30:
            number = arc4random_uniform(6) + 10
        case 31...60:
            number = arc4random_uniform(4) + 10
        default:
            number = arc4random_uniform(3) + 8
        }
        return NSTimeInterval(number)
    }
    
    func chooseTypeOfSpawn(health: Double, amount: Int) -> SKAction {
        var action:SKAction
        switch progression {
        case 0...30:
            action = earlyProgressSpawn(health, amount: amount)
            return action
        case 31...60:
            action = mediumProgressSpawn(health, amount: amount)
            return action
        default:
            action = earlyProgressSpawn(health, amount: amount)
            return action
        }
    }
    
    // Returns an SKAction with a unique pattern of meteor spawns
    // If amount is 2, then we want to spawn more meteors than usual
    func earlyProgressSpawn(health: Double, amount: Int) -> SKAction {
        var number:Int
        if amount == 2 {
            number = 5
        }
        else {
            number = Int(arc4random_uniform(4))
        }
        
        var action:SKAction
        
        switch number {
        case 0:
            action = SKAction.runBlock({ self.spawnMeteor(health) })
            break
        case 1:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait = SKAction.waitForDuration(5)
            var secondSpawn = SKAction.runBlock({ self.spawnMeteor(health) })
            action = SKAction.sequence([firstSpawn, wait, secondSpawn ])
            break
        case 2:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait = SKAction.waitForDuration(3)
            var secondSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            action = SKAction.sequence([firstSpawn, wait, secondSpawn])
            break
        case 3:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait1 = SKAction.waitForDuration(3)
            var secondSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait2 = SKAction.waitForDuration(5)
            var thirdSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            action = SKAction.sequence([firstSpawn, wait1, secondSpawn, wait2, thirdSpawn])
            break
        default:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var secondSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var thirdSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var fourthSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var fifthSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var sixthSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait = SKAction.waitForDuration(4)
            
            action = SKAction.sequence([firstSpawn, wait, secondSpawn, wait, thirdSpawn, wait, fourthSpawn, wait, firstSpawn, wait, sixthSpawn])
            break
        }
        println("EarlySpawn...TypeOfSpawn: \(number)")
        return action
    }
    
    // Returns an SKAction with a unique pattern of meteor spawns
    // If amount is 2, then we want to spawn a barrage of meteors
    func mediumProgressSpawn(health: Double, amount: Int) -> SKAction {
        var number:Int
        if amount == 2 {
            number = 5
        }
        else {
            number = Int(arc4random_uniform(4))
        }
        
        var action:SKAction
        
        switch number {
        case 0:
            action = SKAction.runBlock({ self.spawnMeteor(health) })
            break
        case 1:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait = SKAction.waitForDuration(2)
            var secondSpawn = SKAction.runBlock({ self.spawnMeteor(health) })
            action = SKAction.sequence([firstSpawn, wait, secondSpawn ])
            break
        case 2:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait = SKAction.waitForDuration(4)
            var secondSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            action = SKAction.sequence([firstSpawn, wait, secondSpawn])
            break
        case 3:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait1 = SKAction.waitForDuration(2)
            var secondSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait2 = SKAction.waitForDuration(4)
            var thirdSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            action = SKAction.sequence([firstSpawn, wait1, secondSpawn, wait2, thirdSpawn])
            break
        default:
            var firstSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var secondSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var thirdSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var fourthSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var fifthSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var sixthSpawn = SKAction.runBlock( {self.spawnMeteor(health)} )
            var wait = SKAction.waitForDuration(2.5)
            
            action = SKAction.sequence([firstSpawn, wait, secondSpawn, wait, thirdSpawn, wait, fourthSpawn, wait, firstSpawn, wait, sixthSpawn])
            break
        }
        println("MediumSpawn...TypeOfSpawn: \(number)")
        return action
    }
    
    // Returns an Int describing how much health this meteor should have
    // Increments by 10 for each 10 levels of progression (i.e progression = 14 -> health = 20)
    func chooseHealth() -> Double {
        switch progression {
        case 0...10:
            return 10
        case 11...20:
            return 20
        case 21...30:
            return 30
        case 31...40:
            return 40
        case 41...50:
            return 50
        case 51...60:
            return 60
        case 61...70:
            return 70
        case 71...80:
            return 80
        case 81...90:
            return 90
        case 91...100:
            return 100
        default:
            println("Error: Progression should NOT be this high")
            return -1
        }
    }
    
    // Returns a String describing the texture to use for a meteor
    // Format : asteroidTexture_currencyName-someNumber(1-6)
    func chooseTexture(currencyString: String) -> String{
        var number = arc4random_uniform(6) + 1
        var textureString = "meteor_" + currencyString + "-" + String(number)
        return textureString
    }
    
    // Returns an Int describing how many sequences of meteors should spawn this wave
    // Chances:
    // 2: 1/6
    // 7: 1/6
    // 3: 2/6
    // 5: 2/6
    func chooseAmount() -> Int {
        var amountPicker = Int(arc4random_uniform(6))
        switch amountPicker {
        case 0:
            return 2
        case 1...2:
            return 3
        case 3...4:
            return 5
        default:
            return 7
        }
    }
    
    // Returns an NSTimeInterval describing the rate at which the meteors should spawn
    // Either 4, 5 or 6 sec... for now
    func chooseRateofSpawn() -> NSTimeInterval {
        var rate = Int(arc4random_uniform(3)) + 4
        return NSTimeInterval(rate)
    }
    
    // Returns an NSTimeInterval describing the amount of time to wait before beginning
    // the next wave of meteors
    // As of now, it's either 5, 10, 15 that can be chosen, unless it's been 5 waves,
    // in which case the player gets a "20" second break
    func chooseWaitTime() -> NSTimeInterval {
        if breakCount == 5 {
            breakCount = 0
            return 20.0
        }
        else {
            breakCount+=1
        }
        
        var wait = Int(arc4random_uniform(7))
        switch wait {
        case 0:
            if previousWaitTime != 15 {
                previousWaitTime = 15.0
                return 15.0
            }
            else {
                previousWaitTime = 10.0
                return 10.0
            }
        case 1...2:
            if (previousWaitTime != 5.0) {
                previousWaitTime = 5.0
                return 5.0
            } else {
                previousWaitTime = 10.0
                return 10.0
            }
        default:
            previousWaitTime = 10.0
            return 10.0
        }
    }
    
    // Returns some random angle for the meteor to rotate by between -115 and 115
    func chooseAngleToRotate() -> CGFloat {
        let someAngle = Double(arc4random_uniform(30)) + 180.0
        let radians = someAngle / 180.0 * M_PI
        return CGFloat(radians)
    }
    
    // Returns one of three CGFloats to assign as the Y position of a meteor
    func chooseYPosition(iphone_4: Bool) -> CGFloat {
        var picker = Int(arc4random_uniform(3))
        var baseY = parentScene.frame.height * 0.55
        var frameHeight = parentScene.frame.size.height
        
        switch picker {
        case 0:
            if iphone_4 {
                return baseY + (frameHeight * 0.1) }
            else { return baseY + (frameHeight * 0.3) }
        case 1:
            return baseY + (frameHeight * 0.2)
        default:
            return baseY + (frameHeight * 0.3)
        }
    }
}