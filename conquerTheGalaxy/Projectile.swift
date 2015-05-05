//
//  Projectile.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 4/11/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

class Projectile: SKSpriteNode {
    
    var damage:Double!
    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init(texture: SKTexture!, color: UIColor!, size: CGSize, damage: Double) {
        self.init(texture: texture, color: color, size: size)
        self.damage = damage
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Rotate to face direction of tap
    func rotateToFaceTouch(touchLocation: CGPoint) {
        let dy = touchLocation.y - self.position.y
        let dx = touchLocation.x - self.position.x
        let angle_degrees = atan2f(Float(dy), Float(dx))
        self.zRotation = CGFloat(angle_degrees - Float(M_PI_2))
    }
}