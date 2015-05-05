//
//  TitleScene.swift
//  conquerTheGalaxy
//
//  Created by Carlos Beltran on 3/29/15.
//  Copyright (c) 2015 Carlos. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene : SKScene {
    
    var viewController: UIViewController!
    let IS_IPHONE_5 = UIScreen.mainScreen().bounds.size.height == 568
    let IS_IPHONE_4 = UIScreen.mainScreen().bounds.size.height == 480
    let IS_IPAD = UIDevice.currentDevice().model
    var _scale:CGFloat!
    
    enum UIUserInterfaceIdiom : Int {
        case Phone // iPhone and iPod touch style UI
        case Pad // iPad style UI
    }
    
    override func didMoveToView(view: SKView) {
        if IS_IPHONE_5 || IS_IPHONE_4 {
            _scale = 0.86
        }
        else if (IS_IPAD as NSString).containsString("iPad") {
            _scale = 0.81
        }
        else {
            _scale = 1
        }
        
        showCurrentPlanetImage()
        beginMusic()
    }
    
    // The image covers up the actual scene getting ready in the background
    func showCurrentPlanetImage() {
        
        var launchImage = SKSpriteNode(imageNamed: "mainScreenImage")
        launchImage.position = CGPointMake(self.size.width / 2, self.size.height / 2)
        self.addChild(launchImage)
    }
    
    // Loads the song for the intro, or part of the current planet song
    func beginMusic() {
        
    }
    
    // Once the game is ready (everything loaded) the user can tap anywhere to begin playing
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        presentGameScene()
        self.userInteractionEnabled = false
    }
    
    func presentGameScene() {
        let scene = GameScene()
        // Configure the view.
        let skView = self.viewController.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        scene.size = skView.bounds.size
        scene._scale = self._scale!
        
        let transition = SKTransition.fadeWithDuration(0.5)
        
        skView.presentScene(scene, transition: transition)
    }
    
}