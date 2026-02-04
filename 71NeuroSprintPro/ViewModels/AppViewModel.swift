//
//  AppViewModel.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import Foundation
import SwiftUI
import Combine   

enum AppScreen {
    case onboarding
    case home
    case neuroTest
    case workoutGenerator(CognitiveMetrics)
    case sprintWorkout(Workout)
    case progress
    case workoutList
    case createWorkout(Workout?)
    case achievements
    case settings
}

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .onboarding
    @Published var cognitiveEngine = CognitiveEngine()
    @Published var progressTracker = ProgressTracker()
    @Published var currentWorkout: Workout?
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let hasSeenOnboardingKey = "HasSeenOnboarding"
    
    init() {
        // Check if user has seen onboarding
        if userDefaults.bool(forKey: hasSeenOnboardingKey) {
            currentScreen = .home
        } else {
            currentScreen = .onboarding
        }
        
        cognitiveEngine.onComplete = { [weak self] metrics in
            self?.handleTestComplete(metrics)
        }
        
        // Subscribe to cognitiveEngine changes to trigger UI updates
        cognitiveEngine.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: hasSeenOnboardingKey)
        currentScreen = .home
    }
    
    func handleTestComplete(_ metrics: CognitiveMetrics) {
        progressTracker.saveCognitiveMetrics(metrics)
        currentScreen = .workoutGenerator(metrics)
    }
    
    func startWorkout(_ workout: Workout) {
        var newWorkout = workout
        progressTracker.saveWorkout(newWorkout)
        currentWorkout = newWorkout
        currentScreen = .sprintWorkout(newWorkout)
    }
    
    func completeWorkout() {
        if let workout = currentWorkout {
            progressTracker.completeWorkout(workout.id)
            currentWorkout = nil
        }
    }
}
