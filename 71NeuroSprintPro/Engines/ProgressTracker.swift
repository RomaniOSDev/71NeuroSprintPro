//
//  ProgressTracker.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation
import Combine

class ProgressTracker: ObservableObject {
    @Published var progressData: ProgressData
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "NeuroSprintProgress"
    
    init() {
        if let data = userDefaults.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode(ProgressData.self, from: data) {
            // Migration: update achievements if needed
            var updatedData = decoded
            if updatedData.achievements.count != AchievementType.all.count {
                // Migrate old achievements to new format
                updatedData.achievements = AchievementType.all.map { newAchievement in
                    if let oldAchievement = decoded.achievements.first(where: { $0.name == newAchievement.name }) {
                        // Preserve unlock status
                        var migrated = newAchievement
                        migrated.isUnlocked = oldAchievement.isUnlocked
                        migrated.unlockedAt = oldAchievement.unlockedAt
                        return migrated
                    }
                    return newAchievement
                }
            }
            self.progressData = updatedData
        } else {
            self.progressData = ProgressData(
                cognitiveHistory: [],
                workoutHistory: [],
                customWorkouts: [],
                achievements: AchievementType.all,
                dailyChallenges: []
            )
        }
    }
    
    func saveCognitiveMetrics(_ metrics: CognitiveMetrics) {
        progressData.cognitiveHistory.append(metrics)
        checkAchievements()
        save()
    }
    
    func saveWorkout(_ workout: Workout) {
        var newWorkout = workout
        newWorkout.createdAt = Date()
        progressData.workoutHistory.append(newWorkout)
        checkAchievements()
        save()
    }
    
    func completeWorkout(_ workoutId: UUID) {
        if let index = progressData.workoutHistory.firstIndex(where: { $0.id == workoutId }) {
            var workout = progressData.workoutHistory[index]
            workout.isCompleted = true
            workout.completedAt = Date()
            progressData.workoutHistory[index] = workout
            checkAchievements()
            save()
        }
    }
    
    private func checkAchievements() {
        var newlyUnlocked: [Achievement] = []
        
        // Update progress and check all achievements
        for index in progressData.achievements.indices {
            var achievement = progressData.achievements[index]
            
            if achievement.isUnlocked {
                continue
            }
            
            var shouldUnlock = false
            var newProgress: Double = 0.0
            
            switch achievement.name {
            case "First Steps":
                newProgress = min(1.0, Double(progressData.cognitiveHistory.count))
                shouldUnlock = progressData.cognitiveHistory.count >= 1
                
            case "Sniper":
                if let latest = progressData.cognitiveHistory.last {
                    newProgress = latest.accuracy
                    shouldUnlock = latest.accuracy >= 0.95
                }
                
            case "Lightning Fast":
                if !progressData.cognitiveHistory.isEmpty {
                    let avgReaction = progressData.averageReactionTime
                    if let target = achievement.targetValue {
                        newProgress = min(1.0, 1.0 - (avgReaction / target))
                    }
                    shouldUnlock = avgReaction <= 200
                }
                
            case "Speed Demon":
                if let latest = progressData.cognitiveHistory.last {
                    newProgress = latest.accuracy
                    shouldUnlock = latest.accuracy >= 1.0
                }
                
            case "Untiring":
                let completedCount = progressData.workoutHistory.filter { $0.isCompleted }.count
                if let target = achievement.targetValue {
                    newProgress = min(1.0, Double(completedCount) / target)
                }
                shouldUnlock = completedCount >= 5
                
            case "Marathon":
                let completedCount = progressData.workoutHistory.filter { $0.isCompleted }.count
                if let target = achievement.targetValue {
                    newProgress = min(1.0, Double(completedCount) / target)
                }
                shouldUnlock = completedCount >= 20
                
            case "Hundred Club":
                let totalExercises = progressData.totalExercisesCompleted
                if let target = achievement.targetValue {
                    newProgress = min(1.0, Double(totalExercises) / target)
                }
                shouldUnlock = totalExercises >= 100
                
            case "Perfect Week":
                let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
                let weekWorkouts = progressData.workoutHistory.filter { workout in
                    guard let completedAt = workout.completedAt else { return false }
                    return completedAt >= weekAgo && workout.isCompleted
                }
                if let target = achievement.targetValue {
                    newProgress = min(1.0, Double(weekWorkouts.count) / target)
                }
                shouldUnlock = weekWorkouts.count >= 7
                
            case "Consistency Master":
                let consecutiveDays = calculateConsecutiveDays()
                if let target = achievement.targetValue {
                    newProgress = min(1.0, Double(consecutiveDays) / target)
                }
                shouldUnlock = consecutiveDays >= 10
                
            case "Early Bird":
                let morningWorkouts = progressData.workoutHistory.filter { workout in
                    guard let completedAt = workout.completedAt else { return false }
                    let hour = Calendar.current.component(.hour, from: completedAt)
                    return hour < 8 && workout.isCompleted
                }
                shouldUnlock = !morningWorkouts.isEmpty
                newProgress = morningWorkouts.isEmpty ? 0.0 : 1.0
                
            case "Night Owl":
                let nightWorkouts = progressData.workoutHistory.filter { workout in
                    guard let completedAt = workout.completedAt else { return false }
                    let hour = Calendar.current.component(.hour, from: completedAt)
                    return hour >= 22 && workout.isCompleted
                }
                shouldUnlock = !nightWorkouts.isEmpty
                newProgress = nightWorkouts.isEmpty ? 0.0 : 1.0
                
            case "Correlation Genius":
                if progressData.cognitiveHistory.count >= 2 {
                    let first = progressData.cognitiveHistory.first!
                    let last = progressData.cognitiveHistory.last!
                    
                    let reactionImprovement = (first.averageReactionTime - last.averageReactionTime) / first.averageReactionTime
                    let accuracyImprovement = (last.accuracy - first.accuracy) / first.accuracy
                    
                    newProgress = min(1.0, max(reactionImprovement, accuracyImprovement) / 0.2)
                    shouldUnlock = reactionImprovement >= 0.2 && accuracyImprovement >= 0.2
                }
                
            default:
                break
            }
            
            achievement.progress = newProgress
            
            if shouldUnlock && !achievement.isUnlocked {
                achievement.isUnlocked = true
                achievement.unlockedAt = Date()
                newlyUnlocked.append(achievement)
            }
            
            progressData.achievements[index] = achievement
        }
        
        if !newlyUnlocked.isEmpty {
            DispatchQueue.main.async { [weak self] in
                self?.newlyUnlockedAchievements = newlyUnlocked
            }
        }
    }
    
