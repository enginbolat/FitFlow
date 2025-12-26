//
//  DailyWorkout.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import Foundation

struct DailyWorkout: Codable, Identifiable, Hashable {
    let id = UUID()
    let day: String
    let title: String
    let exercises: [Exercise]
    
    enum CodingKeys: String, CodingKey {
        case day, title, exercises
    }
}
