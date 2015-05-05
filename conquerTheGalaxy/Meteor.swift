//
//  Meteor.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/27/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

// A Meteor encapsulates each meteor node that passes by on-screen. It has "health" and a "currencyType".
// @param health is how much damage it can take from a weapon
// @param currencyType is the kind of currency it contains (i.e silver, gold, platinum)
//
class Meteor : SKSpriteNode {
    
    enum ColliderType:UInt32 {
        case Meteor = 0x01
        case Projectile = 0x02
        case Dome = 0x04
        case FieldNode = 0x08
        //case Consumable = 0x10
    }
    
    var health: Double!
    var currencyType: String!
    var parentNode: SKNode!
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(texture: SKTexture!, color: UIColor!, size: CGSize, health: Double, currencyType: String, pN: SKNode) {
        self.init(texture: texture, color: color, size: size)
        self.health = health
        self.currencyType = currencyType
        self.parentNode = pN
        //addFieldNode() TODO:
    }
    
    // Adds a radial gravity field node to this spritenode
    func addFieldNode() {
        let fieldNode = SKFieldNode.radialGravityField()
        fieldNode.enabled = true
        fieldNode.categoryBitMask = ColliderType.FieldNode.rawValue
        fieldNode.region = SKRegion(radius: Float(self.size.width))
        fieldNode.strength = 20
        fieldNode.falloff = 1
        self.addChild(fieldNode)
    }
    
    // Whenever a weapon's projectile comes into contact with this meteor, "health" drops by the amount
    // of damage the weapon deals. If "health" is zero, the meteor explodes.
    func takeDamage(damage: Double, contactPos: CGPoint) {
        self.health! -= damage
        if self.health <= 0 {
            self.explode(contactPos)
        }
        else {
            self.createSmoke(contactPos)
        }
    }
    
    // TODO:The meteor spawns some smoke particles
    func createSmoke(pos: CGPoint) {
        
    }
    
    // Once the meteor is out of "health" it should run an explode animation, make an exploding sound,
    // and spawn bits of meteor
    func explode(pos: CGPoint) {
        self.createSmoke(pos)
        self.spawnBits()
        
        self.parentNode.removeAllChildren()
        self.parentNode.removeFromParent()
        self.removeFromParent()
    }
    
    // Makes bits of meteor with currency fall to the ground
    // These bits can be collected with a swipe on the lower portion of the screen
    func spawnBits() {
        
    }
    
    func travelAndRotate(path: UIBezierPath, meteorSpeed: NSTimeInterval, angle: CGFloat) {
        let rotateAction = SKAction.rotateByAngle(angle, duration: meteorSpeed)
        self.runAction(rotateAction)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}