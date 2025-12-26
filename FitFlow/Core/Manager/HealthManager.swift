//
//  HealthManager.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI
import HealthKit
import Combine

protocol HealthStoreProtocol {
    var stepCount: Int { get set }
    var isAuthorized: Bool { get set }
    var totalActiveEnergy: Double { get set }
    var height: Double? { get set }
    var weight: Double? { get set }
    var todayActivityLogs: [ActivityLog] { get set }
    var totalWorkoutDuration: Double { get set }
    var birthDate: Date? { get set }
    var bloodType: String { get set }
    var biologicalSex: String { get set }
    var skinType: String { get set }
    var weeklyAverageCalories: Double { get set }
    var weeklyAverageSteps: Double { get set }
    var todayWorkoutCount: Int { get set }
    
    func requestAuthorization() async
    func checkAuthorizationStatus()
    func fetchTodaySteps() async
    func fetchTodayActiveEnergy() async
    func fetchWorkoutLogs() async
    func fetchTodayWorkoutStats() async
    func fetchCharacteristics() async
    func fetchLast7DaysData() async
    func fetchHeightAndWeight() async
}

@MainActor
class HealthManager: HealthStoreProtocol {
    let healthStore = HKHealthStore()
    
    @Published var stepCount: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var totalActiveEnergy: Double = 0.0
    @Published var height: Double? = 0.0
    @Published var weight: Double? = 0.0
    @Published var todayActivityLogs: [ActivityLog] = []
    @Published var totalWorkoutDuration: Double = 0.0
    @Published var todayWorkoutCount: Int = 0
    
