//
//  Coordinator.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI
import Combine

enum Pages: Identifiable, Hashable {
    case Onboarding
    case Dasboard
    case Detail(workout: Workout)
    
    var id: String {
        switch self {
        case .Onboarding: return "Onboarding"
        case .Dasboard: return "Dasboard"
        case .Detail(let workout): return "Detail_\(workout.id)"
        }
    }
}

enum Sheet: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case OnboardingPrivacySheet
    case NetworkConnectivitySheet
}

enum FullScreenCover: String, Identifiable {
    var id: String {
        self.rawValue
    }
    
    case demo
}

class AppCoordinator: ObservableObject {
    // @Injected(StorageServiceProtocol.self) private var storageService
    
    @Published var root: Pages = .Onboarding
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // let value = storageService.get(forKey: .hasSeenOnboarding, as: Bool.self) ?? false
        // if value { root = .Home }
        // else { root = .Onboarding }
        
        setupConnectivityMonitoring()
    }
    
    private func setupConnectivityMonitoring() {
        /* connectivityService.connectivityStatus
            .dropFirst() // Skip initial value
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.presentSheet(.NetworkConnectivitySheet)
                }
            }
            .store(in: &cancellables)
         */
    }
    
    func push(page: Pages) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ cover: FullScreenCover) {
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissCover() {
        self.fullScreenCover = nil
    }
    
    func replace(page: Pages) {
        self.root = page
        self.path = NavigationPath()
    }
    
    func refreshRootBasedOnStorage() {
        /*
         let value = storageService.get(forKey: .hasSeenOnboarding, as: Bool.self) ?? false
         if value {
             root = .Home
         } else {
             root = .Onboarding
         }
         path = NavigationPath()
         */
    }
    
    @ViewBuilder
    func build(page: Pages) -> some View {
        switch page {
            
        // Onboard
        case .Onboarding: OnboardingView(username: .constant(""))
        case .Dasboard: DashboardView(username: "")
        case .Detail(let workout):
            WorkoutDetailView(workout: workout)
        }
    }
        
    @ViewBuilder
    func buildSheet(sheet: Sheet) -> some View {
        switch sheet {
        default:
            EmptyView()
        }
    }
        
    @ViewBuilder
    func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case .demo: EmptyView()
        }
    }
}
