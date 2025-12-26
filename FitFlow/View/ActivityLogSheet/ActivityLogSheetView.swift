//
//  ActivityLogSheetView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct ActivityLogSheet: View {
    @Injected(HealthStoreProtocol.self) private var healthStore
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(localizable: .caloriesBurnedDetails)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 12)
                .padding(.bottom, 5)
            
            Text(String(format: NSLocalizedString("Toplam: %.1f kcal", comment: ""), healthStore.totalActiveEnergy))
                .font(.headline)
                .foregroundColor(.primaryBrand)
                .padding(.bottom, 15)
            
            if healthStore.todayActivityLogs.isEmpty {
                ContentUnavailableView("Bugün Kayıtlı Antrenman Yok", systemImage: "figure.walk")
                    .frame(height: 200)
            } else {
                List {
                    ForEach(healthStore.todayActivityLogs) { log in
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
            Task {
                await healthStore.fetchTodayActiveEnergy()
            }
        }
    }
}

#Preview {
    ActivityLogSheet()
}

