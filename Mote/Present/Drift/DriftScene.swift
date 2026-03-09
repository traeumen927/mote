//
//  DriftScene.swift
//  Mote
//
//  Created by 홍정연 on 3/9/26.
//

import SpriteKit

final class DriftScene: SKScene {
    private let worldBody = SKNode()

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
}
