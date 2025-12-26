//
//  WhatIsGoalView.swift
//  FitFlow
//
//  Created by Engin Bolat on 23.12.2025.
//

import SwiftUI

private var goals: [LocalizableEnum] = [.looseWeight, .buildMuscle, .condition]

struct WhatIsGoalView: View {
    @Binding var profileGoal: LocalizableEnum
    
    var body: some View {
        VStack(spacing: 20) {
            Text(localizable: .whatIsYourGoal).font(.title2).bold()
            ForEach(goals, id: \.self) { goal in
                Button(action: { profileGoal = goal }) {
                    Text(localizable: goal)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(profileGoal == goal ? Color.primaryBrand : Color(.secondarySystemBackground))
                        .foregroundColor(profileGoal == goal ? .white : .primary)
                        .cornerRadius(12)
                }
            }
        }
    }
}

#Preview {
    WhatIsGoalView(profileGoal: .constant(.age))
        .padding(20)
}
