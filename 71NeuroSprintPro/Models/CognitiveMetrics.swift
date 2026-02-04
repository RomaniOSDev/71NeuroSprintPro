//
//  CognitiveMetrics.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation

struct CognitiveMetrics: Codable {
    var averageReactionTime: Double // milliseconds
    var consistency: Double // standard deviation
    var missedTargets: Int
    var falseTaps: Int
    var accuracy: Double // 0.0 - 1.0
    var totalTargets: Int
    var hits: Int
    
    var profile: ReactionProfile {
        if averageReactionTime < 300 && accuracy > 0.9 {
            return .reactiveSniper
        } else if averageReactionTime < 500 && accuracy > 0.7 {
            return .steadyGuardian
        } else {
            return .recovering
        }
    }
}

enum ReactionProfile: String, Codable {
    case reactiveSniper = "Reactive Sniper"
    case steadyGuardian = "Steady Guardian"
    case recovering = "Recovering"
    
    var description: String {
        switch self {
        case .reactiveSniper:
            return "Fast and accurate"
        case .steadyGuardian:
            return "Stable and consistent"
        case .recovering:
            return "Building up"
        }
    }
}

struct Target: Identifiable {
    let id: UUID
    let type: TargetType
    var position: CGPoint
    var size: CGFloat
    var appearedAt: Date
    var isHit: Bool
    var tapCount: Int
    
    init(id: UUID = UUID(), type: TargetType, position: CGPoint, size: CGFloat, appearedAt: Date, isHit: Bool = false, tapCount: Int = 0) {
        self.id = id
        self.type = type
        self.position = position
        self.size = size
        self.appearedAt = appearedAt
        self.isHit = isHit
        self.tapCount = tapCount
    }
    
    var requiredTaps: Int {
        switch type {
        case .basic:
            return 1
        case .double:
            return 2
        case .moving:
            return 1
        }
    }
}

enum TargetType {
    case basic
    case double
    case moving
}
