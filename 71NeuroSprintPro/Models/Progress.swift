//
//  Progress.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation

struct ProgressData: Codable {
    var cognitiveHistory: [CognitiveMetrics]
    var workoutHistory: [Workout]
    var customWorkouts: [Workout]
    var achievements: [Achievement]
    var dailyChallenges: [DailyChallenge]
    
    var totalWorkouts: Int {
        workoutHistory.filter { $0.isCompleted }.count
    }
    
    var averageReactionTime: Double {
        guard !cognitiveHistory.isEmpty else { return 0 }
        return cognitiveHistory.map { $0.averageReactionTime }.reduce(0, +) / Double(cognitiveHistory.count)
    }
    
    var totalExercisesCompleted: Int {
        workoutHistory.filter { $0.isCompleted }.reduce(0) { $0 + $1.exercises.count }
    }
    
    var synchronizationLevel: Double {
        // Combined index of cognitive and physical progress
        let cognitiveProgress = min(1.0, (1000 - averageReactionTime) / 1000)
        let physicalProgress = min(1.0, Double(totalExercisesCompleted) / 100.0)
        return (cognitiveProgress + physicalProgress) / 2.0
    }
}

struct Achievement: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let category: AchievementCategory
    let rarity: AchievementRarity
    var isUnlocked: Bool
    var unlockedAt: Date?
    var progress: Double // 0.0 - 1.0
    var targetValue: Double?
    
    init(id: UUID = UUID(), name: String, description: String, icon: String, category: AchievementCategory, rarity: AchievementRarity, isUnlocked: Bool = false, unlockedAt: Date? = nil, progress: Double = 0.0, targetValue: Double? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.category = category
        self.rarity = rarity
        self.isUnlocked = isUnlocked
        self.unlockedAt = unlockedAt
        self.progress = progress
        self.targetValue = targetValue
    }
}

enum AchievementCategory: String, Codable {
    case cognitive = "Cognitive"
    case physical = "Physical"
    case consistency = "Consistency"
    case special = "Special"
}

enum AchievementRarity: String, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common: return "#808080"
        case .rare: return "#4A90E2"
        case .epic: return "#9B59B6"
        case .legendary: return "#F39C12"
        }
    }
}

enum AchievementType: String {
    case sniper = "Sniper"
    case untiring = "Untiring"
    case earlyBird = "Early Bird"
    case correlationGenius = "Correlation Genius"
    case speedDemon = "Speed Demon"
    case marathon = "Marathon"
    case perfectWeek = "Perfect Week"
    case nightOwl = "Night Owl"
    case consistency = "Consistency Master"
    case firstSteps = "First Steps"
    case hundredClub = "Hundred Club"
    case lightning = "Lightning Fast"
    
    static let all: [Achievement] = [
        // Cognitive Achievements
        Achievement(name: "First Steps", description: "Complete your first neuro test", icon: "figure.walk", category: .cognitive, rarity: .common, targetValue: 1),
        Achievement(name: "Sniper", description: "Achieve 95% accuracy in test", icon: "target", category: .cognitive, rarity: .rare, targetValue: 0.95),
        Achievement(name: "Lightning Fast", description: "Average reaction time under 200ms", icon: "bolt.fill", category: .cognitive, rarity: .epic, targetValue: 200),
        Achievement(name: "Speed Demon", description: "Complete test with 100% accuracy", icon: "speedometer", category: .cognitive, rarity: .legendary, targetValue: 1.0),
        
        // Physical Achievements
        Achievement(name: "Untiring", description: "Complete 5 workouts", icon: "flame.fill", category: .physical, rarity: .common, targetValue: 5),
        Achievement(name: "Marathon", description: "Complete 20 workouts", icon: "figure.run", category: .physical, rarity: .rare, targetValue: 20),
        Achievement(name: "Hundred Club", description: "Complete 100 exercises", icon: "star.circle.fill", category: .physical, rarity: .epic, targetValue: 100),
        
        // Consistency Achievements
        Achievement(name: "Perfect Week", description: "Complete 7 workouts in a week", icon: "calendar", category: .consistency, rarity: .rare, targetValue: 7),
        Achievement(name: "Consistency Master", description: "Complete workouts 10 days in a row", icon: "chart.line.uptrend.xyaxis", category: .consistency, rarity: .epic, targetValue: 10),
        
        // Special Achievements
        Achievement(name: "Early Bird", description: "Complete workout before 8 AM", icon: "sunrise.fill", category: .special, rarity: .common),
        Achievement(name: "Night Owl", description: "Complete workout after 10 PM", icon: "moon.fill", category: .special, rarity: .common),
        Achievement(name: "Correlation Genius", description: "20% improvement in both metrics", icon: "brain.head.profile", category: .special, rarity: .legendary)
    ]
}

struct DailyChallenge: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let target: Double
    let current: Double
    var isCompleted: Bool
    let date: Date
    
    init(id: UUID = UUID(), name: String, description: String, target: Double, current: Double, isCompleted: Bool, date: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.target = target
        self.current = current
        self.isCompleted = isCompleted
        self.date = date
    }
}

struct CognitiveDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let reactionTime: Double
    let accuracy: Double
}
