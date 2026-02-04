//
//  ContentView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel: AppViewModel
    
    init() {
        _appViewModel = StateObject(wrappedValue: AppViewModel())
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            // Achievement Unlocked Overlay
            if !appViewModel.progressTracker.newlyUnlockedAchievements.isEmpty {
                let firstAchievement = appViewModel.progressTracker.newlyUnlockedAchievements[0]
                AchievementUnlockedView(
                    achievement: firstAchievement,
                    isPresented: Binding(
                        get: { true },
                        set: { newValue in
                            if !newValue {
                                // Remove the first achievement from the queue
                                DispatchQueue.main.async {
                                    if !appViewModel.progressTracker.newlyUnlockedAchievements.isEmpty {
                                        appViewModel.progressTracker.newlyUnlockedAchievements.removeFirst()
                                    }
                                }
                            }
                        }
                    )
                )
                .zIndex(1000)
                .allowsHitTesting(true)
            }
            
            switch appViewModel.currentScreen {
            case .onboarding:
                OnboardingView()
                    .environmentObject(appViewModel)
            case .home:
                HomeView()
                    .environmentObject(appViewModel)
            case .neuroTest:
                NeuroTestView()
                    .environmentObject(appViewModel)
            case .workoutGenerator(let metrics):
                WorkoutGeneratorView(metrics: metrics)
                    .environmentObject(appViewModel)
            case .sprintWorkout(let workout):
                SprintWorkoutView(workout: workout)
                    .environmentObject(appViewModel)
            case .progress:
                ProgressScreenView()
                    .environmentObject(appViewModel)
            case .workoutList:
                WorkoutListView()
                    .environmentObject(appViewModel)
            case .createWorkout(let workout):
                CreateWorkoutView(existingWorkout: workout)
                    .environmentObject(appViewModel)
            case .achievements:
                AchievementsView()
                    .environmentObject(appViewModel)
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
            }
        }
    }
}

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var stats: (workouts: Int, reactionTime: Double, achievements: Int) {
        let workouts = appViewModel.progressTracker.progressData.totalWorkouts
        let reactionTime = appViewModel.progressTracker.progressData.averageReactionTime
        let achievements = appViewModel.progressTracker.progressData.achievements.filter { $0.isUnlocked }.count
        return (workouts, reactionTime, achievements)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header Section
                VStack(spacing: 12) {
                    // Logo Icon
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: "#FF3C00").opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        // Main circle with gradient
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF3C00"),
                                        Color(hex: "#FF3C00").opacity(0.75)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color(hex: "#FF3C00").opacity(0.5), radius: 20, x: 0, y: 10)
                            .shadow(color: Color(hex: "#FF3C00").opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // Inner highlight
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .center
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.top, 20)
                    
                    Text("NEURO SPRINT PRO")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: "#FF3C00"))
                    
                    Text("Train your brain, challenge your body")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Stats Cards
                HStack(spacing: 12) {
                    StatMiniCard(
                        icon: "flame.fill",
                        value: "\(stats.workouts)",
                        label: "Workouts",
                        color: Color(hex: "#FF3C00")
                    )
                    
                    StatMiniCard(
                        icon: "bolt.fill",
                        value: stats.reactionTime > 0 ? String(format: "%.0f", stats.reactionTime) : "—",
                        label: "Avg Reaction",
                        color: Color(hex: "#FF3C00")
                    )
                    
                    StatMiniCard(
                        icon: "trophy.fill",
                        value: "\(stats.achievements)",
                        label: "Achievements",
                        color: Color(hex: "#FF3C00")
                    )
                }
                .padding(.horizontal, 20)
                
                // Main Action Button
                Button(action: {
                    appViewModel.currentScreen = .neuroTest
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                        Text("START NEURO TEST")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 64)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "#FF3C00"),
                                            Color(hex: "#FF3C00").opacity(0.85)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            // Inner highlight
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.2),
                                            Color.clear
                                        ],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color(hex: "#FF3C00").opacity(0.4), radius: 15, x: 0, y: 8)
                    .shadow(color: Color(hex: "#FF3C00").opacity(0.2), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // Quick Actions Grid
                VStack(spacing: 16) {
                    Text("Quick Actions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    
                    VStack(spacing: 12) {
                        QuickActionButton(
                            icon: "list.bullet.rectangle",
                            title: "Workouts",
                            subtitle: "Browse & create workouts",
                            color: Color(hex: "#FF3C00")
                        ) {
                            appViewModel.currentScreen = .workoutList
                        }
                        
                        QuickActionButton(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress",
                            subtitle: "View your statistics",
                            color: Color(hex: "#FF3C00")
                        ) {
                            appViewModel.currentScreen = .progress
                        }
                        
                        QuickActionButton(
                            icon: "trophy.fill",
                            title: "Achievements",
                            subtitle: "\(stats.achievements) unlocked",
                            color: Color(hex: "#FF3C00")
                        ) {
                            appViewModel.currentScreen = .achievements
                        }
                        
                        QuickActionButton(
                            icon: "gearshape.fill",
                            title: "Settings",
                            subtitle: "App preferences",
                            color: Color(hex: "#FF3C00")
                        ) {
                            appViewModel.currentScreen = .settings
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.top, 10)
                
                Spacer(minLength: 40)
            }
        }
    }
}

struct StatMiniCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(0.2),
                                    color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.8),
                                Color.gray.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
