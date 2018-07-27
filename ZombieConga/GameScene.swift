//
//  GameScene.swift
//  ZombieConga
//
//  Created by Ma Xueyuan on 2018/07/25.
//  Copyright © 2018年 Ma Xueyuan. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        //add background
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        //add the zombie
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.setScale(2.0)
        addChild(zombie)
    }
}
