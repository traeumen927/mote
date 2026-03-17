//
//  DriftScene.swift
//  Mote
//
//  Created by 홍정연 on 3/9/26.
//

import SpriteKit

/// Drift 탭에서 감정 이모지 노드들의 물리 시뮬레이션을 담당하는 Scene.
/// - 역할:
///   1) 화면 경계를 물리 월드 바운더리로 구성
///   2) 감정 데이터와 노드를 동기화(추가/갱신/삭제)
///   3) 생성 시 1회 랜덤 회전/방향을 부여하고 이후는 물리 엔진에 맡겨 자연스럽게 감속
final class DriftScene: SKScene {
    
    /// edgeLoop 물리 바디를 붙여 월드 경계를 담당하는 노드.
    private let worldBody = SKNode()
    
    /// dateKey 기준으로 현재 화면의 감정 라벨 노드를 관리.
    private var emotionNodesByDateKey: [String: SKLabelNode] = [:]
    
    /// 초기 회전 속도 랜덤 범위
    private let initialAngularVelocityRange: ClosedRange<CGFloat> = 1.2...4.2
    
    /// 화면 위(비가시 영역) 스폰 공간 높이.
    private let hiddenSpawnAreaHeight: CGFloat = 320
    
    /// 스폰 시 겹침 방지를 위한 최소 간격 여유치.
    private let spawnSeparationPadding: CGFloat = 2
    
    private struct ExistingCircle {
        let position: CGPoint
        let radius: CGFloat
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if self.worldBody.parent == nil {
            self.addChild(self.worldBody)
        }
        
        self.backgroundColor = .clear
        self.scaleMode = .resizeFill
        
        // 중력 방향/세기 설정: 노드가 아래로 낙하.
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -3.8)
        self.physicsWorld.speed = 1
        