    private func calculateConsecutiveDays() -> Int {
        let completedWorkouts = progressData.workoutHistory
            .filter { $0.isCompleted }
            .compactMap { $0.completedAt }
            .sorted(by: >)
        
        guard !completedWorkouts.isEmpty else { return 0 }
        
        var consecutiveDays = 1
        var currentDate = Calendar.current.startOfDay(for: completedWorkouts[0])
        
        for workoutDate in completedWorkouts.dropFirst() {
            let workoutDay = Calendar.current.startOfDay(for: workoutDate)
            let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            
            if Calendar.current.isDate(workoutDay, inSameDayAs: currentDate) {
                continue
            } else if Calendar.current.isDate(workoutDay, inSameDayAs: previousDay) {
                consecutiveDays += 1
                currentDate = workoutDay
            } else {
                break
            }
        }
        
        return consecutiveDays
    }
    
    func getDailyChallenges() -> [DailyChallenge] {
        let today = Calendar.current.startOfDay(for: Date())
        return progressData.dailyChallenges.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    func createDailyChallenge(name: String, description: String, target: Double) {
        let challenge = DailyChallenge(
            name: name,
            description: description,
            target: target,
            current: 0,
            isCompleted: false,
            date: Date()
        )
        progressData.dailyChallenges.append(challenge)
        save()
    }
    
    func saveCustomWorkout(_ workout: Workout) {
        var newWorkout = workout
        newWorkout.isCustom = true
        newWorkout.createdAt = Date()
        
        if let index = progressData.customWorkouts.firstIndex(where: { $0.id == workout.id }) {
            progressData.customWorkouts[index] = newWorkout
        } else {
            progressData.customWorkouts.append(newWorkout)
        }
        save()
    }
    
    func deleteCustomWorkout(_ workoutId: UUID) {
        progressData.customWorkouts.removeAll { $0.id == workoutId }
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(progressData) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
    
    func getCognitiveDataPoints() -> [CognitiveDataPoint] {
        return progressData.cognitiveHistory.map {
            CognitiveDataPoint(
                date: Date(),
                reactionTime: $0.averageReactionTime,
                accuracy: $0.accuracy
            )
        }
    }
}
