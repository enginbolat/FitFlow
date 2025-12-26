//
//  FitFlowApp.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

@main
struct FitFlowApp: App {
    
    init() {
        setupDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func setupDependencies() {
        let container = DependencyContainer.shared
        
        container.register(GeminiServiceProtocol.self) {
            GeminiService()
        }
        
        container.register(HealthStoreProtocol.self) {
            HealthManager()
        }
        
        container.register(StorageServiceProtocol.self) {
            StorageManager()
        }
        

        
        container.register(TrackingServiceProtocol.self) {
            TrackingManager()
        }
    }
}
