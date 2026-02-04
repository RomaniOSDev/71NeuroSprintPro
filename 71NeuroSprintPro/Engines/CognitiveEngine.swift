//
//  CognitiveEngine.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation
import SwiftUI
import Combine
import UIKit

class CognitiveEngine: ObservableObject {
    @Published var targets: [Target] = []
    @Published var score: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var isActive: Bool = false
    @Published var currentLevel: Int = 1
    
    private var tapTimes: [Date] = []
    private var reactionTimes: [Double] = []
    private var missedTargets: Int = 0
    private var falseTaps: Int = 0
    private var totalTargets: Int = 0
    private var hits: Int = 0
    
    private var timer: Timer?
    private var targetTimer: Timer?
    private var levelTimer: Timer?
    
    private let screenBounds = UIScreen.main.bounds
    private var movingTargets: [UUID: CGPoint] = [:]
    
    var onComplete: ((CognitiveMetrics) -> Void)?
    
    func start() {
        // Ensure we're on main thread
        if Thread.isMainThread {
            startInternal()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.startInternal()
            }
        }
    }
    
    private func startInternal() {
        // Stop and reset synchronously on main thread
        isActive = false
        timer?.invalidate()
        targetTimer?.invalidate()
        levelTimer?.invalidate()
        timer = nil
        targetTimer = nil
        levelTimer = nil
        
        // Reset state
        targets.removeAll()
        score = 0
        timeRemaining = 60
        currentLevel = 1
        tapTimes.removeAll()
        reactionTimes.removeAll()
        missedTargets = 0
        falseTaps = 0
        totalTargets = 0
        hits = 0
        movingTargets.removeAll()
        
        // Now start
        isActive = true
        print("🎮 Test started! isActive: \(isActive), timeRemaining: \(timeRemaining)")
        
        // Main countdown timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            guard self.isActive else {
                timer.invalidate()
                return
            }
            // Timer callbacks are on main thread, but ensure UI update
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.timeRemaining -= 1
                print("⏱️ Time remaining: \(self.timeRemaining)")
                
                if self.timeRemaining <= 0 {
                    self.stop()
                }
            }
        }
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
            print("✅ Main timer started")
        }
        
        // Level progression every 15 seconds
        levelTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isActive else {
                timer.invalidate()
                return
            }
            self.currentLevel += 1
        }
        if let levelTimer = levelTimer {
            RunLoop.main.add(levelTimer, forMode: .common)
        }
        
        // Spawn first target after a tiny delay to ensure UI is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            print("🚀 Starting to spawn first target, isActive: \(self.isActive)")
            self.spawnNextTarget()
        }
    }
    
    func stop() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isActive = false
            self.timer?.invalidate()
            self.targetTimer?.invalidate()
            self.levelTimer?.invalidate()
            self.timer = nil
            self.targetTimer = nil
            self.levelTimer = nil
            
            let metrics = self.calculateMetrics()
            self.onComplete?(metrics)
        }
    }
    
    func reset() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isActive = false
            self.timer?.invalidate()
            self.targetTimer?.invalidate()
            self.levelTimer?.invalidate()
            self.timer = nil
            self.targetTimer = nil
            self.levelTimer = nil
            self.targets.removeAll()
            self.score = 0
            self.timeRemaining = 60
            self.currentLevel = 1
            self.tapTimes.removeAll()
            self.reactionTimes.removeAll()
            self.missedTargets = 0
            self.falseTaps = 0
            self.totalTargets = 0
            self.hits = 0
            self.movingTargets.removeAll()
        }
    }
    
    func handleTap(at location: CGPoint) {
        guard isActive else { return }
        
        if Thread.isMainThread {
            handleTapInternal(at: location)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.handleTapInternal(at: location)
            }
        }
    }
    
    private func handleTapInternal(at location: CGPoint) {
        guard isActive else { return }
        
        let tapTime = Date()
        tapTimes.append(tapTime)
        
        // Check if tap hit any target
        var hitTarget = false
        for index in targets.indices {
            let target = targets[index]
            let distance = sqrt(pow(location.x - target.position.x, 2) + pow(location.y - target.position.y, 2))
            
            if distance <= target.size / 2 && !target.isHit {
                hitTarget = true
                hits += 1
                
                // Calculate reaction time
                let reactionTime = tapTime.timeIntervalSince(target.appearedAt) * 1000
                reactionTimes.append(reactionTime)
                
                // Update target
                var updatedTarget = target
                updatedTarget.tapCount += 1
                
                if updatedTarget.tapCount >= updatedTarget.requiredTaps {
                    updatedTarget.isHit = true
                    score += 10 * currentLevel
                    targets.remove(at: index)
                    
                    if target.type == .moving {
                        movingTargets.removeValue(forKey: target.id)
                    }
                } else {
                    targets[index] = updatedTarget
                }
                
                break
            }
        }
        
        if !hitTarget {
            falseTaps += 1
        }
    }
    
    private func spawnNextTarget() {
        guard isActive else { 
            print("⚠️ spawnNextTarget: isActive is false")
            return 
        }
        
        // Ensure we're on main thread
        if Thread.isMainThread {
            spawnNextTargetInternal()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.spawnNextTargetInternal()
            }
        }
    }
    
    private func spawnNextTargetInternal() {
        guard isActive else { 
            print("⚠️ spawnNextTarget: isActive became false")
            return 
        }
        
        let targetType: TargetType
        let random = Int.random(in: 0...100)
        
        if random < 50 {
            targetType = .basic
        } else if random < 80 {
            targetType = .double
        } else {
            targetType = .moving
        }
        
        let baseSize: CGFloat = 80
        let size = baseSize / CGFloat(currentLevel)
        
        let x = CGFloat.random(in: size...screenBounds.width - size)
        let y = CGFloat.random(in: 200...screenBounds.height - 200)
        
        let target = Target(
            type: targetType,
            position: CGPoint(x: x, y: y),
            size: size,
            appearedAt: Date()
        )
        
        targets.append(target)
        totalTargets += 1
        print("✅ Target spawned: \(target.type), total targets: \(targets.count)")
        
        if target.type == .moving {
            movingTargets[target.id] = target.position
            startMovingTarget(target.id)
        }
        
        // Remove target after display time
        let displayTime = max(0.5, 1.0 / Double(currentLevel))
        DispatchQueue.main.asyncAfter(deadline: .now() + displayTime) { [weak self] in
            guard let self = self else { return }
            if let index = self.targets.firstIndex(where: { $0.id == target.id && !$0.isHit }) {
                self.targets.remove(at: index)
                self.missedTargets += 1
                self.movingTargets.removeValue(forKey: target.id)
            }
        }
        
        // Spawn next target
        let spawnInterval = max(0.8, 1.5 / Double(currentLevel))
        targetTimer?.invalidate()
        targetTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: false) { [weak self] _ in
            self?.spawnNextTarget()
        }
        if let timer = targetTimer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func startMovingTarget(_ targetId: UUID) {
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self,
                  let index = self.targets.firstIndex(where: { $0.id == targetId }),
                  var position = self.movingTargets[targetId] else {
                timer.invalidate()
                return
            }
            
            // Move target
            let speed: CGFloat = 2.0 / CGFloat(self.currentLevel)
            position.x += CGFloat.random(in: -speed...speed)
            position.y += CGFloat.random(in: -speed...speed)
            
            // Keep within bounds
            let target = self.targets[index]
            position.x = max(target.size/2, min(self.screenBounds.width - target.size/2, position.x))
            position.y = max(200, min(self.screenBounds.height - 200, position.y))
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.movingTargets[targetId] = position
                if let index = self.targets.firstIndex(where: { $0.id == targetId }) {
                    self.targets[index].position = position
                }
            }
        }
    }
    
    private func calculateMetrics() -> CognitiveMetrics {
        let avgReactionTime = reactionTimes.isEmpty ? 1000.0 : reactionTimes.reduce(0, +) / Double(reactionTimes.count)
        
        let mean = avgReactionTime
        let variance = reactionTimes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(reactionTimes.count)
        let consistency = sqrt(variance)
        
        let accuracy = totalTargets > 0 ? Double(hits) / Double(totalTargets) : 0.0
        
        return CognitiveMetrics(
            averageReactionTime: avgReactionTime,
            consistency: consistency,
            missedTargets: missedTargets,
            falseTaps: falseTaps,
            accuracy: accuracy,
            totalTargets: totalTargets,
            hits: hits
        )
    }
}
