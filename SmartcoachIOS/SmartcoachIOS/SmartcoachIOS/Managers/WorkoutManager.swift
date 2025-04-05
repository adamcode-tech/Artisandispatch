import Foundation
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var selectedWorkout: Workout?
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        loadWorkouts()
    }
    
    func loadWorkouts() {
        isLoading = true
        
        // Simuler le chargement des données
        let workItem = DispatchWorkItem {
            self.workouts = [
                Workout(
                    id: UUID(),
                    name: "Entraînement complet",
                    description: "Un entraînement complet pour tout le corps",
                    difficulty: .intermediate,
                    duration: 45,
                    exercises: [
                        Exercise(
                            id: UUID(),
                            name: "Développé couché",
                            description: "Exercice de base pour les pectoraux",
                            muscleGroup: .chest,
                            sets: 3,
                            reps: 12,
                            restTime: 60,
                            difficulty: .intermediate,
                            equipment: .barbell,
                            instructions: ["Allongez-vous sur le banc", "Saisissez la barre", "Descendez la barre vers la poitrine", "Remontez la barre"],
                            videoUrl: nil,
                            imageUrl: nil
                        ),
                        Exercise(
                            id: UUID(),
                            name: "Squats",
                            description: "Exercice de base pour les jambes",
                            muscleGroup: .legs,
                            sets: 4,
                            reps: 10,
                            restTime: 90,
                            difficulty: .intermediate,
                            equipment: .barbell,
                            instructions: ["Placez la barre sur vos épaules", "Descendez en position accroupie", "Remontez à la position de départ"],
                            videoUrl: nil,
                            imageUrl: nil
                        )
                    ],
                    targetMuscles: [.chest, .legs],
                    equipment: [.barbell, .bench],
                    caloriesBurned: 400
                )
            ]
            self.isLoading = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
    
    func getWorkout(by id: UUID) -> Workout? {
        workouts.first { $0.id == id }
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
    
    func removeWorkout(_ workout: Workout) {
        workouts.removeAll { $0.id == workout.id }
    }
    
    func updateWorkout(_ workout: Workout) {
        if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
            workouts[index] = workout
        }
    }
    
    func searchWorkouts(query: String) -> [Workout] {
        guard !query.isEmpty else { return workouts }
        return workouts.filter { workout in
            workout.name.localizedCaseInsensitiveContains(query) ||
            workout.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterWorkouts(by difficulty: WorkoutDifficulty? = nil, muscleGroup: MuscleGroup? = nil) -> [Workout] {
        workouts.filter { workout in
            let matchesDifficulty = difficulty == nil || workout.difficulty == difficulty
            let matchesMuscleGroup = muscleGroup == nil || workout.targetMuscles.contains(where: { $0 == muscleGroup })
            return matchesDifficulty && matchesMuscleGroup
        }
    }
} 