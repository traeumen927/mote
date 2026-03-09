//
//  DriftScene.swift
//  Mote
//
//  Created by 홍정연 on 3/9/26.
//

import SpriteKit

final class DriftScene: SKScene {
    private let worldBody = SKNode()
    private var emotionNodesByDateKey: [String: SKLabelNode] = [:]
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if self.worldBody.parent == nil {
            self.addChild(self.worldBody)
        }
        
        self.backgroundColor = .clear
        self.scaleMode = .resizeFill
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3.8)
        self.physicsWorld.speed = 1
        
        self.physicsBody = nil
        self.configureWorldBoundary()
    }
    
    func updateWorldBounds(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        self.size = size
        self.configureWorldBoundary()
    }
    
    func apply(emotions: [EmotionRecord]) {
        let nextRecordsByKey = Dictionary(uniqueKeysWithValues: emotions.map { ($0.dateKey, $0) })
        let nextKeys = Set(nextRecordsByKey.keys)
        let currentKeys = Set(self.emotionNodesByDateKey.keys)
        
        let keysToRemove = currentKeys.subtracting(nextKeys)
        keysToRemove.forEach { key in
            self.emotionNodesByDateKey[key]?.removeFromParent()
            self.emotionNodesByDateKey[key] = nil
        }
        
        let keysToUpsert = nextKeys
        keysToUpsert.forEach { key in
            guard let record = nextRecordsByKey[key] else { return }
            
            if let node = self.emotionNodesByDateKey[key] {
                self.update(node: node, with: record)
            } else {
                let node = self.makeNode(for: record)
                self.emotionNodesByDateKey[key] = node
                self.addChild(node)
            }
        }
    }
    
    private func configureWorldBoundary() {
        guard self.size.width > 0, self.size.height > 0 else { return }
        
        let boundaryFrame = CGRect(origin: .zero, size: self.size)
        let body = SKPhysicsBody(edgeLoopFrom: boundaryFrame)
        body.restitution = 0.35
        body.friction = 0.8
        body.linearDamping = 0.15
        body.isDynamic = false
        
        self.worldBody.position = .zero
        self.worldBody.physicsBody = body
    }
    
    private func makeNode(for record: EmotionRecord) -> SKLabelNode {
        let node = SKLabelNode(text: record.emotion)
        node.fontName = "Outfit-SemiBold"
        node.fontSize = 28
        node.fontColor = .white
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.zPosition = 1
        
        let x = CGFloat.random(in: 24...(max(self.size.width - 24, 24)))
        let y = CGFloat.random(in: (self.size.height * 0.4)...(max(self.size.height - 24, self.size.height * 0.4)))
        node.position = CGPoint(x: x, y: y)
        
        let body = SKPhysicsBody(circleOfRadius: max(node.frame.width, node.frame.height) * 0.6)
        body.allowsRotation = false
        body.restitution = 0.45
        body.friction = 0.4
        body.linearDamping = 0.25
        body.affectedByGravity = true
        node.physicsBody = body
        
        return node
    }
    
    private func update(node: SKLabelNode, with record: EmotionRecord) {
        if node.text != record.emotion {
            node.text = record.emotion
            
            let newBody = SKPhysicsBody(circleOfRadius: max(node.frame.width, node.frame.height) * 0.6)
            newBody.allowsRotation = false
            newBody.restitution = 0.45
            newBody.friction = 0.4
            newBody.linearDamping = 0.25
            newBody.affectedByGravity = true
            node.physicsBody = newBody
        }
    }
}
