//
//  Workout.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

struct Workout: Identifiable, Codable, Hashable, Equatable {
    let id: Int
    let title: String
    let description: String
    let duration_min: Int
    let image_url: String?
    let exercises: [Exercise]
    
    var isCompleted: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, image_url, exercises
        case duration_min
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(duration_min)
        hasher.combine(image_url)
        hasher.combine(isCompleted)
        exercises.forEach { hasher.combine($0.id) }
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.description == rhs.description &&
        lhs.duration_min == rhs.duration_min &&
        lhs.image_url == rhs.image_url &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.exercises.map { $0.id } == rhs.exercises.map { $0.id }
    }
}
extension Workout {
    static let mockWorkouts: [Workout] = [
        Workout(
            id: 1,
            title: "Pazartesi: Göğüs & Omuz",
            description: "Hacim odaklı, süper setler",
            duration_min: 55,
            image_url: nil,
            exercises: [
                Exercise(name: "Incline Dumbbell Press", sets: 4, reps: "10-12", video_url: "https://www.youtube.com/watch?v=0-X7M93w758"),
                Exercise(name: "Lateral Raise", sets: 3, reps: "15-20", video_url: "https://www.youtube.com/watch?v=s8Yq_gJ2y8Y"),
                Exercise(name: "Triceps Pushdown", sets: 3, reps: "12-15", video_url: "https://www.youtube.com/watch?v=nI-9zJ6kHq4")
            ]
        ),
        Workout(
            id: 2,
            title: "Salı: Bacak & Karın",
            description: "Güç artışı ve merkez bölge dayanıklılığı",
            duration_min: 65,
            image_url: nil,
            exercises: [
                Exercise(name: "Barbell Squat", sets: 5, reps: "5-8", video_url: "https://www.youtube.com/watch?v=ultWc8Rz6vI"),
                Exercise(name: "Romanian Deadlift", sets: 3, reps: "8-10", video_url: "https://www.youtube.com/watch?v=JCXUYuzw7HM"),
                Exercise(name: "Plank", sets: 3, reps: "60 sn", video_url: "https://www.youtube.com/watch?v=ASdvN_X5Mto")
            ]
        ),
        Workout(
            id: 3,
            title: "Çarşamba: Kardiyo & Esneme",
            description: "Aktif dinlenme",
            duration_min: 40,
            image_url: nil,
            exercises: [
                 Exercise(name: "Koşu Bandı (Eğimli)", sets: 1, reps: "30 dk", video_url: "https://www.youtube.com/watch?v=running"),
            ]
        )
    ]
}
