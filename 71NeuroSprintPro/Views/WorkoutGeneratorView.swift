//
//  WorkoutGeneratorView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct WorkoutGeneratorView: View {
    let metrics: CognitiveMetrics
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var workout: Workout?
    @State private var isGenerating = true
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if isGenerating {
                VStack(spacing: 30) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(Color(hex: "#FF3C00"))
                    
                    Text("Analyzing your cognitive profile...")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        workout = WorkoutGenerator.generateWorkout(from: metrics)
                        isGenerating = false
                    }
                }
            } else if let workout = workout {
                ScrollView {
                    VStack(spacing: 30) {
                        // Profile Section
                        VStack(spacing: 16) {
                            Text("Your Reaction Profile")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(metrics.profile.rawValue)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Color(hex: "#FF3C00"))
                            
                            Text(metrics.profile.description)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Metrics
                        VStack(spacing: 12) {
                            MetricRow(label: "Reaction Time", value: String(format: "%.0f ms", metrics.averageReactionTime))
                            MetricRow(label: "Accuracy", value: String(format: "%.1f%%", metrics.accuracy * 100))
                            MetricRow(label: "Consistency", value: String(format: "%.1f", metrics.consistency))
                        }
                        .padding()
                        
                        // Workout Preview
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Your Personalized Workout")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                            
                            WorkoutInfoRow(icon: "arrow.triangle.2.circlepath", text: "\(workout.rounds) Rounds")
                            WorkoutInfoRow(icon: "clock", text: "\(workout.workTime)s Work")
                            WorkoutInfoRow(icon: "pause.circle", text: "\(workout.restTime)s Rest")
                            
                            Divider()
                            
                            Text("Exercises")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            
                            ForEach(workout.exercises) { exercise in
                                ExercisePreviewRow(exercise: exercise)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(16)
                        
                        // Start Button
                        Button(action: {
                            appViewModel.startWorkout(workout)
                        }) {
                            Text("START WORKOUT")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color(hex: "#FF3C00"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                    .padding()
                }
            }
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
        }
    }
}

struct WorkoutInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#FF3C00"))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.black)
        }
    }
}

struct ExercisePreviewRow: View {
    let exercise: Exercise
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(exercise.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if let reps = exercise.reps {
                Text("\(reps) reps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#FF3C00"))
            } else if let duration = exercise.duration {
                Text("\(duration)s")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#FF3C00"))
            }
        }
        .padding(.vertical, 8)
    }
}
