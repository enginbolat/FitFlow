//
//  ActivityCardView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct ActivityCardView: View {
    @ObservedObject var healthManager: HealthManager
    
    var body: some View {
        let currentSteps = healthManager.stepCount
        let goal = 10000.0
        let progress = min(Double(currentSteps) / goal, 1.0)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.primaryBrand)
                Text("Günlük Adımlar")
                    .font(.headline)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("\(currentSteps)")
                        .font(.system(size: 44, weight: .heavy, design: .rounded))
                        .foregroundColor(.primaryBrand)
                    Text("Hedef: \(Int(goal)) adım")
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
    ActivityCardView(healthManager: .init())
}
