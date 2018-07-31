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
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        //add background
        let background = SKSpriteNode(imageNamed: "background1")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
        
        //add the zombie
        zombie.position = CGPoint(x: 400, y: 400)
        //zombie.setScale(2.0)
        
        addChild(zombie)
        
        //gesture recognize
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapRecognizer)
        
        //draw playable area
        debugDrawPlayableArea()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if velocity != CGPoint.zero {
            if let lastTouchLocation = lastTouchLocation {
                rotate(sprite: zombie, direction: velocity, rotateRadiansPerSec: zombieRotateRadiansPerSec)
                
                let pace = (velocity * CGFloat(dt)).length()
                let restDistance = (lastTouchLocation - zombie.position).length()
                if restDistance <= pace {
                    zombie.position = lastTouchLocation
                    velocity = CGPoint.zero
                } else {
                    move(sprite: zombie, velocity: velocity)
                }
            }
        }
        boundsCheckZombie()
    }
    
    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amoutToMove = velocity * CGFloat(dt)
        sprite.position += amoutToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        let length = offset.length()
        if length == 0 {
            velocity = CGPoint.zero
            return
        }
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        //the touch outside the playableRect is 無効
        if !playableRect.contains(touchLocation) {
            return
        }
        lastTouchLocation = touchLocation
        moveZombieToward(location: touchLocation)
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.location(in: self)
//        sceneTouched(touchLocation: touchLocation)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
//        let touchLocation = touch.location(in: self)
//        sceneTouched(touchLocation: touchLocation)
//    }
    
    @objc func handleTap(recognizer: UIGestureRecognizer) {
        let viewLocation = recognizer.location(in: self.view)
        let touchLocation = convertPoint(fromView: viewLocation)
        sceneTouched(touchLocation: touchLocation)
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: playableRect.minX, y: playableRect.minY)
        let topRight = CGPoint(x: playableRect.maxX, y: playableRect.maxY)
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func rotate(sprite: SKSpriteNode, direction: CGPoint, rotateRadiansPerSec: CGFloat) {
        let shortest = shortestAngleBetween(angle1: sprite.zRotation, angle2: direction.angle)
        let amountToRotate = rotateRadiansPerSec * CGFloat(dt)
        if abs(shortest) <= amountToRotate {
            sprite.zRotation = direction.angle
        } else {
            sprite.zRotation += shortest.sign() * amountToRotate
        }
    }
}
