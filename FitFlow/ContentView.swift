//
//  ContentView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @AppStorage("username") var username: String = ""
    
    var body: some View {
        if username.isEmpty {
            OnboardingView(username: $username)
        } else {
            DashboardView(username: username)
        }
    }
}

#Preview {
    ContentView()
}
