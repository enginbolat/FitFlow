//
//  ActivityCardView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct ActivityCardView: View {
    @Injected(HealthStoreProtocol.self) private var healthStore
    
    var body: some View {
        let currentSteps = healthStore.stepCount
        let goal = 10000.0
        var progress: Double {
            let steps = Double(healthStore.stepCount)
            let result = min(steps / goal, 1.0)
            return result
        }
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.primaryBrand)
                Text(localizable: .dailySteps)
                    .font(.headline)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(currentSteps)")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.primaryBrand)
                    Text(String(format: NSLocalizedString(LocalizableEnum.goalSteps.rawValue, comment: ""), Int(goal)))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                CircularProgressView(progress: progress)
            }
        }
        .padding(20)
        .background(Color.cardBackground)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ActivityCardView()
        .environmentObject(AppCoordinator())
}
