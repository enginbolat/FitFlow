//
//  AIWorkoutResponse.swift
//  FitFlow
//
//  Created by Engin Bolat on 22.12.2025.
//

import Foundation

struct MealPlan: Codable {
    let dailyMealPlans: [DailyMealPlan]
    
    enum CodingKeys: String, CodingKey {
        case dailyMealPlans = "daily_meal_plans"
    }
}

struct DailyMealPlan: Codable, Identifiable, Hashable {
    let id = UUID()
    let day: String
    let meals: [Meal]
    
    enum CodingKeys: String, CodingKey {
        case day, meals
    }
}

struct Meal: Codable, Identifiable, Hashable {
    let id = UUID()
    let mealType: String
    let name: String
    let description: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let videoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case mealType = "meal_type"
        case name, description, calories, protein, carbs, fat
        case videoUrl = "video_url"
    }
}

struct AIWorkoutResponse: Codable {
    let weeklyFocus: String
    let nutritionAdvice: String
    let mealPlan: MealPlan
    let dailyPlan: [DailyWorkout]
    
    enum CodingKeys: String, CodingKey {
        case weeklyFocus = "weekly_focus"
        case nutritionAdvice = "nutrition_advice"
        case mealPlan = "meal_plan"
        case dailyPlan = "daily_plan"
    }
}
