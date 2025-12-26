//
//  NutritionGoalCard.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import SwiftUI

struct NutritionGoalCard: View {
    let goals: MacroGoals
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localizable: .dailyNutritionGoal)
                .font(.headline)
            
            HStack(spacing: 15) {
                MacroIndicator(label: "Prot", value: "\(goals.protein)g", color: .orange)
                MacroIndicator(label: "Karb", value: "\(goals.carbs)g", color: .blue)
                MacroIndicator(label: "Yağ", value: "\(goals.fat)g", color: .yellow)
                MacroIndicator(label: "Kcal", value: "\(goals.calories)", color: .red)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    NutritionGoalCard(goals: MacroGoals())
}
