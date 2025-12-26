//
//  TrackingManager.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import HealthKit
import Combine

protocol TrackingServiceProtocol {
    func saveCompletedWorkouts() -> Void
    func loadCompletedWorkouts() -> Void
    func toggleCompletion(for workoutId: Int) -> Void
    func isWorkoutCompletedToday(id: Int) -> Bool
}

@MainActor
class TrackingManager: TrackingServiceProtocol {
    @Published var completedWorkouts: [Int: Date] = [:]
    
    init() { loadCompletedWorkouts() }
    
    func saveCompletedWorkouts() {
        if let encoded = try? JSONEncoder().encode(completedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: StorageEnum.completedWorkouts.rawValue)
        }
    }
    
    func loadCompletedWorkouts() {
        if let savedData = UserDefaults.standard.data(forKey: StorageEnum.completedWorkouts.rawValue),
           let decoded = try? JSONDecoder().decode([Int: Date].self, from: savedData) {
            self.completedWorkouts = decoded
        }
    }
    
    func toggleCompletion(for workoutId: Int) {
        if completedWorkouts[workoutId] != nil && Calendar.current.isDateInToday(completedWorkouts[workoutId]!) {
            completedWorkouts.removeValue(forKey: workoutId)
        } else {
            completedWorkouts[workoutId] = Date()
        }
        saveCompletedWorkouts()
    }
    
    func isWorkoutCompletedToday(id: Int) -> Bool {
        guard let completionDate = completedWorkouts[id] else {
            return false
        }
        return Calendar.current.isDateInToday(completionDate)
    }
}
