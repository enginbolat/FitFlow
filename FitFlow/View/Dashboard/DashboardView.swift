//
//  DashboardView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    let username: String
    @StateObject private var workoutViewModel = WorkoutViewModel()
    @StateObject private var viewModel: DashboardViewModel
    
    init(username: String, viewModel: DashboardViewModel? = nil) {
        self.username = username
        
        if let injectedViewModel = viewModel {
            _viewModel = StateObject(wrappedValue: injectedViewModel)
        } else {
            let workoutVM = WorkoutViewModel()
            _workoutViewModel = StateObject(wrappedValue: workoutVM)
            _viewModel = StateObject(wrappedValue: DashboardViewModel(workoutViewModel: workoutVM))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Merhaba, \(username) 👋")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        Text("Bugünkü Program ve Aktiviten")
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    

                    ActivityCardView(healthManager: viewModel.healthManager)
                        .padding(.horizontal)
                    
                    Text("Hızlı Metrikler")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    HStack {
                        MetricChip(iconName: "flame.fill", value: viewModel.healthManager.totalActiveEnergy,unit: .kcal, label: "Yakılan Kalori", color: .red)
                            .onTapGesture { viewModel.handleRequestOrShowSheet() }
                        MetricChip(iconName: "clock.fill", value: viewModel.healthManager.totalWorkoutDuration, unit: .dk, label: "Aktif Süre", color: .secondaryBrand)
                        MetricChip(iconName: "figure.strengthtraining.traditional", value: Double(viewModel.healthManager.todayWorkoutCount), unit: .empty, label: "İdman Sayısı", color: .primaryBrand)
                    }
                    .padding(.horizontal)
                    
                    Text("Program Listesi")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding([.horizontal, .top])
                    
                    Group {
                        switch workoutViewModel.appState {
                        case .loading:
                            ProgressView("Programlar Yükleniyor...")
                                .controlSize(.large).padding(.top, 50).frame(maxWidth: .infinity)
                        case .failed(let error):
                            ErrorView(error: error) { Task { await workoutViewModel.fetchWorkouts() } }
                        case .loaded:
                            LazyVStack(spacing: 12) {
                                ForEach(workoutViewModel.workouts) { workout in
                                    CleanWorkoutRow(workout: workout)
                                        .onTapGesture { coordinator.push(page: .Detail(workout: workout)) }
                                }
                            }
                            .padding(.horizontal)
                            .refreshable { Task { await workoutViewModel.fetchWorkouts() } }
                        case .empty:
                            ContentUnavailableView("Program Yok", systemImage: "xmark.octagon.fill")
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .environmentObject(viewModel.trackingManager)
        .onAppear { viewModel.handleOnAppear() }
        .preferredColorScheme(.light)
        .sheet(isPresented: $viewModel.showingCalorieSheet) {
            ActivityLogSheet(healthManager: viewModel.healthManager)
                .presentationDetents([.medium])
        }
    }
}

