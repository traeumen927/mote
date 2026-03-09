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
    private let horizontalCenteringForce: CGFloat = 0.42
    private let maxSidewaysDriftForce: CGFloat = 0.06
    
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
        node.fontSize = 50
        node.fontColor = .white
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.zPosition = 1
        
        let x = self.makeSpawnXPosition()
        let y = CGFloat.random(in: (self.size.height * 0.4)...(max(self.size.height - 24, self.size.height * 0.4)))
        node.position = CGPoint(x: x, y: y)
        
        let body = SKPhysicsBody(circleOfRadius: max(node.frame.width, node.frame.height) * 0.52)
        body.allowsRotation = true
        body.friction = 0.7
        body.angularDamping = 0.35
        body.linearDamping = 0.22
        body.mass = 0.12
        body.affectedByGravity = true
        node.physicsBody = body
        
        self.applyInitialImpulse(to: node)
        
        return node
    }
    
    private func update(node: SKLabelNode, with record: EmotionRecord) {
        if node.text != record.emotion {
            node.text = record.emotion
            
            let newBody = SKPhysicsBody(circleOfRadius: max(node.frame.width, node.frame.height) * 0.52)
            newBody.allowsRotation = true
            newBody.restitution = 0.45
            newBody.friction = 0.7
            newBody.angularDamping = 0.35
            newBody.linearDamping = 0.22
            newBody.mass = 0.12
            newBody.affectedByGravity = true
            node.physicsBody = newBody
            
            self.applyInitialImpulse(to: node)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        let centerX = self.size.width * 0.5
        self.emotionNodesByDateKey.values.forEach { node in
            guard let body = node.physicsBody else { return }
            
            let distanceFromCenter = centerX - node.position.x
            let normalizedDistance = max(-1, min(1, distanceFromCenter / max(self.size.width * 0.5, 1)))
            let centeringForceX = normalizedDistance * self.horizontalCenteringForce
            let driftForceX = CGFloat.random(in: -self.maxSidewaysDriftForce...self.maxSidewaysDriftForce)
            
            body.applyForce(CGVector(dx: centeringForceX + driftForceX, dy: 0))
        }
    }
    
    private func makeSpawnXPosition() -> CGFloat {
        let minX = CGFloat(24)
        let maxX = max(self.size.width - 24, minX)
        let existingX = self.emotionNodesByDateKey.values.map(\.position.x)
        
        guard !existingX.isEmpty else {
            return CGFloat.random(in: minX...maxX)
        }
        
        var bestX = minX
        var bestDistance = -CGFloat.greatestFiniteMagnitude
        
        stride(from: minX, through: maxX, by: 18).forEach { candidateX in
            let nearestDistance = existingX
                .map { abs($0 - candidateX) }
                .min() ?? 0
            
            if nearestDistance > bestDistance {
                bestDistance = nearestDistance
                bestX = candidateX
            }
        }
        
        return bestX
    }
    
    private func applyInitialImpulse(to node: SKLabelNode) {
        guard let body = node.physicsBody else { return }
        
        let angle = CGFloat.random(in: (.pi * 0.3)...(.pi * 0.7))
        let magnitude = CGFloat.random(in: 1.6...2.5)
        let impulse = CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
        body.applyImpulse(impulse)
        
        let randomTorque = CGFloat.random(in: -0.022...0.022)
        body.applyTorque(randomTorque)
    }
}
