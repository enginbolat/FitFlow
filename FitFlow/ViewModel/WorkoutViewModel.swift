//
//  WorkoutViewModel.swift
//  FitFlow
//
//  Created by Engin on 21.12.2025.
//

import Combine
import Foundation

@MainActor
class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var appState: AppState = .loading
    
    enum AppState {
        case loading
        case loaded
        case failed(Error)
        case empty
    }
    
    private let apiURL = URL(string: "https://placeholder.vercel.app/api/workouts")!
    
    
    func fetchWorkouts() async {
        self.appState = .loading
        
        try? await Task.sleep(nanoseconds: 700_000_000)
        
        let mockData = Workout.mockWorkouts
        
        if mockData.isEmpty {
            self.appState = .empty
        } else {
            self.workouts = mockData
            self.appState = .loaded
        }
    }
}
