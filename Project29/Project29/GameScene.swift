//
//  GameScene.swift
//  Project29
//
//  Created by Harry Liu on 2016-01-17.
//  Copyright (c) 2016 HarryLiu. All rights reserved.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case Banana = 1
    case Building = 2
    case Player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController!
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        backgroundColor = UIColor(hue: 0.699, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        physicsWorld.contactDelegate = self
        
        createBuildings()
        createPlayers()
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody!.categoryBitMask = CollisionTypes.Player.rawValue
        player1.physicsBody!.collisionBitMask = CollisionTypes.Banana.rawValue
        player1.physicsBody!.contactTestBitMask = CollisionTypes.Banana.rawValue
        player1.physicsBody!.dynamic = false
        
        let player1Building = buildings[1]
        player1.position = CGPoint(x: player1Building.position.x, y: player1Building.position.y + ((player1Building.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player2.physicsBody!.categoryBitMask = CollisionTypes.Player.rawValue
        player2.physicsBody!.collisionBitMask = CollisionTypes.Banana.rawValue
        player2.physicsBody!.contactTestBitMask = CollisionTypes.Banana.rawValue
        player2.physicsBody!.dynamic = false
        
        let player2Building = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Building.position.x, y: player2Building.position.y + ((player2Building.size.height + player2.size.height) / 2))
        addChild(player2)
        
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: RandomInt(min: 2, max: 4) * 40, height: RandomInt(min: 300, max: 600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: UIColor.redColor(), size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
            addChild(building)
            
            buildings.append(building)
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if let firstNode = firstBody.node {
            if let secondNode = secondBody.node {
                if firstNode.name == "banana" && secondNode.name == "building" {
                    bananaHitBuilding(secondNode as! BuildingNode, atPoint: contact.contactPoint)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player1" {
                    destroyPlayer(player1)
                }
                
                if firstNode.name == "banana" && secondNode.name == "player2" {
                    destroyPlayer(player2)
                }
            }
        }
    }
    
    func destroyPlayer(player: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "hitPlayer.sks")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        banana?.removeFromParent()
        
        RunAfterDelay(2) { [unowned self] in
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorwayWithDuration(1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        }
        else {
            currentPlayer = 1
        }
        
        viewController.activatePlayerNumer(currentPlayer)
        
    }
    
    func degToRad(degress: Int) -> Double {
        return Double(degress) * M_PI / 180.0
    }
    
    func bananaHitBuilding(building: BuildingNode, atPoint contactPoint: CGPoint) {
        let buildingLocation = convertPoint(contactPoint, toNode: building)
        building.hitAtPoint(buildingLocation)
        
        let explosion = SKEmitterNode(fileNamed: "hitBuilding.sks")!
        explosion.position = contactPoint
        addChild(explosion)
        
        banana.name = ""
        banana?.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func launch(angle angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10.0
        
        let radians = degToRad(angle)
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody!.categoryBitMask = CollisionTypes.Banana.rawValue
        banana.physicsBody!.collisionBitMask = CollisionTypes.Building.rawValue | CollisionTypes.Player.rawValue
        banana.physicsBody!.contactTestBitMask = CollisionTypes.Building.rawValue | CollisionTypes.Player.rawValue
        banana.physicsBody!.usesPreciseCollisionDetection = true
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody!.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.waitForDuration(0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.runAction(sequence)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
        else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody!.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.waitForDuration(0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.runAction(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        

    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
            if banana != nil {
                if banana.position.y < -1000 {
                    banana.removeFromParent()
                    banana = nil
                    
                    changePlayer()
            }
            
        }
    }
}
