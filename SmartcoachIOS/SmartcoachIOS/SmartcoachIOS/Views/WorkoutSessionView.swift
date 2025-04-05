import SwiftUI

struct WorkoutSessionView: View {
    @StateObject private var sessionManager = WorkoutSessionManager()
    @Environment(\.dismiss) private var dismiss
    let workout: Workout
    
    var body: some View {
        VStack {
            // En-tête
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(workout.name)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    if sessionManager.isActive {
                        sessionManager.pauseWorkout()
                    } else {
                        sessionManager.resumeWorkout()
                    }
                }) {
                    Image(systemName: sessionManager.isActive ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            // Timer
            Text(timeString(from: sessionManager.elapsedTime))
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .padding()
            
            // Progression
            ProgressView(value: sessionManager.progress)
                .padding(.horizontal)
            
            // Exercice actuel
            if let currentExercise = sessionManager.currentExercise {
                VStack(spacing: 20) {
                    Text(currentExercise.name)
                        .font(.title3)
                        .bold()
                    
                    Text("\(sessionManager.currentSet)/\(currentExercise.sets) séries")
                        .font(.headline)
                    
                    Text("\(currentExercise.reps) répétitions")
                        .font(.subheadline)
                    
                    if sessionManager.isResting {
                        Text("Temps de repos: \(sessionManager.restTimeRemaining)s")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Contrôles
            HStack(spacing: 40) {
                Button(action: { sessionManager.previousExercise() }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                }
                
                Button(action: { sessionManager.nextExercise() }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                }
            }
            .padding()
        }
        .onAppear {
            sessionManager.startWorkout(workout)
        }
        .onDisappear {
            sessionManager.endWorkout()
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    WorkoutSessionView(workout: Workout(
        name: "Entraînement complet",
        description: "Un entraînement complet pour tout le corps",
        difficulty: .intermediate,
        duration: 45,
        exercises: [
            Exercise(
                name: "Pompes",
                description: "Exercice de base pour les pectoraux",
                muscleGroup: .chest,
                sets: 3,
                reps: 12,
                restTime: 30,
                difficulty: .intermediate,
                equipment: .bodyweight,
                instructions: ["Position de départ en planche", "Descendre jusqu'à toucher le sol", "Remonter en poussant"]
            ),
            Exercise(
                name: "Squats",
                description: "Exercice pour les jambes",
                muscleGroup: .legs,
                sets: 3,
                reps: 15,
                restTime: 30,
                difficulty: .beginner,
                equipment: .bodyweight,
                instructions: ["Pieds écartés largeur épaules", "Descendre comme pour s'asseoir", "Remonter en poussant sur les talons"]
            )
        ],
        targetMuscles: [.chest, .arms, .legs],
        equipment: [.bodyweight],
        caloriesBurned: 300
    ))
} 