//
//  AchievementUnlockedView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct AchievementUnlockedView: View {
    let achievement: Achievement
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var isDismissing = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 30) {
                // Trophy Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: achievement.rarity.color),
                                    Color(hex: achievement.rarity.color).opacity(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: achievement.rarity.color).opacity(0.5), radius: 20)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                .opacity(opacity)
                
                VStack(spacing: 12) {
                    Text("Achievement Unlocked!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(achievement.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(hex: achievement.rarity.color))
                    
                    Text(achievement.description)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Rarity Badge
                    Text(achievement.rarity.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(hex: achievement.rarity.color))
                        .cornerRadius(20)
                }
                .opacity(opacity)
            }
        }
        .opacity(isDismissing ? 0 : 1)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if !isDismissing && isPresented {
                    dismiss()
                }
            }
        }
    }
    
    private func dismiss() {
        guard !isDismissing else { return }
        isDismissing = true
        
        withAnimation(.easeOut(duration: 0.25)) {
            scale = 0.5
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
        }
    }
}
