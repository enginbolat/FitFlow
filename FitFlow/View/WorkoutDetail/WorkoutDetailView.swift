//
//  WorkoutDetailView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct WorkoutDetailView: View {
    @Injected(TrackingServiceProtocol.self) private var trackingManager
    
    let title: String
    let description: String
    let exercises: [ExerciseDisplayModel]
    let nutritionAdvice: String?
    let workoutId: String
    
    init(workout: Workout) {
        self.title = workout.title
        self.description = workout.description
        self.workoutId = String(workout.id)
        self.nutritionAdvice = nil
        self.exercises = workout.exercises.map {
            ExerciseDisplayModel(name: $0.name, sets: "\($0.sets)", reps: "\($0.reps)", videoUrl: "")
        }
    }
    
    init(aiWorkout: DailyWorkout, nutrition: String?) {
        self.title = aiWorkout.title
        self.description = aiWorkout.day
        self.workoutId = aiWorkout.id.uuidString
        self.nutritionAdvice = nutrition
        self.exercises = aiWorkout.exercises.map {
            ExerciseDisplayModel(name: $0.name, sets: $0.sets, reps: $0.reps, videoUrl: $0.videoUrl)
        }
    }

    var body: some View {
        let isCompleted = trackingManager.isWorkoutCompletedToday(id: Int(workoutId.prefix(5).filter(\.isNumber)) ?? 0)
        
        List {
            Section(header: Text(localizable: .generalInformation)) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text(localizable: .focusDay)
                    Spacer()
                    Text(description).foregroundColor(.secondary)
                }
            }
            
            if let advice = nutritionAdvice {
                Section(header: Text(localizable: .aiNutritionAdvice)) {
                    Text(advice)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.primaryBrand)
                }
            }
            
            Section(header: Text(localizable: .exercisesDetails)) {
                ForEach(exercises) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name).font(.headline)
                        HStack {
                            Text(String(format: NSLocalizedString("%@ Set", comment: ""), exercise.sets)).bold()
                            Text("·")
                            Text(String(format: NSLocalizedString("%@ Tekrar", comment: ""), exercise.reps)).foregroundColor(.secondary)
                        }
                        
                        if let url = exercise.videoUrl, let videoURL = URL(string: url) {
                            Link(destination: videoURL) {
                                HStack {
                                    Image(systemName: "play.circle.fill").foregroundColor(.red)
                                    Text(localizable: .watchFormVideo).font(.caption)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle(title)
        
        VStack {
            Button {
                trackingManager.toggleCompletion(for: Int(workoutId.prefix(5).filter(\.isNumber)) ?? 0)
            } label: {
                Text(LocalizedStringKey(isCompleted ? LocalizableEnum.undo.rawValue : LocalizableEnum.completeWorkout.rawValue))
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isCompleted ? Color.orange : Color.primaryBrand)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

struct ExerciseDisplayModel: Identifiable {
    let id = UUID()
    let name: String
    let sets: String
    let reps: String
    let videoUrl: String?
}
#Preview {
    let mockManager = TrackingManager()
    
    WorkoutDetailView(
        workout: .init(
        id: 1,
        title: "title",
        description: "description",
        duration_min: 3,
        image_url: "",
        exercises: []
    )
  )
}
