//
//  AchievementsView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var selectedCategory: AchievementCategory? = nil
    
    var filteredAchievements: [Achievement] {
        let achievements = appViewModel.progressTracker.progressData.achievements
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }
    
    var unlockedCount: Int {
        appViewModel.progressTracker.progressData.achievements.filter { $0.isUnlocked }.count
    }
    
    var totalCount: Int {
        appViewModel.progressTracker.progressData.achievements.count
    }
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            appViewModel.currentScreen = .home
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 6) {
                            Text("Achievements")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("\(unlockedCount)/\(totalCount) unlocked")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Placeholder for alignment
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    
                    // Progress Bar
                    VStack(spacing: 12) {
                        HStack {
                            Text("Overall Progress")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                            Text("\(Int(Double(unlockedCount) / Double(totalCount) * 100))%")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "#FF3C00"))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 12)
                                    .cornerRadius(6)
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "#FF3C00"), Color(hex: "#FF3C00").opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(unlockedCount) / CGFloat(totalCount), height: 12)
                                    .cornerRadius(6)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding(.horizontal, 4)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                .background(Color.white)
                
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryFilterButton(
                            title: "All",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach([AchievementCategory.cognitive, .physical, .consistency, .special], id: \.self) { category in
                            CategoryFilterButton(
                                title: category.rawValue,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Achievements Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredAchievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct CategoryFilterButton: View {
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
                .background(isSelected ? Color(hex: "#FF3C00") : Color.gray.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                // Outer glow for unlocked
                if achievement.isUnlocked {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: achievement.rarity.color).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 25,
                                endRadius: 45
                            )
                        )
                        .frame(width: 90, height: 90)
                }
                
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [
                                Color(hex: achievement.rarity.color).opacity(0.25),
                                Color(hex: achievement.rarity.color).opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.1),
                                Color.gray.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(
                        color: achievement.isUnlocked ?
                        Color(hex: achievement.rarity.color).opacity(0.3) :
                        Color.black.opacity(0.1),
                        radius: achievement.isUnlocked ? 12 : 4,
                        x: 0,
                        y: achievement.isUnlocked ? 6 : 2
                    )
                
                // Inner highlight
                if achievement.isUnlocked {
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
                        .frame(width: 70, height: 70)
                }
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 32))
                    .foregroundColor(
                        achievement.isUnlocked ?
                        Color(hex: achievement.rarity.color) :
                        .gray
                    )
                    .shadow(
                        color: achievement.isUnlocked ?
                        Color(hex: achievement.rarity.color).opacity(0.3) :
                        Color.clear,
                        radius: 4
                    )
            }
            
            // Name
            Text(achievement.name)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(achievement.isUnlocked ? .black : .gray)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            // Rarity Badge
            Text(achievement.rarity.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(hex: achievement.rarity.color))
                .cornerRadius(8)
            
            // Progress (if not unlocked)
            if !achievement.isUnlocked && achievement.progress > 0 {
                VStack(spacing: 4) {
                    ProgressView(value: achievement.progress)
                        .tint(Color(hex: "#FF3C00"))
                        .scaleEffect(x: 1, y: 0.5, anchor: .center)
                    
                    if let target = achievement.targetValue {
                        Text("\(Int(achievement.progress * target)) / \(Int(target))")
                            .font(.system(size: 10))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Unlocked Badge
            if achievement.isUnlocked {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                    Text("Unlocked")
                        .font(.system(size: 10, weight: .semibold))
                }
                .foregroundColor(Color(hex: "#FF3C00"))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: [
                                Color(hex: achievement.rarity.color).opacity(0.08),
                                Color(hex: achievement.rarity.color).opacity(0.03)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.gray.opacity(0.02)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                if achievement.isUnlocked {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            }
            .shadow(
                color: achievement.isUnlocked ?
                Color(hex: achievement.rarity.color).opacity(0.2) :
                Color.black.opacity(0.08),
                radius: achievement.isUnlocked ? 15 : 8,
                x: 0,
                y: achievement.isUnlocked ? 8 : 4
            )
            .shadow(
                color: Color.black.opacity(0.04),
                radius: 2,
                x: 0,
                y: 1
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    achievement.isUnlocked ?
                    LinearGradient(
                        colors: [
                            Color(hex: achievement.rarity.color).opacity(0.4),
                            Color(hex: achievement.rarity.color).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.1),
                            Color.gray.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: achievement.isUnlocked ? 1.5 : 1
                )
        )
        .onTapGesture {
            showDetails = true
        }
        .sheet(isPresented: $showDetails) {
            AchievementDetailView(achievement: achievement)
        }
    }
}

struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Large Icon
                ZStack {
                    Circle()
                        .fill(
                            achievement.isUnlocked ?
                            Color(hex: achievement.rarity.color).opacity(0.2) :
                            Color.gray.opacity(0.1)
                        )
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 70))
                        .foregroundColor(
                            achievement.isUnlocked ?
                            Color(hex: achievement.rarity.color) :
                            .gray
                        )
                }
                
                VStack(spacing: 12) {
                    Text(achievement.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(achievement.rarity.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: achievement.rarity.color))
                        .cornerRadius(20)
                    
                    Text(achievement.description)
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    if achievement.isUnlocked, let unlockedAt = achievement.unlockedAt {
                        Text("Unlocked: \(unlockedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                    
                    if !achievement.isUnlocked && achievement.progress > 0 {
                        VStack(spacing: 8) {
                            Text("Progress")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            ProgressView(value: achievement.progress)
                                .tint(Color(hex: "#FF3C00"))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                                .frame(width: 200)
                            
                            if let target = achievement.targetValue {
                                Text("\(Int(achievement.progress * target)) / \(Int(target))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.top, 20)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Achievement")
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
