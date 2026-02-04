//
//  ProgressView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct ProgressScreenView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Your Progress")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Brain & Body Sync")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                        
                        // Stats Cards
                        HStack(spacing: 16) {
                            StatCard(
                                title: "Workouts",
                                value: "\(appViewModel.progressTracker.progressData.totalWorkouts)",
                                icon: "flame.fill",
                                color: Color(hex: "#FF3C00")
                            )
                            
                            StatCard(
                                title: "Avg Reaction",
                                value: String(format: "%.0f ms", appViewModel.progressTracker.progressData.averageReactionTime),
                                icon: "bolt.fill",
                                color: Color(hex: "#FF3C00")
                            )
                        }
                        .padding(.horizontal)
                        
                        // Synchronization Level
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Synchronization Level")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("\(Int(appViewModel.progressTracker.progressData.synchronizationLevel * 100))%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "#FF3C00"))
                            }
                            
                            ProgressView(value: appViewModel.progressTracker.progressData.synchronizationLevel)
                                .tint(Color(hex: "#FF3C00"))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Achievements Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Achievements")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Button(action: {
                                    appViewModel.currentScreen = .achievements
                                }) {
                                    Text("View All")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(hex: "#FF3C00"))
                                }
                            }
                            
                            // Show only unlocked achievements or first 3
                            let displayedAchievements = Array(appViewModel.progressTracker.progressData.achievements.prefix(3))
                            ForEach(displayedAchievements) { achievement in
                                AchievementRow(achievement: achievement)
                            }
                            
                            if appViewModel.progressTracker.progressData.achievements.count > 3 {
                                Button(action: {
                                    appViewModel.currentScreen = .achievements
                                }) {
                                    HStack {
                                        Text("View \(appViewModel.progressTracker.progressData.achievements.count - 3) more")
                                            .font(.system(size: 14, weight: .medium))
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12))
                                    }
                                    .foregroundColor(Color(hex: "#FF3C00"))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Recent History
                        if !appViewModel.progressTracker.progressData.cognitiveHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Tests")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                
                                ForEach(Array(appViewModel.progressTracker.progressData.cognitiveHistory.suffix(5).reversed()), id: \.averageReactionTime) { metrics in
                                    CognitiveHistoryRow(metrics: metrics)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Back Button
                        Button(action: {
                            appViewModel.currentScreen = .home
                        }) {
                            Text("BACK TO HOME")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(hex: "#FF3C00"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.system(size: 24))
                .foregroundColor(achievement.isUnlocked ? Color(hex: "#FF3C00") : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(achievement.isUnlocked ? .black : .gray)
                
                Text(achievement.description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#FF3C00"))
            }
        }
        .padding(.vertical, 8)
    }
}

struct CognitiveHistoryRow: View {
    let metrics: CognitiveMetrics
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(metrics.profile.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(String(format: "%.0f ms • %.1f%% accuracy", metrics.averageReactionTime, metrics.accuracy * 100))
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
