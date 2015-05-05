//
//  GameScene.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/27/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit
import GameKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let IS_IPHONE_4 = UIScreen.mainScreen().bounds.size.height == 480
    var _scale:CGFloat!
    
    enum ColliderType:UInt32 {
        case Meteor = 0x01
        case Projectile = 0x02
        case Dome = 0x04
        case FieldNode = 0x08
        //case Consumable = 0x10
    }
    
    var meteorShowerController: MeteorShower!
    var gameData: GameData!
    var equippedWeapon:Weapon!
    var planetBase:PlanetBase!
    
    override func didMoveToView(view: SKView) {
        initGame()
        self.physicsWorld.contactDelegate = self
    }
    
    // Whenever the player touches the screen, the weapon should shoot
    // shoot() behavior changes based on the currentWeapon
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

        
        let touch = touches.first as! UITouch
        let touchLocation = touch.locationInNode(self)
        
        let beginningLocation = CGPointMake(equippedWeapon.position.x, equippedWeapon.position.y + equippedWeapon.size.height)
        let targetVector = vectorSubtract(touchLocation, beginningLocation)
        if targetVector.y > 30 {
            equippedWeapon.shoot(touchLocation, vector: targetVector)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch contactMask {
        case ColliderType.Projectile.rawValue | ColliderType.Meteor.rawValue:
            
            var projectile:Projectile
            var meteor:Meteor
            
            if contact.bodyA.categoryBitMask == ColliderType.Projectile.rawValue {
                projectile = contact.bodyA.node as! Projectile
                meteor = contact.bodyB?.node as! Meteor
            }
            else {
                projectile = contact.bodyB.node as! Projectile
                meteor = contact.bodyA?.node as! Meteor
            }
            
            meteor.takeDamage(projectile.damage, contactPos: projectile.position)
            projectile.removeFromParent()
        default:
            println("Hello?")
        }
    }
    
    // MARK: init functions
    
    // Try to retrieve saved game data and call appropriate functions to set up the scene.
    func initGame() {
        gameData = NSKeyedUnarchiver.unarchiveObjectWithFile(GameData.getFilePath() as! String) as? GameData
        
        // should only happen on the first launch
        if gameData == nil {
            gameData = GameData()
            saveGameData()
        }
        
        initBase()
        initBackground()
        initWeapon()
        initWaveController()
    }
    
    // Sets up the appropriate background image according the player's current planet
    func initBackground() {
        var textureString = gameData!.currentPlanet! + "_background"
        var texture = SKTexture(imageNamed: textureString)
        var background = SKSpriteNode(texture: texture, size: texture.size())
        background.position = CGPointMake(self.frame.midX, self.frame.midY)
        background.zPosition = -10
        background.setScale(_scale)
        self.addChild(background)
        
        var g_string = gameData.currentPlanet! + "_ground"
        var g_texture = SKTexture(imageNamed: g_string)
        var ground = SKSpriteNode(texture: g_texture, size: g_texture.size())
        ground.anchorPoint = CGPointMake(0.5, 0)
        ground.position = CGPointMake(self.frame.midX, self.frame.minY)
        ground.zPosition = -5
        
        // the ipad uses different ground textures.
        if (_scale == 0.81) {
            ground.setScale(1.0)
        }
        else {
            ground.setScale(_scale)
        }
        self.addChild(ground)
    }
    
    // Sets up the appropriate weapon based on the player's equipped weapon
    // Also sets up the weapon platform
    func initWeapon() {
        var equippedName = gameData.equippedWeaponName!
        var equippedData = gameData.weaponInventory![equippedName]
        var equippedString = "\(equippedName)-\(equippedData!.level!)"
        var texture = SKTexture(imageNamed: equippedString)
        
        if equippedName.hasPrefix("machine_gun") {
            equippedWeapon = MachineGun(texture: texture, color: nil, size: texture.size(), name: equippedData!.name!, level: equippedData!.level!, sublevel: equippedData!.sublevel!, parentScene: self)
        }
        else if equippedName.hasPrefix("missile_launcher"){
            equippedWeapon = Missile(texture: texture, color: nil, size: texture.size(), name: equippedData!.name!, level: equippedData!.level!, sublevel: equippedData!.sublevel!, parentScene: self)
        }
        else if equippedName.hasPrefix("laser") {
            equippedWeapon = Laser(texture: texture, color: nil, size: texture.size(), name: equippedData!.name!, level: equippedData!.level!, sublevel: equippedData!.sublevel!, parentScene: self)
        }
        else {
            equippedWeapon = RailGun(texture: texture, color: nil, size: texture.size(), name: equippedData!.name!, level: equippedData!.level!, sublevel: equippedData!.sublevel!, parentScene: self)
        }
        
        // Platform for weapon
        var platformString = "platform-\(equippedWeapon.level!)"
        var platform = SKSpriteNode(imageNamed: platformString)
        platform.anchorPoint = CGPointMake(0.5, 0.73)
        platform.position = planetBase.getCorrectPosition()
        platform.setScale(_scale)
        platform.zPosition = -1
        self.addChild(platform)
        
        equippedWeapon.anchorPoint = CGPointMake(0.5, 0)
        equippedWeapon.position = platform.position
        equippedWeapon.zPosition = 0
        equippedWeapon.setScale(_scale)
        self.addChild(equippedWeapon)
        
    }
    
    // Sets up the object in charge of the wave of meteors
    func initWaveController() {
        meteorShowerController = MeteorShower(progression: gameData!.currentProgress!, parentScene: self, scale: _scale, is_i4: IS_IPHONE_4)
        meteorShowerController.beginWave()
    }
    
    // Sets up the buildings for the base, as well as the spacemen positions
    func initBase() {
        planetBase = PlanetBase(base_states: gameData!.baseStates!, scene: self)
        planetBase.initBase(_scale)
        planetBase.initSpacemen(_scale)
    }
    
    // MARK: Helper functions
    
    // Returns the avaudioplayer we specify
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer {
        var path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        var url = NSURL.fileURLWithPath(path!)
        var error: NSError?
        var audioPlayer: AVAudioPlayer?
        audioPlayer = AVAudioPlayer(contentsOfURL: url, error: &error)
        return audioPlayer!
    }

    // Saves the instance of gameData to a file in the documents directory
    func saveGameData() -> Bool {
        var filepath = GameData.documentsDirectory().stringByAppendingPathComponent("gameData")
        var ret = NSKeyedArchiver.archiveRootObject(gameData!, toFile: filepath)
        return ret
    }
    
    override func update(currentTime: CFTimeInterval) {
        
    }

    

}
