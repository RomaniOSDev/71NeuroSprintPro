//
//  WorkoutGenerator.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation

class WorkoutGenerator {
    static func generateWorkout(from metrics: CognitiveMetrics) -> Workout {
        // Calculate intensity: faster reaction = higher intensity
        let intensity = max(0.0, min(1.0, 1.0 - (metrics.averageReactionTime / 1000.0)))
        
        // Calculate complexity: better accuracy = more complex exercises
        let complexity = metrics.accuracy * 2.0
        
        // Determine rounds: 3-5 based on intensity
        let rounds = Int(3 + intensity * 2)
        
        // Determine work time: 30-60 seconds based on complexity
        let workTime = 30 + Int(complexity * 30)
        
        // Determine rest time: 10-20 seconds (higher intensity = less rest)
        let restTime = 20 - Int(intensity * 10)
        
        // Select exercises based on profile
        let exercises = ExerciseDatabase.exercises(
            for: metrics.profile,
            intensity: intensity,
            complexity: complexity
        )
        
        return Workout(
            name: "Generated Workout",
            rounds: rounds,
            exercises: exercises,
            workTime: workTime,
            restTime: restTime,
            createdAt: Date(),
            completedAt: nil,
            isCompleted: false,
            isCustom: false
        )
    }
}
