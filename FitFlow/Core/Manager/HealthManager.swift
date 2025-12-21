//
//  HealthManager.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI
import HealthKit
import Combine

@MainActor
class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var stepCount: Int = 0
    @Published var isAuthorized: Bool = false
    @Published var totalActiveEnergy: Double = 0.0
    @Published var todayActivityLogs: [ActivityLog] = []
    @Published var totalWorkoutDuration: Double = 0.0
    @Published var todayWorkoutCount: Int = 0
    
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let workoutType = HKObjectType.workoutType()
        
        let readTypes: Set<HKObjectType> = [stepType, energyType, workoutType]
        
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.fetchTodaySteps()
                    self.fetchTodayActiveEnergy()
                    self.fetchTodayWorkoutStats()
                }
            }
        }
    }
    
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    func checkAuthorizationStatus() {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let energyStatus = healthStore.authorizationStatus(for: energyType)
        
        DispatchQueue.main.async {
            if energyStatus == .sharingAuthorized {
                self.isAuthorized = true
                
                self.fetchTodaySteps()
                self.fetchTodayActiveEnergy()
                self.fetchTodayWorkoutStats()
                
            } else {
                self.isAuthorized = false
            }
        }
    }
    
    func fetchTodaySteps() {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            DispatchQueue.main.async { self.stepCount = steps }
        }
        healthStore.execute(query)
    }
    
    func fetchTodayActiveEnergy() {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            let totalKcal = sum.doubleValue(for: HKUnit.kilocalorie())
            
            DispatchQueue.main.async {
                self.totalActiveEnergy = totalKcal
            }
        }
        healthStore.execute(query)
        fetchWorkoutLogs()
    }
    
    func fetchWorkoutLogs() {
        let workoutType = HKObjectType.workoutType()
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            
            guard let workouts = samples as? [HKWorkout] else { return }
            
            let logs: [ActivityLog] = workouts.map { workout in
                return ActivityLog(
                    originalType: workout.workoutActivityType,
                    activityName: workout.workoutActivityType.description,
                    calorieAmount: workout.totalEnergyBurned?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0,
                    duration: workout.duration / 60,
                    date: workout.startDate
                )
            }
            
            DispatchQueue.main.async {
                self.todayActivityLogs = logs
            }
        }
        healthStore.execute(query)
    }
    
    func fetchTodayWorkoutStats() {
        let workoutType = HKObjectType.workoutType()
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKSampleQuery(sampleType: workoutType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            
            guard let workouts = samples as? [HKWorkout] else {
                DispatchQueue.main.async {
                    self.totalWorkoutDuration = 0
                    self.todayWorkoutCount = 0
                }
                return
            }
            
            let totalDuration = workouts.reduce(0.0) { (sum, workout) -> Double in
                return sum + workout.duration
            }
            
            DispatchQueue.main.async {
                self.totalWorkoutDuration = totalDuration / 60
                self.todayWorkoutCount = workouts.count
            }
        }
        healthStore.execute(query)
    }
}

extension HKWorkoutActivityType: @retroactive CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .americanFootball: return "Amerikan Futbolu"
        case .archery: return "Okçuluk"
        case .australianFootball: return "Avustralya Futbolu"
        case .badminton: return "Badminton"
        case .baseball: return "Beyzbol"
        case .basketball: return "Basketbol"
        case .bowling: return "Bovling"
        case .boxing: return "Boks"
        case .climbing: return "Tırmanma"
        case .cricket: return "Kriket"
        case .crossTraining: return "Karma Antrenman"
        case .curling: return "Körling"
        case .cycling: return "Bisiklet"
        case .elliptical: return "Eliptik"
        case .equestrianSports: return "Binicilik Sporları"
        case .fencing: return "Eskrim"
        case .fishing: return "Balıkçılık"
        case .functionalStrengthTraining: return "Fonksiyonel Kuvvet Antrenmanı"
        case .golf: return "Golf"
        case .gymnastics: return "Jimnastik"
        case .handball: return "Hentbol"
        case .hiking: return "Doğa Yürüyüşü (Hiking)"
        case .hockey: return "Hokey"
        case .hunting: return "Avcılık"
        case .lacrosse: return "Lakros"
        case .martialArts: return "Dövüş Sanatları"
        case .mindAndBody: return "Zihin ve Vücut"
        case .paddleSports: return "Kürek Sporları"
        case .play: return "Oyun"
        case .preparationAndRecovery: return "Hazırlık ve Toparlanma"
        case .racquetball: return "Raket Sporları"
        case .rowing: return "Kürek Çekme"
        case .rugby: return "Ragbi"
        case .running: return "Koşu"
        case .sailing: return "Yelkencilik"
        case .skatingSports: return "Paten Sporları"
        case .snowSports: return "Kar Sporları"
        case .soccer: return "Futbol"
        case .softball: return "Softbol"
        case .squash: return "Squash"
        case .stairClimbing: return "Merdiven Tırmanma"
        case .surfingSports: return "Sörf Sporları"
        case .swimming: return "Yüzme"
        case .tableTennis: return "Masa Tenisi"
        case .tennis: return "Tenis"
        case .trackAndField: return "Atletizm"
        case .traditionalStrengthTraining: return "Geleneksel Kuvvet Antrenmanı"
        case .volleyball: return "Voleybol"
        case .walking: return "Yürüyüş"
        case .waterFitness: return "Su Fitnessı"
        case .waterPolo: return "Su Topu"
        case .waterSports: return "Su Sporları"
        case .wrestling: return "Güreş"
        case .yoga: return "Yoga"
        case .barre: return "Barre"
        case .coreTraining: return "Merkez Bölge Antrenmanı (Core)"
        case .crossCountrySkiing: return "Kros Kayağı"
        case .downhillSkiing: return "Alp Kayağı"
        case .flexibility: return "Esneklik Antrenmanı"
        case .highIntensityIntervalTraining: return "HIIT (Yüksek Yoğunluk)"
        case .jumpRope: return "İp Atlama"
        case .kickboxing: return "Kickboks"
        case .pilates: return "Pilates"
        case .snowboarding: return "Snowboard"
        case .stairs: return "Merdiven"
        case .stepTraining: return "Adım Antrenmanı"
        case .wheelchairWalkPace: return "Tekerlekli Sandalye (Yürüme Hızı)"
        case .wheelchairRunPace: return "Tekerlekli Sandalye (Koşu Hızı)"
        case .taiChi: return "Tai Chi"
        case .mixedCardio: return "Karma Kardiyo"
        case .handCycling: return "El Bisikleti"
        case .discSports: return "Disk Sporları"
        case .fitnessGaming: return "Fitness Oyunu"
        case .cardioDance: return "Kardiyo Dans"
        case .socialDance: return "Sosyal Dans"
        case .pickleball: return "Turşu Topu (Pickleball)"
        case .cooldown: return "Soğuma"
        case .swimBikeRun: return "Yüzme, Bisiklet, Koşu (Triatlon)"
        case .transition: return "Geçiş"
        case .underwaterDiving: return "Sualtı Dalışı"

        case .dance: return "Dans (Eski)"
        case .danceInspiredTraining: return "Danstan İlham Alan Antrenman (Eski)"
        case .mixedMetabolicCardioTraining: return "Karma Metabolik Kardiyo (Eski)"

        case .other: return "Diğer Aktivite"
        default: return "Bilinmeyen Aktivite (\(rawValue))"
        }
    }
}


