//
//  SprintWorkoutView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct SprintWorkoutView: View {
    let workout: Workout
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var currentRound = 1
    @State private var currentExerciseIndex = 0
    @State private var timeRemaining = 0
    @State private var isResting = false
    @State private var isPaused = false
    @State private var isCompleted = false
    @State private var timer: Timer?
    
    var currentExercise: Exercise {
        workout.exercises[currentExerciseIndex]
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            if isCompleted {
                CompletionView()
                    .environmentObject(appViewModel)
            } else {
                VStack(spacing: 30) {
                    // Top Bar
                    HStack {
                        Button(action: {
                            appViewModel.currentScreen = .home
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("Round \(currentRound)/\(workout.rounds)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: {
                            togglePause()
                        }) {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color(hex: "#FF3C00"))
                        }
                    }
                    .padding()
                    
                    // Exercise Info
                    VStack(spacing: 16) {
                        Text(currentExercise.name.uppercased())
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(currentExercise.description)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        
                        Text(currentExercise.instruction)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#FF3C00"))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#FF3C00").opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Timer
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / CGFloat(isResting ? workout.restTime : workout.workTime))
                            .stroke(Color(hex: "#FF3C00"), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear, value: timeRemaining)
                        
                        VStack {
                            Text("\(timeRemaining)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(Color(hex: "#FF3C00"))
                            
                            Text(isResting ? "REST" : "WORK")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Progress Bar
                    ProgressView(value: Double(currentRound - 1), total: Double(workout.rounds))
                        .tint(Color(hex: "#FF3C00"))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal, 40)
                    
                    // Exercise Counter
                    Text("Exercise \(currentExerciseIndex + 1)/\(workout.exercises.count)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
                .onAppear {
                    startWorkout()
                }
                .onDisappear {
                    stopTimer()
                }
            }
        }
    }
    
    private func startWorkout() {
        startExercise()
    }
    
    private func startExercise() {
        isResting = false
        timeRemaining = workout.workTime
        startTimer()
    }
    
    private func startRest() {
        isResting = true
        timeRemaining = workout.restTime
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                timeRemaining -= 1
                
                if timeRemaining <= 0 {
                    handleTimerComplete()
                }
            }
        }
    }
    
    private func handleTimerComplete() {
        if isResting {
            // Rest complete, move to next exercise or round
            currentExerciseIndex += 1
            
            if currentExerciseIndex >= workout.exercises.count {
                // Round complete
                currentExerciseIndex = 0
                currentRound += 1
                
                if currentRound > workout.rounds {
                    // Workout complete
                    completeWorkout()
                } else {
                    startExercise()
                }
            } else {
                startExercise()
            }
        } else {
            // Work complete, start rest
            startRest()
        }
    }
    
    private func completeWorkout() {
        stopTimer()
        isCompleted = true
        appViewModel.completeWorkout()
    }
    
    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            stopTimer()
        } else {
            startTimer()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct CompletionView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#FF3C00"))
            
            Text("Workout Complete!")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
            
            Text("Great job! Your brain and body are in sync.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                appViewModel.currentScreen = .home
            }) {
                Text("BACK TO HOME")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(Color(hex: "#FF3C00"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}
