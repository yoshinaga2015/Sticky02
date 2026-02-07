//
//  OnboardingView.swift
//
//  Copyright (c) 2026 yuki
//
//  This software is released under the MIT License.
//  See LICENSE file for more information.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .padding(.top, 20)
            
            VStack(spacing: 8) {
                Text("Accessibility Permission Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("To use the global shortcut (Cmd+Ctrl+M), this app needs accessibility permissions.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    AccessibilityManager.promptAccessibilityPermission()
                    AccessibilityManager.openSystemSettings()
                }) {
                    Text("Open System Settings")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                Button("I have enabled it") {
                    if AccessibilityManager.checkAccessibilityPermission() {
                        isPresented = false
                    } else {
                        showingAlert = true
                    }
                }
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .frame(width: 400, height: 350)
        .background(Material.regular)
        .alert("Permission Not Detected", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please enable the permission in System Settings > Privacy & Security > Accessibility, then try again.")
        }
    }
}
