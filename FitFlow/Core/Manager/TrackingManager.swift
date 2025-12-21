//
//  TrackingManager.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import HealthKit
import Combine

@MainActor
class TrackingManager: ObservableObject {
    @Published var completedWorkouts: [Int: Date] = [:]
    private let storageKey = "CompletedWorkouts"
    
    init() { loadCompletedWorkouts() }
    
    func saveCompletedWorkouts() {
        if let encoded = try? JSONEncoder().encode(completedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func loadCompletedWorkouts() {
        if let savedData = UserDefaults.standard.data(forKey: storageKey),
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
