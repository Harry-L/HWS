//
//  GameScene.swift
//  Project20
//
//  Created by Harry Liu on 2016-01-13.
//  Copyright (c) 2016 HarryLiu. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

var gameTimer: NSTimer!
var fireworks = [SKNode]()

let leftEdge = -22
let bottomEdge = -22
let rightEdge = 1024 + 22

var gameScore: SKLabelNode!

var score: Int = 0 {
    didSet {
        gameScore.text = "Scocre is \(score)"
    }
}

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .Replace
        background.zPosition = -1
        addChild(background)
        
        gameTimer = NSTimer.scheduledTimerWithTimeInterval(6, target: self, selector: "launchFireworks", userInfo: nil, repeats: true)
        
        gameScore = SKLabelNode(text: "Score: 0")
        gameScore.horizontalAlignmentMode = .Left
        gameScore.fontSize = 48
        gameScore.position = CGPoint(x: 8, y: 8)
        addChild(gameScore)

    }
    
    func createFirework(xMovement xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.name = "firework"
        node.addChild(firework)
        
        switch GKRandomSource.sharedRandom().nextIntWithUpperBound(3) {
        case 0:
            firework.color = UIColor.cyanColor()
            firework.colorBlendFactor = 1
            
        case 1:
            firework.color = UIColor.greenColor()
            firework.colorBlendFactor = 1
            
        case 2:
            firework.color = UIColor.redColor()
            firework.colorBlendFactor = 1
            
        default:
            break
        }
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.followPath(path.CGPath, asOffset: true, orientToPath: true, speed: 200)
        node.runAction(move)
        
        let emitter = SKEmitterNode(fileNamed: "fuse.sks")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        fireworks.append(node)
        addChild(node)
    }
    
    func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        switch GKRandomSource.sharedRandom().nextIntWithUpperBound(4) {
        case 0:
            // 5 up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)
            
        case 1:
            // 5 in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)
            
        case 2:
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)
        
        case 3:
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)
        
        default:
            break
        }
    }
    
    func checkForTouches(touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.locationInNode(self)
        let nodes = nodesAtPoint(location)
        
        for node in nodes {
            if node.isKindOfClass(SKSpriteNode.self) {
                let sprite = node as! SKSpriteNode
                
                if sprite.name == "firework" {
                    for parent in fireworks {
                        let firework = parent.children[0] as! SKSpriteNode
                        
                        if firework.name == "selected" && firework.color != sprite.color {
                            firework.name = "firework"
                            firework.colorBlendFactor = 1
                        }
                    }
                    sprite.name = "selected"
                    sprite.colorBlendFactor = 0
                }
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        checkForTouches(touches)
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)
        checkForTouches(touches)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for var i = fireworks.count - 1; i >= 0; i-- {
            let firework = fireworks[i]
            
            if firework.position.y > 900 {
                fireworks.removeAtIndex(i)
                firework.removeFromParent()
            }
        }
    }
    
    func explodeFirework(firework: SKNode) {
        let emitter = SKEmitterNode(fileNamed: "explode.sks")!
        emitter.position = firework.position
        addChild(emitter)
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for var i = fireworks.count - 1; i >= 0; i-- {
            let parent = fireworks[i]
            let firework = parent.children[0] as! SKSpriteNode
            
            if firework.name == "selected" {
                explodeFirework(parent)
                fireworks.removeAtIndex(i)
                
                numExploded++
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
}