        self.physicsBody = nil
        self.configureWorldBoundary()
    }
    
    /// 뷰 사이즈 변경 시 Scene 크기와 경계 물리를 재설정.
    func updateWorldBounds(for size: CGSize) {
        guard size.width > 0, size.height > 0 else { return }
        self.size = size
        self.configureWorldBoundary()
    }
    
    /// 최신 감정 목록을 기준으로 노드를 추가/갱신/삭제한다.
    func apply(emotions: [EmotionRecord]) {
        let nextRecordsByKey = Dictionary(uniqueKeysWithValues: emotions.map { ($0.dateKey, $0) })
        let nextKeys = Set(nextRecordsByKey.keys)
        let currentKeys = Set(self.emotionNodesByDateKey.keys)
        
        // 현재에는 있지만 다음 데이터에는 없는 노드 제거.
        let keysToRemove = currentKeys.subtracting(nextKeys)
        keysToRemove.forEach { key in
            self.emotionNodesByDateKey[key]?.removeFromParent()
            self.emotionNodesByDateKey[key] = nil
        }
        
        // 다음 데이터 기준으로 노드 upsert(있으면 갱신, 없으면 생성).
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
    
    /// Scene 전체 외곽에 edgeLoop를 만들어 노드가 화면 밖으로 빠져나가지 않게 한다.
    private func configureWorldBoundary() {
        guard self.size.width > 0, self.size.height > 0 else { return }
        
        // 비가시 상단 영역까지 포함해서 월드 경계를 만든다.
        // 상단에서 충돌해도 좌우 벽 밖으로 유실되지 않도록 하기위함
        let boundaryFrame = CGRect(
            x: 0,
            y: 0,
            width: self.size.width,
            height: self.size.height + self.hiddenSpawnAreaHeight
        )
        let body = SKPhysicsBody(edgeLoopFrom: boundaryFrame)
        body.restitution = 0.22
        body.friction = 0.8
        body.linearDamping = 0.15
        body.isDynamic = false
        
        self.worldBody.position = .zero
        self.worldBody.physicsBody = body
    }
    
    /// 신규 감정에 대응하는 라벨 노드를 만들고 초기 물리 상태를 주입.
    private func makeNode(for record: EmotionRecord) -> SKLabelNode {
        let node = SKLabelNode(text: record.emotion)
        node.fontSize = 50
        node.fontColor = .white
        node.verticalAlignmentMode = .center
        node.horizontalAlignmentMode = .center
        node.zPosition = 1
        
        // 생성 시점의 시각적 회전 각도도 랜덤으로 부여.
        node.zRotation = CGFloat.random(in: -(.pi / 8)...(.pi / 8))
        
        let nodeRadius = max(node.frame.width, node.frame.height) * 0.52
        node.position = self.makeSpawnPosition(nodeRadius: nodeRadius)
        
        let body = SKPhysicsBody(circleOfRadius: nodeRadius)
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
    
    /// 텍스트가 바뀐 노드는 물리 바디 반경도 달라질 수 있어 재생성한다.
    private func update(node: SKLabelNode, with record: EmotionRecord) {
        if node.text != record.emotion {
            node.text = record.emotion
            
            let newBody = SKPhysicsBody(circleOfRadius: max(node.frame.width, node.frame.height) * 0.52)
            newBody.allowsRotation = true
            newBody.restitution = 0.22
            newBody.friction = 0.7
            newBody.angularDamping = 0.9
            newBody.linearDamping = 0.55
            newBody.mass = 0.12
            newBody.affectedByGravity = true
            node.physicsBody = newBody
            
            // 텍스트/바디 갱신 후에도 초기 움직임을 다시 주어 정적인 상태를 피함.
            self.applyInitialImpulse(to: node)
        }
    }
    
    /// 비가시 상단 영역 안에서 기존 아이템들과 겹치지 않는 스폰 좌표를 만든다.
    private func makeSpawnPosition(nodeRadius: CGFloat) -> CGPoint {
        let minX = nodeRadius + 12
        let maxX = max(self.size.width - nodeRadius - 12, minX)
        let minY = self.size.height + nodeRadius + 8
        let maxY = self.size.height + self.hiddenSpawnAreaHeight - nodeRadius - 8
        
        let yUpperBound = max(maxY, minY)
        
        let existingCircles = self.emotionNodesByDateKey.values.map { node in
            ExistingCircle(
                position: node.position,
                radius: max(node.frame.width, node.frame.height) * 0.52
            )
        }
        
        let existingCount = existingCircles.count
        let fastSampleCount = min(380, max(80, 40 + (existingCount * 12)))
        let bestCandidateSampleCount = min(720, max(220, 120 + (existingCount * 20)))
        
        let nearestFreeDistance: (CGPoint) -> CGFloat = { candidate in
            existingCircles
                .map { existing in
                    let minimumDistance = existing.radius + nodeRadius + self.spawnSeparationPadding
                    return hypot(existing.position.x - candidate.x, existing.position.y - candidate.y) - minimumDistance
                }
                .min() ?? .greatestFiniteMagnitude
        }
        
        let randomCandidate: () -> CGPoint = {
            CGPoint(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...yUpperBound)
            )
        }
        
        // 1) 동적 샘플 수로 비충돌 위치를 빠르게 탐색
        for _ in 0..<fastSampleCount {
            let candidate = randomCandidate()
            if nearestFreeDistance(candidate) >= 0 {
                return candidate
            }
        }
        // 2) 모든 점이 빽빽할 때는 best-candidate 샘플링으로
        //    가장 여유가 큰 점(= 최근접 거리 최대)을 선택해 Poisson-disc에 가깝게 배치
        var bestPoint = randomCandidate()
        var bestDistance = -CGFloat.greatestFiniteMagnitude
        
        for _ in 0..<bestCandidateSampleCount {
            let candidate = randomCandidate()
            let distance = nearestFreeDistance(candidate)
            
            if distance > bestDistance {
                bestDistance = distance
                bestPoint = candidate
            }
        }
        
        return bestPoint
    }
    
    /// 노드 생성/갱신 시점에만 1회 초기 이동량/회전값을 부여한다.
    private func applyInitialImpulse(to node: SKLabelNode) {
        guard let body = node.physicsBody else { return }
        
        // 초기에 위쪽 방향으로 날아오르되, 좌우 편차는 랜덤.
        let angle = CGFloat.random(in: (.pi * 0.2)...(.pi * 0.8))
        let magnitude = CGFloat.random(in: 1.9...2.8)
        let impulse = CGVector(dx: cos(angle) * magnitude, dy: sin(angle) * magnitude)
        body.applyImpulse(impulse)
        
        // 회전값 자체를 랜덤으로 지정(방향/세기 모두 랜덤).
        let randomAngularVelocity = CGFloat.random(in: self.initialAngularVelocityRange)
        let spinDirection: CGFloat = Bool.random() ? 1 : -1
        body.angularVelocity = randomAngularVelocity * spinDirection
    }
}
