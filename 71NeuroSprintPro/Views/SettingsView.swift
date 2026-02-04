//
//  SettingsView.swift
//  71NeuroSprintPro
//
//  Created by Роман Главацкий on 26.01.2026.
//

import SwiftUI
import StoreKit
import UIKit

struct SettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    
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
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("Settings")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Info Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "info.circle.fill",
                                    title: "App Version",
                                    value: getAppVersion(),
                                    color: Color(hex: "#FF3C00")
                                ) {}
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                SettingsRow(
                                    icon: "star.fill",
                                    title: "Rate Us",
                                    value: nil,
                                    color: Color(hex: "#FF3C00")
                                ) {
                                    rateApp()
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 20)
                        }
                        
                        // Legal Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Legal")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                SettingsRow(
                                    icon: "lock.shield.fill",
                                    title: "Privacy Policy",
                                    value: nil,
                                    color: Color(hex: "#FF3C00")
                                ) {
                                    openPrivacyPolicy()
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                SettingsRow(
                                    icon: "doc.text.fill",
                                    title: "Terms of Service",
                                    value: nil,
                                    color: Color(hex: "#FF3C00")
                                ) {
                                    openTermsOfService()
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, 20)
                        }
                        
                        // App Name
                        VStack(spacing: 8) {
                            Text("NEURO SPRINT PRO")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "#FF3C00"))
                            
                            Text("Train your brain, challenge your body")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 10)
                }
            }
        }
    }
    
    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "\(version) (\(build))"
        }
        return "1.0.0"
    }
    
    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.termsfeed.com/live/ab6dd244-3723-47b0-b80b-c6d817bf40e9") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.termsfeed.com/live/5dd483ea-8c67-42d4-865e-1f6c9f373ee4") {
            UIApplication.shared.open(url)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String?
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
                        .frame(width: 40, height: 40)
                        .shadow(color: color.opacity(0.2), radius: 6, x: 0, y: 3)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
