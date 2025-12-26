//
//  UserProfile.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

struct UserProfile: Codable {
    var name: String = ""
    var goal: LocalizableEnum = .weight
    var height: Double? = 0.0
    var weight: Double? = 0.0
    var age: Int? = 0
    var macros: MacroGoals = MacroGoals()
}
