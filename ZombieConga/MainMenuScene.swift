//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by Ma Xueyuan on 2018/08/09.
//  Copyright © 2018年 Ma Xueyuan. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override func didMove(to view: SKView) {
        let mainMenu = SKSpriteNode(imageNamed: "MainMenu.png")
        mainMenu.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(mainMenu)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sceneTapped()
    }
    
    func sceneTapped() {
        let gameScene = GameScene(size: size)
        gameScene.scaleMode = scaleMode
        let reveal = SKTransition.doorway(withDuration: 1.5)
        view?.presentScene(gameScene, transition: reveal)
    }
}
