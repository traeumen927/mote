//
//  MotesScene.swift
//  Mote
//
//  Created by 홍정연 on 3/17/26.
//

import SpriteKit

/// Motes 탭에서 무작위 아이템 낙하를 담당하는 Scene.
final class MotesScene: SKScene {
    
    private let worldBody = SKNode()
    private var itemNodes: [SKLabelNode] = []
    
    private let initialAngularVelocityRange: ClosedRange<CGFloat> = 1.2...4.2
    
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
    
    func applyRandomItems(_ items: [String]) {
        self.itemNodes.forEach { $0.removeFromParent() }
        self.itemNodes.removeAll(keepingCapacity: true)
        
        items.forEach { item in
            let node = self.makeNode(for: item)
            self.itemNodes.append(node)
            self.addChild(node)
        }
    }
    
    private func configureWorldBoundary() {
        guard self.size.width > 0, self.size.height > 0 else { return }
        
        let boundaryFrame = CGRect(origin: .zero, size: self.size)
        let body = SKPhysicsBody(edgeLoopFrom: boundaryFrame)
        body.restitution = 0.22
        body.friction = 0.8
        body.linearDamping = 0.15
        body.isDynamic = false
        
        self.worldBody.position = .zero
        self.worldBody.physicsBody = body
    }
    
    private func makeNode(for item: String) -> SKLabelNode {
        let node = SKLabelNode(text: item)
        node.fontSize = 50
        node.fontColor = .white
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.zPosition = 1
        node.zRotation = CGFloat.random(in: -(.pi / 8)...(.pi / 8))
        
        let minX = CGFloat(24)
        let maxX = max(self.size.width - 24, minX)
        let x = CGFloat.random(in: minX...maxX)
        let y = CGFloat.random(in: (self.size.height * 0.4)...(max(self.size.height - 24, self.size.height * 0.4)))
        node.position = CGPoint(x: x, y: y)
        
        let body = SKPhysicsBody(circleOfRadius: max(node.frame.width, node.frame.height) * 0.52)
        body.allowsRotation = true
        body.friction = 0.7
        body.angularDamping = 0.9
        body.linearDamping = 0.55
        body.mass = 0.12
        body.affectedByGravity = true
        node.physicsBody = body
        
        self.applyInitialImpulse(to: node)
        return node
    }
    
    private func applyInitialImpulse(to node: SKLabelNode) {
        guard let body = node.physicsBody else { return }
        
        let angle = CGFloat.random(in: (.pi * 0.2)...(.pi * 0.8))
        let magnitude = CGFloat.random(in: 1.9...2.8)
        let impulse = CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
        body.applyImpulse(impulse)
        
        let randomAngularVelocity = CGFloat.random(in: self.initialAngularVelocityRange)
        let spinDirection: CGFloat = Bool.random() ? 1 : -1
        body.angularVelocity = randomAngularVelocity * spinDirection
    }
}
