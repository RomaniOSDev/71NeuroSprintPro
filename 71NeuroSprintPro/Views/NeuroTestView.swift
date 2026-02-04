//
//  NeuroTestView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI

struct NeuroTestView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var isStarting = true
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            // Top Info Bar
            VStack {
                HStack {
                    Button(action: {
                        appViewModel.cognitiveEngine.stop()
                        appViewModel.currentScreen = .home
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(appViewModel.cognitiveEngine.timeRemaining)s")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "#FF3C00"))
                    
                    Spacer()
                    
                    Text("Score: \(appViewModel.cognitiveEngine.score)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding()
                
                Spacer()
            }
            
            // Targets
            ForEach(appViewModel.cognitiveEngine.targets) { target in
                TargetView(target: target)
                    .position(target.position)
            }
            
            // Bottom Instruction
            VStack {
                Spacer()
                
                if isStarting {
                    Text("Starting test...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                } else {
                    Text("Tap the orange circles!")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onEnded { value in
                    appViewModel.cognitiveEngine.handleTap(at: value.location)
                }
        )
        .onAppear {
            isStarting = true
            appViewModel.cognitiveEngine.onComplete = { [weak appViewModel] metrics in
                DispatchQueue.main.async {
                    appViewModel?.handleTestComplete(metrics)
                }
            }
            // Start with a small delay to ensure view is fully loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isStarting = false
                appViewModel.cognitiveEngine.start()
            }
        }
        .onDisappear {
            appViewModel.cognitiveEngine.stop()
        }
    }
}

struct TargetView: View {
    let target: Target
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Outer circle
            Circle()
                .fill(Color(hex: "#FF3C00").opacity(0.3))
                .frame(width: target.size, height: target.size)
            
            // Inner circle
            Circle()
                .fill(Color(hex: "#FF3C00"))
                .frame(width: target.size * 0.7, height: target.size * 0.7)
            
            // Double circle indicator
            if target.type == .double {
                Circle()
                    .stroke(Color(hex: "#FF3C00"), lineWidth: 3)
                    .frame(width: target.size * 1.2, height: target.size * 1.2)
            }
        }
        .scaleEffect(scale)
        .animation(.easeInOut(duration: 0.2), value: scale)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                scale = target.type == .double ? 1.1 : 1.0
            }
        }
    }
}