extension HKWorkoutActivityType {
    var sfSymbolName: String {
        switch self {

        case .americanFootball: return "figure.american.football"
        case .australianFootball: return "figure.australian.football"
        case .baseball: return "baseball"
        case .basketball: return "figure.basketball"
        case .cricket: return "figure.cricket"
        case .soccer: return "figure.soccer"
        case .softball: return "figure.softball"
        case .volleyball: return "figure.volleyball"
        case .handball: return "figure.handball"
        case .lacrosse: return "figure.lacrosse"
        case .rugby: return "figure.rugby"
        case .waterPolo: return "figure.water.polo"

        case .traditionalStrengthTraining, .functionalStrengthTraining: return "dumbbell"
        case .coreTraining: return "figure.core.training"
        case .crossTraining, .mixedCardio: return "figure.mix"
        case .highIntensityIntervalTraining: return "flame"
        case .kickboxing, .boxing, .martialArts, .wrestling: return "figure.boxing"
        case .preparationAndRecovery, .cooldown: return "figure.cooldown"
        case .flexibility: return "figure.flexibility"
            
        case .running: return "figure.run"
        case .walking: return "figure.walk"
        case .stairClimbing, .stairs: return "figure.stairs"
        case .hiking: return "figure.hiking"
        case .elliptical: return "figure.elliptical"
        case .jumpRope: return "figure.jump.rope"
        case .cycling, .handCycling: return "figure.outdoor.cycle"
        case .wheelchairWalkPace, .wheelchairRunPace: return "figure.roll"
        case .trackAndField: return "figure.track.and.field"

        case .swimming: return "figure.pool.swim"
        case .waterFitness: return "figure.water.fitness"
        case .waterSports: return "figure.water.pipe"
        case .underwaterDiving: return "figure.dive"
        case .surfingSports: return "figure.surfing"
        case .paddleSports: return "figure.sailing"
        
        case .snowSports: return "figure.skiing"
        case .crossCountrySkiing: return "figure.crosscountry.skiing"
        case .downhillSkiing: return "figure.skiing.downhill"
        case .snowboarding: return "figure.snowboarding"
        case .climbing: return "figure.climbing"
        case .fishing, .hunting: return "figure.outdoor.hang"
        
        case .yoga, .pilates, .barre: return "figure.yoga"
        case .mindAndBody, .taiChi: return "figure.mind.and.body"
        case .dance, .socialDance, .cardioDance, .danceInspiredTraining: return "figure.dance"
        case .gymnastics: return "figure.gymnastics"
        
        case .tennis, .tableTennis, .squash, .badminton, .racquetball, .pickleball: return "figure.tennis"

        case .archery: return "figure.archery"
        case .bowling: return "figure.bowling"
        case .curling: return "figure.curling"
        case .equestrianSports: return "figure.equestrian.sports"
        case .fencing: return "figure.fencing"
        case .golf: return "figure.golf"
        case .rowing: return "figure.rower"
        case .sailing: return "figure.sailing"
        case .skatingSports: return "figure.skating"
        case .discSports: return "figure.disc.sports"
        case .fitnessGaming: return "figure.fall"
        case .play: return "figure.and.child.holdinghands"
        case .swimBikeRun, .transition: return "figure.mixed.cardio"
        
        case .mixedMetabolicCardioTraining: return "figure.mix"
        case .other: return "questionmark.circle"
        default: return "figure.activity"
        }
    }
}
