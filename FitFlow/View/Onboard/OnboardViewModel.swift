//
//  OnboardViewModel.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import Combine
import HealthKit

@MainActor
class OnboardViewModel: ObservableObject {
    let healthStore: HealthStoreProtocol
    @Published var workoutPlan: AIWorkoutResponse? = nil
    @Published var profile = UserProfile()
    @Published var lastError: String?
    
    @Published var isLoadingPlan = false
    @Published var isLoadingHealthData = false
    @Published var step = 1
    
    private let coordinator: AppCoordinator
    private let geminiService: GeminiServiceProtocol
    private let storageService: StorageServiceProtocol
    
    init(
        coordinator: AppCoordinator,
        healthStore: HealthStoreProtocol,
        geminiService: GeminiServiceProtocol,
        storageService: StorageServiceProtocol
    ) {
        self.coordinator = coordinator
        self.healthStore = healthStore
        self.geminiService = geminiService
        self.storageService = storageService
    }
    
    func startGenerationProcess(profile: UserProfile) async {
        isLoadingPlan = true
        
        let prompt = geminiService.generateWorkoutAndMealPlan(profile: profile)
        
        do {
            let plan = try await geminiService.fetchWorkoutPlan(prompt: prompt)
            self.workoutPlan = plan
            let _ = storageService.saveToLocal(.savedWorkoutPlan, value: plan)
        } catch {
            lastError = error.localizedDescription
        }
        isLoadingPlan = false
        coordinator.replace(page: .Dashboard)
    }
    
    private func requestHealthKitAccess() async {
        await healthStore.requestAuthorization()
    }
    
    func nextStep() {
        if step == 1 {
            step = 2
            return
        }
        
        if step == 2 {
            isLoadingHealthData = true
            Task {
                await requestHealthKitAccess()
                
                await MainActor.run {
                    isLoadingHealthData = false
                    
                    profile.height = healthStore.height ?? profile.height
                    profile.weight = healthStore.weight ?? profile.weight
                    
                    if let birthDate = healthStore.birthDate {
                        let calendar = Calendar.current
                        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
                        profile.age = ageComponents.year
                    }
                    
                    let hasAllFields = profile.height != nil &&
                                      profile.height != 0.0 &&
                                      profile.weight != nil &&
                                      profile.weight != 0.0 &&
                                      profile.age != nil &&
                                      profile.age != 0
                    
                    if !hasAllFields {
                        step = 3
                    }
                    else {
                        generatePlan()
                    }
                }
            }
            return
        }
        
        generatePlan()
    }
    
    func generatePlan() {
        profile.height = healthStore.height ?? profile.height
        profile.weight = healthStore.weight ?? profile.weight
        
        if profile.age == nil || profile.age == 0, let birthDate = healthStore.birthDate {
            let calendar = Calendar.current
            let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
            profile.age = ageComponents.year
        }
        
        Task {
            await startGenerationProcess(profile: profile)
        }
    }
}
