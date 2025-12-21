//
//  ActivityLogSheetView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct ActivityLogSheet: View {
    @ObservedObject var healthManager: HealthManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Yakılan Kalori Detayları")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 12)
                .padding(.bottom, 5)
            
            Text("Toplam: \(healthManager.totalActiveEnergy, specifier: "%.1f") kcal")
                .font(.headline)
                .foregroundColor(.primaryBrand)
                .padding(.bottom, 15)
            
            if healthManager.todayActivityLogs.isEmpty {
                ContentUnavailableView("Bugün Kayıtlı Antrenman Yok", systemImage: "figure.walk")
                    .frame(height: 200)
            } else {
                List {
                    ForEach(healthManager.todayActivityLogs) { log in
                        HStack {
                            VStack(alignment: .leading) {
                                HStack(spacing: 2) {
                                    Image(systemName: log.originalType.sfSymbolName)
                                        .foregroundColor(.primaryBrand)
                                        .frame(width: 30, alignment: .leading)
                                    
                                    Text(log.activityName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                Text("\(log.date, style: .time) · \(log.duration ?? 0, specifier: "%.0f") dk")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(log.calorieAmount, specifier: "%.1f") kcal")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .onAppear {
            healthManager.fetchTodayActiveEnergy()
        }
    }
}

#Preview {
    ActivityLogSheet(healthManager: .init())
}

