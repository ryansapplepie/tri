//
//  PlayScene.swift
//  Tri
//
//  Created by Ryan King on 1/07/17.
//  Copyright © 2017 Ryan King. All rights reserved.
//

import UIKit
import SpriteKit

class PlayScene: SKScene, SKPhysicsContactDelegate {
    let bgColorArray: [UIColor] = [UIColor(red:0.20, green:0.80, blue:1.00, alpha:1.0), UIColor(red:1.00, green:0.52, blue:0.20, alpha:1.0), UIColor(red:0.00, green:0.90, blue:0.45, alpha:1.0), UIColor(red:0.73, green:0.27, blue:0.92, alpha:1.0), UIColor(red:1.00, green:1.00, blue:0.40, alpha:1.0), UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)]
    
    var bgColorIndex:Int = 0
    var screenMod:Int = 0
    
    var positionsArray = [[CGPoint]]()
    var player = SKSpriteNode(imageNamed: "hex.png")
    var scoreLabel = SKLabelNode(fontNamed: "Avenir-Book")
    var background = SKSpriteNode()
    let bgAudioPlayer = SKAudioNode(fileNamed: "Night-Prowler.mp3")
    var currentIndex = [Int]()
    
    let playerCategory: UInt32 = 0x1 << 0
    let beamCategory: UInt32 = 0x1 << 1
    
    var inverseSpeed:Double = 1.00
    var score:Float = 0.0
    var lastSideNum:Int = 0
    
    var cameraZoomFactor:Float = 0.0
    var alive = true
    
    override func sceneDidLoad(){
        let camera = SKCameraNode()
        camera.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(camera)
        self.camera = camera
        
        let camWidth = Int(self.frame.width * 0.667)
        
        bgAudioPlayer.autoplayLooped = true
        self.addChild(bgAudioPlayer)
        bgAudioPlayer.run(SKAction.play())
        
        background.color = bgColorArray[bgColorIndex]
        background.size = CGSize(width: self.frame.width * 2, height: self.frame.height * 2)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -1
        self.addChild(background)
        
        scoreLabel.text = "0"
        scoreLabel.fontSize = 65
        scoreLabel.position = CGPoint(x: 0, y: camWidth)
        self.camera?.addChild(scoreLabel)
        
        if self.frame.width == 320.0{ //iPhone 5/SE dimensions
            screenMod = 25
        }else if self.frame.width == 414.0{ //iPhone Plus dimensions
            screenMod = -15
        }
        //else leave the value 0 : iPhone 6/7 dimensions

        for i in 0...2{
            var dimension = [CGPoint]()
            for b in 0...2{
                let point = CGPoint(x: ((i+1) * 80)+27 - screenMod, y: ((b+1) * 80) + 200 - screenMod)
                let posSprite = SKSpriteNode(color: .black, size:CGSize(width: 5, height: 5))
                dimension.append(point)
                posSprite.position = point
                self.addChild(posSprite)
            }
            positionsArray.append(dimension)
        }
        
        physicsWorld.contactDelegate = self
        
        player.color = .black
        player.size = CGSize(width:50, height:50)
        player.name = "player"
        player.position = positionsArray[1][1]
        player.alpha = 0.0
        currentIndex += [1,1]
        
        player = initPhysics(for: player)
        self.addChild(player)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 1.5 * inverseSpeed), SKAction.run(spawnBeams)])))
        player.run(SKAction.fadeIn(withDuration: 0.2))
        player.run(SKAction.repeatForever((SKAction.rotate(byAngle: 50, duration: 9 * inverseSpeed))))
        
    }
    
    override func didMove(to view: SKView) {
        for dir in [UISwipeGestureRecognizerDirection.right, UISwipeGestureRecognizerDirection.left, UISwipeGestureRecognizerDirection.up, UISwipeGestureRecognizerDirection.down]{
            let gesture = UISwipeGestureRecognizer()
            gesture.direction = dir
            gesture.addTarget(self, action: #selector(PlayScene.swipeResponder(gesture:)))
            view.addGestureRecognizer(gesture)
        }
    }
    
    func swipeResponder(gesture: UIGestureRecognizer){
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.right:
                    if currentIndex[0] != 2{
                        currentIndex[0] += 1
                    }
                case UISwipeGestureRecognizerDirection.left:
                    if currentIndex[0] != 0{
                        currentIndex[0] -= 1
                    }
                case UISwipeGestureRecognizerDirection.up:
                    if currentIndex[1] != 2{
                        currentIndex[1] += 1
                    }
                case UISwipeGestureRecognizerDirection.down:
                    if currentIndex[1] != 0{
                        currentIndex[1] -= 1
                    }
                default:
                    break
            }
            
            let newPos = positionsArray[currentIndex[0]][currentIndex[1]]
            player.run(SKAction.move(to: newPos, duration: 0.09))
        }
    }
    
    func resetScene(){
        let newPlayScene:MenuScene = MenuScene(size: self.view!.bounds.size)
        newPlayScene.scaleMode = SKSceneScaleMode.fill
        self.view!.presentScene(newPlayScene, transition: SKTransition.fade(withDuration: 1.2))
        
    }
    
    func spawnBeams(){
        if alive{
            let numBeams = Int(arc4random_uniform(4) + 1)
            var beams = [Int: String]()
            
            var firstSideNum:Int = 0
            for _ in 1...(numBeams >= 2 ? 2 : numBeams){ //ensure 3/4 odds of 2 beams
                var sideNum = Int(arc4random_uniform(6) + 1)
                while sideNum == firstSideNum || sideNum == lastSideNum{ sideNum = Int(arc4random_uniform(6) + 1) }
                beams[sideNum] = (Int(arc4random_uniform(2)) == 0 ? "+" : "-")
                firstSideNum = sideNum
            }
            lastSideNum = firstSideNum
            
            for (key, value) in beams{
                var beamSprite = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 40))
                beamSprite.name = "beam"
                beamSprite = initPhysics(for: beamSprite)
                
                if key <= 3 {
                    //on top
                    beamSprite.position = CGPoint(x: (key * 80)+27 - screenMod, y: Int(580 + cameraZoomFactor) - screenMod)
                    beamSprite.position.y += (value == "+" ? -440 - CGFloat(cameraZoomFactor * 2) : 0)
                }else{
                    //on side
                    beamSprite.position = CGPoint(x: Int(20 - cameraZoomFactor) - screenMod, y: (key * 72) - screenMod)
                    beamSprite.position.x += (value == "+" ? 0 : 335 + CGFloat(cameraZoomFactor * 2))
                    
                }
                
                beamSprite.color = .black
                beamSprite.alpha = 0.0
                self.addChild(beamSprite)
                
                let dir:Float = (value == "+" ? 1.0 : -1.0)
                let moveA = SKAction.moveBy(x: (CGFloat(key > 3 ? ((300 + (cameraZoomFactor * 1.5)) * dir ) : 0)) , y: (CGFloat(key <= 3 ? ((350 + (cameraZoomFactor * 1.5)) * dir ) : 0)), duration: 0.9 * inverseSpeed)
                let incrementScore = SKAction.run({self.progressCycle(beams: numBeams)})
                beamSprite.run(SKAction.sequence([SKAction.fadeIn(withDuration: 0.4), moveA, SKAction.fadeOut(withDuration: 0.4), SKAction.removeFromParent(), incrementScore]))
                
            }
        }
    }
    
    func initPhysics(for sprite: SKSpriteNode) -> SKSpriteNode{
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 1.7)
        sprite.physicsBody?.affectedByGravity = false
        sprite.physicsBody?.categoryBitMask = (sprite.name == "player" ? playerCategory : beamCategory)
        sprite.physicsBody?.collisionBitMask = 0
        sprite.physicsBody?.contactTestBitMask = (sprite.name == "player" ? beamCategory : playerCategory)
        
        return sprite
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        alive = false
        bgAudioPlayer.run(SKAction.changeVolume(to: 0.0, duration: 2))
        run(SKAction.playSoundFileNamed("Menu-Choice.mp3", waitForCompletion: true))
        /*if let particles = SKEmitterNode(fileNamed: "bgParticles.sks") {
            particles.position = background.position
            self.addChild(particles)
        }*/
        player.removeFromParent()
        if UserDefaults.standard.integer(forKey: "highScore") < Int(scoreLabel.text!)!{
            UserDefaults.standard.set(Int(scoreLabel.text!), forKey: "highScore")
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 1.75), SKAction.run(resetScene)]))
    }
    
    func progressCycle(beams: Int){
        if alive{
            score += (beams == 1 ? 1 : 0.5)
        }
        scoreLabel.text = String(Int(score))
        if score.truncatingRemainder(dividingBy: 5.0) == 0 && score != 1.0 && score != 0.0
        {
            //print("Score is " + String((score)))
            //print("Remainder is " + String(score.truncatingRemainder(dividingBy: 5.0)))
            
            let randCamMode = Int(arc4random_uniform(2))
            if cameraZoomFactor == 0.0 && randCamMode == 1{
                self.camera?.run(SKAction.scale(to: 2, duration: 1))
                cameraZoomFactor = (self.frame.width != 320.0 ? 200.0 : 175.0)
            }else if cameraZoomFactor == 200.0 && randCamMode == 1{
                self.camera?.run(SKAction.scale(to: 1, duration: 1))
                cameraZoomFactor = 0.0
            }
            
            inverseSpeed -= 0.1
            bgColorIndex += 1
            
            let newColor:UIColor
            bgColorIndex = (bgColorIndex == bgColorArray.count ? 0 : bgColorIndex)
            newColor = bgColorArray[bgColorIndex]
            
            if newColor == UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0){
                scoreLabel.fontColor = .black
            }else if newColor == UIColor(red:0.20, green:0.80, blue:1.00, alpha:1.0){
                scoreLabel.fontColor = .white
            }
            
            background.run(SKAction.colorize(with: newColor, colorBlendFactor: 1.0, duration: 1.3))
            
        }
        
    }
}
