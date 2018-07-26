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
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(background)
    }
}
