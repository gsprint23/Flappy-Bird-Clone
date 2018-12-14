//
//  GameScene.swift
//  Flappy Bird Clone
//
//  Created by Gina Sprint on 11/25/18.
//  Copyright © 2018 Gina Sprint. All rights reserved.
// based on Rob Percival's Flappy Bird Clone
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var gameOver = false
    var scoreLabel = SKLabelNode()
    var score = 0
    var gameOverLabel = SKLabelNode()
    var timer = Timer()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2 // pipe or ground
        case Gap = 4
        // 8
        // doubles every time, use a unique number to represent a group of cases
    }
    
    @objc func makePipes() {
        let gapHeight = bird.size.height * 4 // chance of bird getting through
        let movementAmount = Int.random(in: 0..<Int(self.frame.height / 2))
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        
        
        let pipeTexture1 = SKTexture(imageNamed: "pipe1")
        pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture1.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture1.size())
        pipe1.physicsBody?.isDynamic = false
        pipe1.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue // can only detect contacts between objects of the same contactTestBitMask
        pipe1.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.collisionBitMask = ColliderType.Object.rawValue // whether two objects are allowed to pass through each other or not
        pipe1.zPosition = -1
        self.addChild(pipe1)
        
        let pipeTexture2 = SKTexture(imageNamed: "pipe2")
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture1.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.physicsBody?.isDynamic = false
        pipe2.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue // can only detect contacts between objects of the same contactTestBitMask
        pipe2.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = ColliderType.Object.rawValue // whether two objects are allowed to pass through each other or not
        pipe2.zPosition = -1
        self.addChild(pipe2)
        
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100.0))
        pipe1.run(movePipes)
        pipe2.run(movePipes)
        
        let gap = SKNode() // don't need a texture or sprite image from this
        gap.position = CGPoint(x: pipe1.position.x, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1.size.width, height: gapHeight))
        gap.physicsBody?.isDynamic = false
        gap.run(movePipes)
        gap.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue // can only detect contacts between objects of the same contactTestBitMask
        gap.physicsBody?.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody?.collisionBitMask = ColliderType.Gap.rawValue // bird is able to pass through the gap but we are still able to detect contact
        self.addChild(gap)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // called whenever we have contact between our objects
        // don't care which objects collided
        //know it will be the bird and something
        if gameOver == false {
            print("We have contact \(contact.bodyA.categoryBitMask) : \(contact.bodyB.categoryBitMask)")
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
                print("Gap")
                score += 1
                scoreLabel.text = String(score)
            }
            else {
                self.speed = 0 // stop the game
                gameOver = true
                timer.invalidate()
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                gameOverLabel.text = "Game Over! Tap to play again."
                self.addChild(gameOverLabel)
            }
        }
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
    }
    
    
    func setupGame() {
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        
        let backgroundTexture = SKTexture(imageNamed: "bg")
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -backgroundTexture.size().width, dy: 0.0), duration: 7.0) // move gradually to the left
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: backgroundTexture.size().width, dy: 0.0), duration: 0.0) // jump back to original position
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation, shiftBGAnimation]))
        
        var i = 0
        while i < 3 {
            bg = SKSpriteNode(texture: backgroundTexture)
            bg.position = CGPoint(x: backgroundTexture.size().width * CGFloat(i), y: self.frame.midY) // align the left hand edge with the edge of the background texture
            bg.size.height = self.frame.height
            bg.run(moveBGForever)
            self.addChild(bg)
            i += 1
            
            bg.zPosition = -2 // higher z position will be in front of it all the time
            // default zPosition is 0
        }
        
        
        
        let birdTexture = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1) // .1 seconds between each flap
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2)
        bird.physicsBody?.isDynamic = false
        bird.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue // can only detect contacts between objects of the same contactTestBitMask
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue // whether two objects are allowed to pass through each other or not
        
        self.addChild(bird)
        
        
        
        // want to check collision of bird with ground
        let ground = SKNode() // so sprite or image associated with it, invisible
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1)) // hieght of 1 pixel
        ground.physicsBody?.isDynamic = false // ground is not affected by gravity
        ground.physicsBody?.contactTestBitMask = ColliderType.Object.rawValue // can only detect contacts between objects of the same contactTestBitMask
        ground.physicsBody?.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = ColliderType.Object.rawValue // whether two objects are allowed to pass through each other or not
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 100)
        self.addChild(scoreLabel)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
            // start gravity when the user first touches the screen
            bird.physicsBody?.isDynamic = true
            bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 50.0)) // like hitting a ball with a bat
            // shift it 50 pixels upwards
        }
        else {
            gameOver = false
            score = 0
            self.speed = 1
            // remove the game over label and remove the pipes
            self.removeAllChildren()
            setupGame()
        }
    }
    
   
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
