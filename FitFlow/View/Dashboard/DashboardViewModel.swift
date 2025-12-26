//
//  DashboardViewModel.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import Combine
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var showingCalorieSheet = false
    @Published var workoutPlan: AIWorkoutResponse? = nil
    @Published var isLoadingPlan = false
    
    private let healthStore: HealthStoreProtocol
    private let trackingService: TrackingServiceProtocol
    private let geminiService: GeminiServiceProtocol
    private let storageService: StorageServiceProtocol
    let goals = MacroGoals()
    
    init(
        geminiService: GeminiServiceProtocol,
        storageService: StorageServiceProtocol,
        healthStore: HealthStoreProtocol,
        trackingService: TrackingServiceProtocol,
    ) {
        self.healthStore = healthStore
        self.trackingService = trackingService
        self.geminiService = geminiService
        self.storageService = storageService
    }
    
    
    func handleRequestOrShowSheet() {
        if healthStore.isAuthorized {
            showingCalorieSheet = true
        } else {
            Task {
                await healthStore.requestAuthorization()
            }
        }
    }
    
    func handleOnAppear() {
        workoutPlan = storageService.getFromLocal(.savedWorkoutPlan, as: AIWorkoutResponse.self)
        Task {
            await healthStore.requestAuthorization()
        }
    }
    
    var userAge: String {
        guard let birthDate = healthStore.birthDate else {
            return "--"
        }
        
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        
        if let year = ageComponents.year {
            return "\(year)"
        }
        
        return "--"
    }
}
