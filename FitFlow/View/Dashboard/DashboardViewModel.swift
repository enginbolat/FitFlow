//
//  DashboardViewModel.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import Combine

final class DashboardViewModel: ObservableObject {
    let workoutViewModel: WorkoutViewModel
    
    @Published var showingCalorieSheet = false
    @Published var healthManager = HealthManager()
    @Published var trackingManager = TrackingManager()
    
    init(workoutViewModel: WorkoutViewModel) {
        self.workoutViewModel = workoutViewModel
    }
    
    func handleRequestOrShowSheet() {
        if healthManager.isAuthorized {
            showingCalorieSheet = true
        }
        else {
            healthManager.requestAuthorization()
        }
    }
    
    func handleOnAppear() {
        healthManager.checkAuthorizationStatus()
        if !healthManager.isAuthorized { healthManager.requestAuthorization() }
        Task { await workoutViewModel.fetchWorkouts() }
    }
}
