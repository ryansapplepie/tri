//
//  MenuScene.swift
//  Tri
//
//  Created by Ryan King on 11/07/17.
//  Copyright © 2017 Ryan King. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    var toggleBg = false
    var background = SKSpriteNode()
    
    let titleLabel = SKLabelNode(fontNamed:"Avenir-Heavy")
    let aboutSprite = SKSpriteNode(imageNamed: "infoIcon.png")
    let creditLabel = SKLabelNode(fontNamed: "Avenir-Light")
    let highScoreLabel = SKLabelNode(fontNamed: "Avenir-Black")
    let playSprite = SKSpriteNode(imageNamed: "hex.png")
    
    override func didMove(to view: SKView) {
        background.color = UIColor(red:0.20, green:0.80, blue:1.00, alpha:1.0)
        background.size = CGSize(width: self.frame.width, height: self.frame.height)
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.zPosition = -1
        self.addChild(background)
        
        titleLabel.text = "Tri."
        titleLabel.fontSize = 100
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY * 1.55)
        self.addChild(titleLabel)
        
        var playSpriteXValue:Int = 187
        var playSpriteYValue:Int = 360
        
        if self.frame.width == 320.0{ //iPhone 5/SE dimensions
            playSpriteXValue = 162
            playSpriteYValue = 335
        }else if self.frame.width == 414.0{ //iPhone Plus dimensions
            playSpriteXValue = 202
            playSpriteYValue = 375
        }
        //else leave the values : iPhone 6/7 dimensions
        
        playSprite.color = .black
        playSprite.size = CGSize(width:50, height: 50)
        playSprite.position = CGPoint(x: playSpriteXValue, y: playSpriteYValue)
        playSprite.name = "playSprite"
        self.addChild(playSprite)
        
        aboutSprite.size = CGSize(width: 50, height: 50)
        aboutSprite.position = CGPoint(x: self.frame.midX, y: (self.frame.midY * 1.2) - self.frame.midY)
        aboutSprite.name = "aboutSprite"
        self.addChild(aboutSprite)
        
        creditLabel.text = "An App by Ryan King"
        creditLabel.fontSize = 20
        creditLabel.position = CGPoint(x: self.frame.midX, y: (self.frame.midY * 1.5) - self.frame.midY)
        self.addChild(creditLabel)
        
        highScoreLabel.text = ("High Score: " + String(UserDefaults.standard.integer(forKey: "highScore")))
        highScoreLabel.fontSize = 18
        highScoreLabel.position = CGPoint(x: self.frame.midX, y: (self.frame.midY * 1.8) - self.frame.midY)
        self.addChild(highScoreLabel)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(toggleScreen), SKAction.wait(forDuration: 5)])))
        playSprite.run(SKAction.repeatForever((SKAction.rotate(byAngle: 50, duration: 9))))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            let node:SKNode = self.atPoint(location)
            if node.name == "playSprite"{
                let newPlayScene:PlayScene = PlayScene(size: self.view!.bounds.size)
                newPlayScene.scaleMode = SKSceneScaleMode.fill
                self.view!.presentScene(newPlayScene, transition: SKTransition.crossFade(withDuration: 0.5))
            }else if node.name == "aboutSprite"{
                print("foo")
            }
        }
    }
    
    func toggleScreen(){
        var newFontColor:UIColor
        var newBgColor:UIColor
        if toggleBg{
            newFontColor = .black
            newBgColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0)
            toggleBg = false
        }else{
            newFontColor = .white
            newBgColor = UIColor(red:0.20, green:0.80, blue:1.00, alpha:1.0)
            toggleBg = true
        }
        let colorizeFont = SKAction.colorize(with: newFontColor, colorBlendFactor: 1.0, duration: 2.3)
        titleLabel.run(colorizeFont)
        creditLabel.run(colorizeFont)
        highScoreLabel.run(colorizeFont)
        background.run(SKAction.colorize(with: newBgColor, colorBlendFactor: 1.0, duration: 2.3))
        
    }
}
