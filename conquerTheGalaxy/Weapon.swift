//
//  Weapon.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/30/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

// An extension of the CGPoint to cover some Vector math
internal extension CGPoint {
    
    // Get the length (a.k.a. magnitude) of the vector
    var length: CGFloat { return sqrt(self.x * self.x + self.y * self.y) }
    
    // Normalize the vector (preserve its direction, but change its magnitude to 1)
    var normalized: CGPoint { return CGPoint(x: self.x / self.length, y: self.y / self.length) }
}

// Vector * scalar
internal func vectorMultiply(point: CGPoint, factor: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * factor, y:point.y * factor)
}

// Vector - Vector
internal func vectorSubtract(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

// Weapon is the object that spawns projectiles to shoot at the meteors passing by. There
// are 4 categories of weapons, which will be subclasses of this class (MachineGun, Laser, 
// ExplodingCrossbow, and Missile) The main difference between all of these is the type of 
// projectile they spawn.
// All weapons include a subtle crosshair in their texture
// @param level describes the level of the gun, which reflects the amount of damage it does
// @param category is the subclass of weapon this belongs to, for easy storing
// @param weaponName is the name of the weapon, for easy storing and display
class Weapon: SKSpriteNode {
    
    // Three unique masks to identify the bodies that come into contact
    enum ColliderType:UInt32 {
        case Meteor = 0x01
        case Projectile = 0x02
        case Dome = 0x04
        case FieldNode = 0x08
        //case Consumable = 0x10
    }
    
    var level: Int!
    var sublevel: Int!
    var weaponName: String!
    var parentScene: SKScene!
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(texture: SKTexture!, color: UIColor!, size: CGSize, name: String, level: Int, sublevel: Int, parentScene: SKScene) {
        self.init(texture: texture, color: color, size: size)
        self.weaponName = name
        self.level = level
        self.sublevel = sublevel
        self.parentScene = parentScene
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Spawns a projectile. This function will be different for each gun category
    func shoot(touchLocation: CGPoint, vector: CGPoint) {
        rotateToFaceTouch(touchLocation)
    }
    
    // Rotate to face direction of tap
    func rotateToFaceTouch(touchLocation: CGPoint) {
        let dy = touchLocation.y - self.position.y
        let dx = touchLocation.x - self.position.x
        let angle_degrees = atan2f(Float(dy), Float(dx))
        self.zRotation = CGFloat(angle_degrees - Float(M_PI_2))
    }
    
    // Upgrade one level
    // Each weapon increases its damage differently.
    func upgrade() {}
}