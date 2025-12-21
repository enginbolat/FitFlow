//
//  Exercise.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import Foundation

struct Exercise: Identifiable, Codable {
    let id = UUID()
    let name: String
    let sets: Int
    let reps: String
    let video_url: String
    
    private enum CodingKeys: String, CodingKey {
        case name, sets, reps
        case video_url
    }
}
