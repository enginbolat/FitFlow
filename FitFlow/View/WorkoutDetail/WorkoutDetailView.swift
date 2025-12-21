//
//  WorkoutDetailView.swift
//  FitFlow
//
//  Created by Engin Bolat on 16.12.2025.
//

import SwiftUI

struct WorkoutDetailView: View {
    @EnvironmentObject var trackingManager: TrackingManager
    let workout: Workout
    
    var body: some View {
        let isCompleted = trackingManager.isWorkoutCompletedToday(id: workout.id)
        
        List {
            Section(header: Text("Genel Bilgiler")) {
                HStack { Image(systemName: "clock.fill"); Text("Süre:"); Spacer(); Text("\(workout.duration_min) dakika") }
                HStack { Image(systemName: "note.text"); Text("Odak:"); Spacer(); Text(workout.description) }
            }
            
            Section(header: Text("Hareketler & Detaylar")) {
                ForEach(workout.exercises, id: \.id) { exercise in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(exercise.name).font(.headline)
                        HStack {
                            Text("\(exercise.sets) Set").bold()
                            Text("·")
                            Text("\(exercise.reps) Tekrar").foregroundColor(.secondary)
                        }
                        Link(destination: URL(string: exercise.video_url)!) {
                            HStack {
                                Image(systemName: "play.circle.fill").foregroundColor(.red)
                                Text("Form Videosunu İzle").foregroundColor(.secondaryBrand)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.title)
        
        VStack {
            Button {
                trackingManager.toggleCompletion(for: workout.id)
            } label: {
                Text(isCompleted ? "Bugünkü İdmanı Geri Al" : "İdmanı Tamamla")
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

#Preview {
    WorkoutDetailView(
        trackingManager: .init(),
        workout: .init(
        id: 1,
        title: "title",
        description: "description",
        duration_min: 3,
        image_url: "",
        exercises: [
            .init(name: "name", sets: 2, reps: "2", video_url: "")
        ]
    )
  )
}
