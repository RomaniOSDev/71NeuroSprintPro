//
//  Workout.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation

struct Workout: Codable, Identifiable {
    let id: UUID
    var name: String
    var rounds: Int
    var exercises: [Exercise]
    var workTime: Int // seconds
    var restTime: Int // seconds
    var createdAt: Date
    var completedAt: Date?
    var isCompleted: Bool = false
    var isCustom: Bool = false
    
    init(id: UUID = UUID(), name: String = "", rounds: Int, exercises: [Exercise], workTime: Int, restTime: Int, createdAt: Date = Date(), completedAt: Date? = nil, isCompleted: Bool = false, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.rounds = rounds
        self.exercises = exercises
        self.workTime = workTime
        self.restTime = restTime
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.isCompleted = isCompleted
        self.isCustom = isCustom
    }
}

struct Exercise: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let difficulty: Int // 1-5
    let muscleGroup: String
    let type: ExerciseType
    let duration: Int? // seconds, if nil - reps based
    let reps: Int?
    
    init(id: UUID = UUID(), name: String, description: String, difficulty: Int, muscleGroup: String, type: ExerciseType, duration: Int?, reps: Int?) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.muscleGroup = muscleGroup
        self.type = type
        self.duration = duration
        self.reps = reps
    }
    
    var instruction: String {
        switch type {
        case .explosive:
            return "Focus on explosive power"
        case .endurance:
            return "Maintain steady pace"
        case .mobility:
            return "Focus on form and coordination"
        }
    }
}

enum ExerciseType: String, Codable, CaseIterable {
    case explosive = "Explosive"
    case endurance = "Endurance"
    case mobility = "Mobility"
}

// Exercise Database
struct ExerciseDatabase {
    static let allExercises: [Exercise] = [
        // Explosive exercises
        Exercise(name: "Jump Squats", description: "Explosive squat jumps", difficulty: 4, muscleGroup: "Legs", type: .explosive, duration: nil, reps: 15),
        Exercise(name: "Burpees", description: "Full body explosive movement", difficulty: 5, muscleGroup: "Full Body", type: .explosive, duration: nil, reps: 10),
        Exercise(name: "Mountain Climbers", description: "Fast alternating leg movements", difficulty: 3, muscleGroup: "Core", type: .explosive, duration: 30, reps: nil),
        Exercise(name: "Box Jumps", description: "Jump onto elevated surface", difficulty: 4, muscleGroup: "Legs", type: .explosive, duration: nil, reps: 12),
        Exercise(name: "High Knees", description: "Running in place with high knees", difficulty: 2, muscleGroup: "Legs", type: .explosive, duration: 30, reps: nil),
        
        // Endurance exercises
        Exercise(name: "Plank", description: "Hold plank position", difficulty: 3, muscleGroup: "Core", type: .endurance, duration: 45, reps: nil),
        Exercise(name: "Wall Sit", description: "Sit against wall", difficulty: 3, muscleGroup: "Legs", type: .endurance, duration: 40, reps: nil),
        Exercise(name: "Push-ups", description: "Standard push-ups", difficulty: 3, muscleGroup: "Upper Body", type: .endurance, duration: nil, reps: 15),
        Exercise(name: "Lunges", description: "Alternating lunges", difficulty: 2, muscleGroup: "Legs", type: .endurance, duration: nil, reps: 20),
        Exercise(name: "Bicycle Crunches", description: "Alternating bicycle crunches", difficulty: 2, muscleGroup: "Core", type: .endurance, duration: nil, reps: 30),
        
        // Mobility exercises
        Exercise(name: "Lateral Lunges", description: "Side-to-side lunges", difficulty: 2, muscleGroup: "Legs", type: .mobility, duration: nil, reps: 12),
        Exercise(name: "Rotational Lunges", description: "Lunges with torso rotation", difficulty: 3, muscleGroup: "Legs", type: .mobility, duration: nil, reps: 10),
        Exercise(name: "Side Steps", description: "Lateral stepping movements", difficulty: 1, muscleGroup: "Legs", type: .mobility, duration: 30, reps: nil),
        Exercise(name: "Single Leg Balance", description: "Balance on one leg", difficulty: 2, muscleGroup: "Legs", type: .mobility, duration: 20, reps: nil),
        Exercise(name: "Hip Circles", description: "Circular hip movements", difficulty: 1, muscleGroup: "Hips", type: .mobility, duration: 30, reps: nil)
    ]
    
    static func exercises(for profile: ReactionProfile, intensity: Double, complexity: Double) -> [Exercise] {
        let filtered: [Exercise]
        
        switch profile {
        case .reactiveSniper:
            filtered = allExercises.filter { $0.type == .explosive }
        case .steadyGuardian:
            filtered = allExercises.filter { $0.type == .endurance }
        case .recovering:
            filtered = allExercises.filter { $0.type == .mobility }
        }
        
        let difficultyRange = Int(complexity * 2) + 1...Int(complexity * 2) + 3
        let selected = filtered.filter { difficultyRange.contains($0.difficulty) }
        
        return Array(selected.shuffled().prefix(Int(3 + intensity * 2)))
    }
}

// Predefined Workouts
struct PredefinedWorkouts {
    static let all: [Workout] = [
        Workout(
            name: "Quick Start",
            rounds: 3,
            exercises: [
                ExerciseDatabase.allExercises[0], // Jump Squats
                ExerciseDatabase.allExercises[4], // High Knees
                ExerciseDatabase.allExercises[8]  // Lateral Lunges
            ],
            workTime: 30,
            restTime: 15,
            isCustom: false
        ),
        Workout(
            name: "Full Body Blast",
            rounds: 4,
            exercises: [
                ExerciseDatabase.allExercises[1], // Burpees
                ExerciseDatabase.allExercises[6], // Plank
                ExerciseDatabase.allExercises[7], // Push-ups
                ExerciseDatabase.allExercises[2]  // Mountain Climbers
            ],
            workTime: 45,
            restTime: 20,
            isCustom: false
        ),
        Workout(
            name: "Endurance Challenge",
            rounds: 5,
            exercises: [
                ExerciseDatabase.allExercises[5], // Plank
                ExerciseDatabase.allExercises[6], // Wall Sit
                ExerciseDatabase.allExercises[8], // Lunges
                ExerciseDatabase.allExercises[9]  // Bicycle Crunches
            ],
            workTime: 60,
            restTime: 30,
            isCustom: false
        ),
        Workout(
            name: "Mobility Flow",
            rounds: 3,
            exercises: [
                ExerciseDatabase.allExercises[10], // Lateral Lunges
                ExerciseDatabase.allExercises[11], // Rotational Lunges
                ExerciseDatabase.allExercises[12], // Side Steps
                ExerciseDatabase.allExercises[13]  // Single Leg Balance
            ],
            workTime: 40,
            restTime: 20,
            isCustom: false
        ),
        Workout(
            name: "Explosive Power",
            rounds: 4,
            exercises: [
                ExerciseDatabase.allExercises[0], // Jump Squats
                ExerciseDatabase.allExercises[1], // Burpees
                ExerciseDatabase.allExercises[3], // Box Jumps
                ExerciseDatabase.allExercises[2]  // Mountain Climbers
            ],
            workTime: 45,
            restTime: 15,
            isCustom: false
        )
    ]
}
