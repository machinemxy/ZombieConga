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
    //zombie related
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    let zombieAnimation: SKAction
    var invincible = false
    
    //game related
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let playableRect: CGRect
    var lastTouchLocation: CGPoint?
    
    //sound
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animate(with: textures, timePerFrame: 0.1)
        
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
        zombie.zPosition = 100
        addChild(zombie)
        
        //spawn enemies
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { [weak self] in
                self?.spawnEnemy()
            }, SKAction.wait(forDuration: 2.0)
            ])))
        
        //spawn cats
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { [weak self] in
                    self?.spawnCat()
                }, SKAction.wait(forDuration: 1.0)])
        ))
        
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
                    stopZombieAnimation()
                } else {
                    move(sprite: zombie, velocity: velocity)
                }
            }
        }
        
        boundsCheckZombie()
        
        moveTrain()
    }
    
    override func didEvaluateActions() {
        CheckCollisions()
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
            stopZombieAnimation()
            return
        }
        let direction = offset.normalized()
        velocity = direction * zombieMovePointsPerSec
        startZombieAnimation()
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
    
    func startZombieAnimation() {
        if zombie.action(forKey: "animation") == nil {
            zombie.run(SKAction.repeatForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeAction(forKey: "animation")
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "enemy"
        enemy.position = CGPoint(
            x: size.width + enemy.size.width/2,
            y: CGFloat.random(min: playableRect.minY + enemy.size.height/2, max: playableRect.maxY - enemy.size.height/2))
        addChild(enemy)
        
        let actionMove = SKAction.moveTo(x: -enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionRemove]))
    }
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
        cat.position = CGPoint(
            x: CGFloat.random(min: playableRect.minX, max: playableRect.maxX),
            y: CGFloat.random(min: playableRect.minY, max: playableRect.maxY))
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        cat .zRotation = π/16.0
        let leftWiggle = SKAction.rotate(byAngle: π/8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scale(by: 1.2, duration: 0.25)
        let scaleDwon = scaleUp.reversed()
        let fullScale = SKAction.sequence([scaleUp, scaleDwon, scaleUp, scaleDwon])
        let group = SKAction.group([fullWiggle, fullScale])
        let groupWait = SKAction.repeat(group, count: 10)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.run(SKAction.sequence(actions))
    }
    
    func zombieHit(cat: SKSpriteNode) {
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1)
        cat.zRotation = 0
        let becomeGreen = SKAction.colorize(with: SKColor.green, colorBlendFactor: 1, duration: 0.2)
        cat.run(becomeGreen)
        
        run(catCollisionSound)
    }
    
    func zombieHit(enemy: SKSpriteNode) {
        invincible = true
        
        //zombie blink
        let blinkTime = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customAction(withDuration: duration) { (node, elapsedTime) in
            let slice = duration / blinkTime
            let remainder = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
            node.isHidden = remainder > slice/2
        }
        zombie.run(blinkAction) {
            self.invincible = false
        }
        
        run(enemyCollisionSound)
    }
    
    func CheckCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodes(withName: "cat") { (node, _) in
            let cat = node as! SKSpriteNode
            if cat.frame.intersects(self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHit(cat: cat)
        }
        
        if invincible {
            return
        }
        
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodes(withName: "enemy") { (node, _) in
            let enemy = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHit(enemy: enemy)
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        
        enumerateChildNodes(withName: "train") { (node, stop) in
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amoutToMovePerSec = direction * self.zombieMovePointsPerSec
                let amoutToMove = amoutToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveBy(x: amoutToMove.x, y: amoutToMove.y, duration: actionDuration)
                node.run(moveAction)
            }
            targetPosition = node.position
        }
    }
}
