//
//  CleanWorkoutRow.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct CleanWorkoutRow: View {
    @EnvironmentObject var trackingManager: TrackingManager
    let workout: Workout
    
    var body: some View {
        let isCompleted = trackingManager.isWorkoutCompletedToday(id: workout.id)
        
        HStack(alignment: .center) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .primaryBrand)
                .onTapGesture {
                    trackingManager.toggleCompletion(for: workout.id)
                }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(workout.title).font(.headline)
                Text("\(workout.duration_min) dakika · \(workout.description)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .opacity(0.6)
        }
        .padding(.vertical, 8)
        .background(Color.cardBackground)
        .opacity(isCompleted ? 0.6 : 1.0)
    }
}

