//
//  MachineGun.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/30/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

// MachineGun is a category of a Weapon. 
// shoot() must be overriden
// This weapon shoots three round bursts wherever the user taps
// Enough cooldown for the three projectiles to spawn
class MachineGun: Weapon {
    
    var coolDown:NSTimeInterval = 0.6
    var canShoot:Bool!
    
    convenience init(texture: SKTexture!, color: UIColor!, size: CGSize, name: String, level: Int, sublevel: Int, parentScene: SKScene) {
        self.init(texture: texture, color: color, size: size)
        self.weaponName = name
        self.level = level
        self.sublevel = sublevel
        canShoot = true
        self.parentScene = parentScene
    }
    
    override func shoot(touchLocation: CGPoint, vector: CGPoint) {
        if canShoot! {
            canShoot = false
            var spawnAction = SKAction.runBlock({ self.spawnBullets(touchLocation, vector: vector)})
            var waitAction = SKAction.waitForDuration(coolDown)
            var canShootNow = SKAction.runBlock({ self.canShoot = true })
            var burstWait = SKAction.waitForDuration(0.08)
            var burstShot = SKAction.sequence([spawnAction, burstWait, spawnAction, burstWait, spawnAction])
            
            self.runAction(SKAction.sequence([burstShot, waitAction, canShootNow]))
        }
    }
    
    func spawnBullets(touchLocation: CGPoint, vector: CGPoint) {
        let bulletTextureString = "bullets-\(level)"
        let texture = SKTexture(imageNamed: bulletTextureString)
        
        let bullets = Projectile(texture: texture, color: nil, size: texture.size(), damage: Double(level))
        bullets.position = CGPointMake(self.position.x, self.position.y + bullets.size.height)
        
        bullets.physicsBody = SKPhysicsBody(rectangleOfSize: bullets.size)
        //bullets.physicsBody?.dynamic = true
        bullets.physicsBody?.affectedByGravity = false
        bullets.physicsBody?.categoryBitMask = ColliderType.Projectile.rawValue
        //bullets.physicsBody?.collisionBitMask = ColliderType.Meteor.rawValue
        bullets.physicsBody?.contactTestBitMask = ColliderType.Meteor.rawValue
        
        // Position stuff
        var destination = vector.normalized
        let missileVector = vectorMultiply(destination, 1500)
        // TODO: get the right angle for these projectiles
        
        var moveAction = SKAction.moveTo(missileVector, duration: 2.5)
        var removeAction = SKAction.runBlock({ bullets.removeFromParent() })
        
        // Add and move to destination
        parentScene.addChild(bullets)
        bullets.runAction(SKAction.sequence([moveAction, removeAction]))
    }
    
}