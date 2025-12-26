//
//  OnboardingView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardViewModel
    
    @Injected(HealthStoreProtocol.self) private var healthStore
    @Injected(GeminiServiceProtocol.self) private var geminiService
    @Injected(TrackingServiceProtocol.self) private var trackingManager
    @Injected(StorageServiceProtocol.self) private var storageService

    init(coordinator: AppCoordinator) {
        let geminiService = DependencyContainer.shared.resolve(GeminiServiceProtocol.self)
        let storageService = DependencyContainer.shared.resolve(StorageServiceProtocol.self)
        let healthStore = DependencyContainer.shared.resolve(HealthStoreProtocol.self)
        
        let viewModel = OnboardViewModel(
            coordinator: coordinator,
            healthStore: healthStore,
            geminiService: geminiService,
            storageService: storageService
        )
        
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                ProgressView(value: Double(viewModel.step), total: 4)
                    .padding()
                    .tint(.green)
                
                switch viewModel.step {
                    case 2: WhatIsGoalView(
                        profileGoal: $viewModel.profile.goal
                    )
                    case 3: PhysicalInfoView(
                        height: $viewModel.profile.height,
                        weight: $viewModel.profile.weight,
                        age: $viewModel.profile.age,
                        isButtonDisabled: (viewModel.isLoadingPlan || viewModel.isLoadingHealthData)
                    )
                    default: PersonalInfoView(
                        name: $viewModel.profile.name
                    )
                }
                
                Spacer()
                
                Button(action: viewModel.nextStep) {
                    VStack {
                        if viewModel.isLoadingPlan || viewModel.isLoadingHealthData {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(LocalizedStringKey(viewModel.step == 3 ? LocalizableEnum.prepareProgram.rawValue : LocalizableEnum.continueButton.rawValue))
                                .bold()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBrand)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoadingPlan || viewModel.isLoadingHealthData)
            }
            .padding()
            
            if(viewModel.isLoadingHealthData) {
                LoaderView()
            }
            
            if(viewModel.isLoadingPlan) {
                Color.gray.opacity(0.5)
                    .blur(radius: 5)
                    .ignoresSafeArea()

                AILoadingView()
                    .allowsHitTesting(false)
            }
        }
    }
}

 
 #Preview {
     let coordinator = AppCoordinator()
     
     OnboardingView(coordinator: coordinator)
 }

