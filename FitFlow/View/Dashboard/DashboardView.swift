//
//  DashboardView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct DashboardView: View {
    let username: String
    
    @Injected(HealthStoreProtocol.self) private var healthStore
    @Injected(GeminiServiceProtocol.self) private var geminiService
    @Injected(TrackingServiceProtocol.self) private var trackingManager
    @Injected(StorageServiceProtocol.self) private var storageService
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @StateObject private var viewModel: DashboardViewModel
    
  
    init(username: String) {
        self.username = username
        
        let geminiService = DependencyContainer.shared.resolve(GeminiServiceProtocol.self)
        let storageService = DependencyContainer.shared.resolve(StorageServiceProtocol.self)
        let healthStore = DependencyContainer.shared.resolve(HealthStoreProtocol.self)
        let trackingService = DependencyContainer.shared.resolve(TrackingServiceProtocol.self)
        
        let viewModel = DashboardViewModel(
            geminiService: geminiService,
            storageService: storageService,
            healthStore: healthStore,
            trackingService: trackingService
        )
        
        _viewModel = StateObject(wrappedValue: viewModel)
        let _ = storageService.saveToLocal(.hasSeenDashboard, value: true)
    }
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(String(format: NSLocalizedString(LocalizableEnum.hello.rawValue, comment: ""), username))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text(localizable: .todaysProgramAndActivities)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    
                    ActivityCardView()
                        .padding(.horizontal)
                    
                    NutritionGoalCard(goals: viewModel.goals)
                        .padding(.horizontal)
                    
                    Text(localizable: .quickMetrics)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        MetricChip(iconName: "flame.fill",
                                   value: String(format: "%.0f", healthStore.totalActiveEnergy),
                                   unit: .kcal,
                                   label: "Yakılan",
                                   color: .red)
                        .onTapGesture { viewModel.handleRequestOrShowSheet() }
                        
                        MetricChip(iconName: "clock.fill",
                                   value: String(format: "%.0f", healthStore.totalWorkoutDuration),
                                   unit: .dk,
                                   label: "Aktif Süre",
                                   color: .secondaryBrand)
                        
                        MetricChip(iconName: "figure.strengthtraining.traditional",
                                   value: "\(healthStore.todayWorkoutCount)",
                                   unit: .empty,
                                   label: "İdman",
                                   color: .primaryBrand)
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 12) {
                        MetricChip(iconName: "drop.fill",
                                   value: healthStore.bloodType,
                                   unit: .empty,
                                   label: "Kan Grubu",
                                   color: .red)
                        
                        MetricChip(iconName: "person.fill",
                                   value: healthStore.biologicalSex,
                                   unit: .empty,
                                   label: "Cinsiyet",
                                   color: .blue)
                        
                        MetricChip(iconName: "calendar",
                                   value: viewModel.userAge,
                                   unit: .empty,
                                   label: "Yaş",
                                   color: .orange)
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 20) {
                    if viewModel.isLoadingPlan {
                        VStack {
                            ProgressView()
                            Text(localizable: .geminiPreparingProgram)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    } else if let plan = viewModel.workoutPlan {
                        AIWorkoutSection(plan: plan)
                    }
                }.padding(.top, 20)
            }
        .padding(.vertical)
        .onAppear { viewModel.handleOnAppear() }
        .preferredColorScheme(.light)
        .sheet(isPresented: $viewModel.showingCalorieSheet) {
            ActivityLogSheet()
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    DashboardView(username: "")
}
