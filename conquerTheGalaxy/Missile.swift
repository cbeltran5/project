//
//  Missile.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/30/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

// Missile is a category of a Weapon.
// shoot() must be overriden
// This weapon shoots one projectile that does critical damage, as well as splash damage
// on nearby meteors
// Short cooldown
//
// @param coolDown the amount of time the user must wait between shots
// @param canShoot determines whether the weapon can shoot or not
class Missile: Weapon {
    
    var coolDown:NSTimeInterval = 0.8
    var canShoot:Bool!
    
    convenience init(texture: SKTexture!, color: UIColor!, size: CGSize, name: String, level: Int, sublevel: Int, parentScene: SKScene) {
        self.init(texture: texture, color: color, size: size)
        self.weaponName = name
        self.level = level
        self.sublevel = sublevel
        canShoot = true
        self.parentScene = parentScene
    }
    
    // If the weapon can shoot, spawn a projectile and have it move in the direction the user tapped
    override func shoot(touchLocation: CGPoint, vector: CGPoint) {
        super.shoot(touchLocation, vector: vector)
        if canShoot! {
            canShoot = false
            var spawnAction = SKAction.runBlock({ self.spawnMissile(touchLocation, vector: vector)})
            var waitAction = SKAction.waitForDuration(coolDown)
            var canShootNow = SKAction.runBlock({ self.canShoot = true })
            self.runAction(SKAction.sequence([spawnAction, waitAction, canShootNow]))
        }
    }
    
    // Spawns a projectile and makes it travel in the direction of the player's tap
    // It should cause splash damage, so not sure how to implement that... maybe make it split into three?
    // The other two that spawn could travel in a different paths to try and hit other meteors
    // This missile does damage of [level * 3]
    func spawnMissile(touchLocation: CGPoint, vector: CGPoint) {
        let missileTextureString = "rocket-\(self.level!)"
        let texture = SKTexture(imageNamed: missileTextureString)
        
        let missile = Projectile(texture: texture, color: nil, size: texture.size(), damage: Double(level) * 2.5)
        missile.anchorPoint = CGPointMake(0.5, 0)
        missile.position = self.position
        
        // Physics stuff
        missile.physicsBody = SKPhysicsBody(rectangleOfSize: missile.size)
        missile.physicsBody?.dynamic = true
        missile.physicsBody?.affectedByGravity = false
        missile.physicsBody?.categoryBitMask = ColliderType.Projectile.rawValue
        missile.physicsBody?.contactTestBitMask = ColliderType.Meteor.rawValue
//        missile.physicsBody?.fieldBitMask = ColliderType.FieldNode.rawValue
//        missile.physicsBody?.allowsRotation = true
        
        // Destination and action
        var destination = vector.normalized
        let missileVector = vectorMultiply(destination, 2000)
        var moveAction = SKAction.moveTo(missileVector, duration: 3.5)
        var removeAction = SKAction.runBlock({ missile.removeFromParent() })
        
        missile.rotateToFaceTouch(touchLocation)
        
        // Add and move to destination
        parentScene.addChild(missile)
        missile.runAction(SKAction.sequence([moveAction, removeAction]))
    }
    
}