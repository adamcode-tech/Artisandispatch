import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var startWorkoutPresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image du workout
                if let imageUrl = workout.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                // Informations principales
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(workout.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        NutritionValueView(title: "Durée", value: String(workout.duration), unit: "min")
                        NutritionValueView(title: "Calories", value: String(workout.caloriesBurned), unit: "kcal")
                        NutritionValueView(title: "Difficulté", value: workout.difficulty.rawValue, unit: "")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Muscles ciblés
                VStack(alignment: .leading, spacing: 16) {
                    Text("Muscles ciblés")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(workout.targetMuscles, id: \.self) { muscle in
                            Text(muscle.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Équipement
                VStack(alignment: .leading, spacing: 16) {
                    Text("Équipement")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(workout.equipment, id: \.self) { equipment in
                            Text(equipment.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Exercices
                VStack(alignment: .leading, spacing: 16) {
                    Text("Exercices")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(workout.exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                }
                
                // Bouton pour commencer l'entraînement
                Button(action: {
                    startWorkoutPresented = true
                }) {
                    Text("Commencer l'entraînement")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    workoutManager.removeWorkout(workout)
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $startWorkoutPresented) {
            WorkoutSessionView(workout: workout)
        }
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                
                Spacer()
                
                Text("\(exercise.sets) × \(exercise.reps)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(exercise.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if !exercise.instructions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(exercise.instructions, id: \.self) { instruction in
                        HStack(alignment: .top) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                            Text(instruction)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutDetailView(workout: Workout(
                id: UUID(),
                name: "Entraînement complet",
                description: "Un entraînement complet pour tout le corps",
                difficulty: .intermediate,
                duration: 45,
                exercises: [
                    Exercise(
                        id: UUID(),
                        name: "Pompes",
                        description: "Exercice de base pour la poitrine",
                        muscleGroup: .chest,
                        sets: 3,
                        reps: 12,
                        restTime: 60,
                        difficulty: .intermediate,
                        equipment: .bodyweight,
                        instructions: ["Position de départ", "Descente", "Remontée"],
                        videoUrl: nil,
                        imageUrl: nil
                    )
                ],
                targetMuscles: [.chest, .back, .legs],
                equipment: [.dumbbell, .bench],
                caloriesBurned: 300
            ))
            .environmentObject(WorkoutManager())
        }
    }
} 