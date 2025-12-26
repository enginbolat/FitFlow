//
//  ContentView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        CoordinatorView()
    }
}

#Preview {
    ContentView()
}
