//
//  MetricChip.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

enum Unit: String, CaseIterable {
    case dk = "dk"
    case kcal = "kcal"
    case empty = ""
}

struct MetricChip: View {
    let iconName: String
    let value: Double
    let unit: Unit
    let label: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: iconName).font(.title2).foregroundColor(color)
            Text("\(value, specifier: "%.0f") \(unit.rawValue)")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.bottom, 2)
            
            Text(label).font(.caption).foregroundColor(.secondary)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