    @Published var birthDate: Date? = nil
    @Published var bloodType: String = "Bilinmiyor"
    @Published var biologicalSex: String = "Bilinmiyor"
    @Published var skinType: String = "Bilinmiyor"
    @Published var weeklyAverageCalories: Double = 0.0
    @Published var weeklyAverageSteps: Double = 0.0
    
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let workoutType = HKObjectType.workoutType()
    private let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
    private let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    
    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        let dobType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)!
        let sexType = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        let skinType = HKObjectType.characteristicType(forIdentifier: .fitzpatrickSkinType)!
        
        let readTypes: Set<HKObjectType> = [stepType, energyType, workoutType, heightType, weightType, dobType, bloodType, sexType, skinType]
        let shareTypes: Set<HKSampleType> = []
        
        do {
            try await healthStore.requestAuthorization(toShare: shareTypes, read: readTypes)
            self.isAuthorized = true
            
            await fetchTodaySteps()
            await fetchTodayActiveEnergy()
            await fetchTodayWorkoutStats()
            await fetchCharacteristics()
            await fetchHeightAndWeight()
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
            self.isAuthorized = false
        }
    }
    
    func checkAuthorizationStatus() {
        let energyStatus = healthStore.authorizationStatus(for: energyType)
        
        if energyStatus == .sharingAuthorized {
            self.isAuthorized = true
            Task {
                await fetchTodaySteps()
                await fetchTodayActiveEnergy()
                await fetchTodayWorkoutStats()
            }
        } else {
            self.isAuthorized = false
        }
    }
    
    func fetchTodaySteps() async {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let steps = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()
                let value = Int(sum?.doubleValue(for: HKUnit.count()) ?? 0)
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
        
        self.stepCount = steps
    }
    
    func fetchTodayActiveEnergy() async {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let totalKcal = await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()
                let value = sum?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
                continuation.resume(returning: value)
            }
            healthStore.execute(query)
        }
        
        self.totalActiveEnergy = totalKcal
        await fetchWorkoutLogs()
    }
    
    func fetchWorkoutLogs() async {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let logs: [ActivityLog] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, _ in
                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: [])
                    return
                }
                
                let activityLogs: [ActivityLog] = workouts.map { workout in
                    ActivityLog(
                        originalType: workout.workoutActivityType,
                        activityName: workout.workoutActivityType.description,
                        calorieAmount: workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0,
                        duration: workout.duration / 60,
                        date: workout.startDate
                    )
                }
                continuation.resume(returning: activityLogs)
            }
            healthStore.execute(query)
        }
        
        self.todayActivityLogs = logs
    }
    
    func fetchTodayWorkoutStats() async {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let stats = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                guard let workouts = samples as? [HKWorkout] else {
                    continuation.resume(returning: (duration: 0.0, count: 0))
                    return
                }
                
                let totalDuration = workouts.reduce(0.0) { $0 + $1.duration }
                continuation.resume(returning: (duration: totalDuration / 60, count: workouts.count))
            }
            healthStore.execute(query)
        }
        
        self.totalWorkoutDuration = stats.duration
        self.todayWorkoutCount = stats.count
    }
    
    func fetchCharacteristics() async {
        do {
            let birthdayComponents = try healthStore.dateOfBirthComponents()
            self.birthDate = Calendar.current.date(from: birthdayComponents)
            
            let bloodTypeObject = try healthStore.bloodType()
            self.bloodType = formatBloodType(bloodTypeObject.bloodType)
            
            let sexObject = try healthStore.biologicalSex()
            self.biologicalSex = formatSex(sexObject.biologicalSex)
            
            let skinTypeObject = try healthStore.fitzpatrickSkinType()
            self.skinType = formatSkinType(skinTypeObject.skinType)
        } catch {
            print("Error fetching characteristics: \(error.localizedDescription)")
        }
    }
    
    func fetchLast7DaysData() async {
        let now = Date()
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: now)!
        let predicate = HKQuery.predicateForSamples(withStart: sevenDaysAgo, end: now, options: .strictStartDate)
        
        async let avgCalories: Double = withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()
                let value = sum?.doubleValue(for: .kilocalorie()) ?? 0.0
                continuation.resume(returning: value / 7)
            }
            healthStore.execute(query)
        }
        
        async let avgSteps: Double = withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                let sum = result?.sumQuantity()
                let value = sum?.doubleValue(for: .count()) ?? 0.0
                continuation.resume(returning: value / 7)
            }
            healthStore.execute(query)
        }
        
        self.weeklyAverageCalories = await avgCalories
        self.weeklyAverageSteps = await avgSteps
    }
    
    func fetchHeightAndWeight() async {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        async let heightVal: Double? = withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    continuation.resume(returning: sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi)))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
        
        async let weightVal: Double? = withCheckedContinuation { continuation in
            let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
                if let sample = samples?.first as? HKQuantitySample {
                    continuation.resume(returning: sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo)))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            healthStore.execute(query)
        }
        
        self.height = await heightVal
        self.weight = await weightVal
    }
}

//MARK: PRIVATE
extension HealthManager {
    private func formatBloodType(_ type: HKBloodType) -> String {
        switch type {
        case .aPositive: return "A+"
        case .aNegative: return "A-"
        case .bPositive: return "B+"
        case .bNegative: return "B-"
        case .abPositive: return "AB+"
        case .abNegative: return "AB-"
        case .oPositive: return "0+"
        case .oNegative: return "0-"
        default: return "Belirtilmemiş"
        }
    }
    
    private func formatSex(_ sex: HKBiologicalSex) -> String {
        switch sex {
        case .female: return "Kadın"
        case .male: return "Erkek"
        case .other: return "Diğer"
        default: return "Belirtilmemiş"
        }
    }
    
    private func formatSkinType(_ type: HKFitzpatrickSkinType) -> String {
        switch type {
        case .I: return "Tip I (Çok Açık)"
        case .II: return "Tip II (Açık)"
        case .III: return "Tip III (Buğday)"
        case .IV: return "Tip IV (Esmer)"
        case .V: return "Tip V (Koyu Esmer)"
        case .VI: return "Tip VI (Siyah)"
        default: return "Bilinmiyor"
        }
    }
}
