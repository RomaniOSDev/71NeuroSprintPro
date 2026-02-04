//
//  CreateWorkoutView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct CreateWorkoutView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    let existingWorkout: Workout?
    
    @State private var workoutName: String = ""
    @State private var rounds: Int = 3
    @State private var workTime: Int = 30
    @State private var restTime: Int = 15
    @State private var selectedExercises: [Exercise] = []
    @State private var showExercisePicker = false
    
    init(existingWorkout: Workout? = nil) {
        self.existingWorkout = existingWorkout
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        appViewModel.currentScreen = .workoutList
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text(existingWorkout == nil ? "Create Workout" : "Edit Workout")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        saveWorkout()
                    }) {
                        Text("Save")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#FF3C00"))
                    }
                    .disabled(selectedExercises.isEmpty || workoutName.isEmpty)
                }
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Workout Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Workout Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("Enter workout name", text: $workoutName)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(size: 16))
                        }
                        .padding(.horizontal)
                        
                        // Settings
                        VStack(spacing: 16) {
                            SettingRow(
                                title: "Rounds",
                                value: $rounds,
                                range: 1...10,
                                format: { "\($0)" }
                            )
                            
                            SettingRow(
                                title: "Work Time (seconds)",
                                value: $workTime,
                                range: 10...120,
                                step: 5,
                                format: { "\($0)s" }
                            )
                            
                            SettingRow(
                                title: "Rest Time (seconds)",
                                value: $restTime,
                                range: 5...60,
                                step: 5,
                                format: { "\($0)s" }
                            )
                        }
                        .padding(.horizontal)
                        
                        // Exercises Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Exercises")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Button(action: {
                                    showExercisePicker = true
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus")
                                        Text("Add")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(hex: "#FF3C00"))
                                }
                            }
                            .padding(.horizontal)
                            
                            if selectedExercises.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray.opacity(0.5))
                                    Text("No exercises added")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                            } else {
                                ForEach(selectedExercises.indices, id: \.self) { index in
                                    ExerciseEditRow(
                                        exercise: $selectedExercises[index],
                                        onDelete: {
                                            selectedExercises.remove(at: index)
                                        }
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .sheet(isPresented: $showExercisePicker) {
            ExercisePickerView(selectedExercises: $selectedExercises)
        }
        .onAppear {
            if let workout = existingWorkout {
                workoutName = workout.name
                rounds = workout.rounds
                workTime = workout.workTime
                restTime = workout.restTime
                selectedExercises = workout.exercises
            }
        }
    }
    
    private func saveWorkout() {
        let workout = Workout(
            id: existingWorkout?.id ?? UUID(),
            name: workoutName,
            rounds: rounds,
            exercises: selectedExercises,
            workTime: workTime,
            restTime: restTime,
            isCustom: true
        )
        
        appViewModel.progressTracker.saveCustomWorkout(workout)
        appViewModel.currentScreen = .workoutList
    }
}

struct SettingRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    let format: (Int) -> String
    
    init(title: String, value: Binding<Int>, range: ClosedRange<Int>, step: Int = 1, format: @escaping (Int) -> String) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
        self.format = format
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: {
                    if value > range.lowerBound {
                        value = max(range.lowerBound, value - step)
                    }
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value > range.lowerBound ? Color(hex: "#FF3C00") : .gray)
                }
                .disabled(value <= range.lowerBound)
                
                Text(format(value))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(minWidth: 60)
                
                Button(action: {
                    if value < range.upperBound {
                        value = min(range.upperBound, value + step)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(value < range.upperBound ? Color(hex: "#FF3C00") : .gray)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ExerciseEditRow: View {
    @Binding var exercise: Exercise
    let onDelete: () -> Void
    
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
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
                    .padding(8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ExercisePickerView: View {
    @Binding var selectedExercises: [Exercise]
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedType: ExerciseType? = nil
    
    var filteredExercises: [Exercise] {
        var exercises = ExerciseDatabase.allExercises
        
        if let type = selectedType {
            exercises = exercises.filter { $0.type == type }
        }
        
        if !searchText.isEmpty {
            exercises = exercises.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return exercises
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    TextField("Search exercises", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(title: "All", isSelected: selectedType == nil) {
                                selectedType = nil
                            }
                            
                            ForEach(ExerciseType.allCases, id: \.self) { type in
                                FilterButton(title: type.rawValue, isSelected: selectedType == type) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(Color.gray.opacity(0.05))
                
                // Exercise List
                List {
                    ForEach(filteredExercises) { exercise in
                        ExercisePickerRow(exercise: exercise) {
                            if !selectedExercises.contains(where: { $0.id == exercise.id }) {
                                selectedExercises.append(exercise)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Add Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "#FF3C00"))
                }
            }
        }
    }
}

struct ExercisePickerRow: View {
    let exercise: Exercise
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(exercise.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                
                HStack(spacing: 8) {
                    Text(exercise.type.rawValue)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#FF3C00"))
                        .cornerRadius(6)
                    
                    Text(exercise.muscleGroup)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FF3C00"))
            }
        }
        .padding(.vertical, 8)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "#FF3C00") : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
    }
}
