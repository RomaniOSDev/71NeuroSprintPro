//
//  WorkoutListView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        appViewModel.currentScreen = .home
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text("Workouts")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        appViewModel.currentScreen = .createWorkout(nil)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color(hex: "#FF3C00"))
                    }
                }
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Predefined Workouts
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Predefined Workouts")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            ForEach(PredefinedWorkouts.all) { workout in
                                WorkoutCard(workout: workout, isCustom: false)
                                    .environmentObject(appViewModel)
                            }
                        }
                        .padding(.top)
                        
                        // Custom Workouts
                        if !appViewModel.progressTracker.progressData.customWorkouts.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("My Workouts")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal)
                                
                                ForEach(appViewModel.progressTracker.progressData.customWorkouts) { workout in
                                    WorkoutCard(workout: workout, isCustom: true)
                                        .environmentObject(appViewModel)
                                }
                            }
                            .padding(.top)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    let isCustom: Bool
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name.isEmpty ? "Unnamed Workout" : workout.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("\(workout.rounds) rounds • \(workout.exercises.count) exercises")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isCustom {
                    Menu {
                        Button(action: {
                            appViewModel.currentScreen = .createWorkout(workout)
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: {
                            showDeleteAlert = true
                        }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                    Text("\(workout.workTime)s")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(Color(hex: "#FF3C00"))
                
                HStack(spacing: 4) {
                    Image(systemName: "pause.circle")
                        .font(.system(size: 14))
                    Text("\(workout.restTime)s")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.gray)
            }
            
            // Exercises preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(workout.exercises.prefix(4)) { exercise in
                        Text(exercise.name)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(hex: "#FF3C00").opacity(0.8))
                            .cornerRadius(8)
                    }
                    if workout.exercises.count > 4 {
                        Text("+\(workout.exercises.count - 4)")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            
            Button(action: {
                appViewModel.startWorkout(workout)
            }) {
                Text("START")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(hex: "#FF3C00"))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
        .alert("Delete Workout", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                appViewModel.progressTracker.deleteCustomWorkout(workout.id)
            }
        } message: {
            Text("Are you sure you want to delete this workout?")
        }
    }
}
