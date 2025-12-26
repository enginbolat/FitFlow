//
//  Exercise.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import Foundation

struct Exercise: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let sets: String
    let reps: String
    let videoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case name, sets, reps
        case videoUrl = "video_url"
    }
}
