import SwiftUI

struct WorkoutView: View {
    @StateObject private var workoutManager = WorkoutManager()
    @State private var searchText = ""
    @State private var selectedDifficulty: WorkoutDifficulty?
    @State private var selectedMuscleGroups: Set<MuscleGroup> = []
    
    var filteredWorkouts: [Workout] {
        workoutManager.workouts.filter { workout in
            let matchesSearch = searchText.isEmpty || 
                workout.name.localizedCaseInsensitiveContains(searchText) ||
                workout.description.localizedCaseInsensitiveContains(searchText)
            
            let matchesDifficulty = selectedDifficulty == nil || 
                workout.difficulty == selectedDifficulty
            
            let matchesMuscleGroups = selectedMuscleGroups.isEmpty || 
                !Set(workout.targetMuscles).isDisjoint(with: selectedMuscleGroups)
            
            return matchesSearch && matchesDifficulty && matchesMuscleGroups
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filtres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(WorkoutDifficulty.allCases, id: \.self) { difficulty in
                            FilterChip(
                                title: difficulty.rawValue,
                                isSelected: selectedDifficulty == difficulty,
                                action: {
                                    if selectedDifficulty == difficulty {
                                        selectedDifficulty = nil
                                    } else {
                                        selectedDifficulty = difficulty
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                            FilterChip(
                                title: muscle.rawValue,
                                isSelected: selectedMuscleGroups.contains(muscle),
                                action: {
                                    if selectedMuscleGroups.contains(muscle) {
                                        selectedMuscleGroups.remove(muscle)
                                    } else {
                                        selectedMuscleGroups.insert(muscle)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Liste des entraînements
                List(filteredWorkouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        WorkoutCard(workout: workout)
                    }
                }
            }
            .navigationTitle("Entraînements")
            .searchable(text: $searchText, prompt: "Rechercher un entraînement")
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name)
                .font(.headline)
            
            Text(workout.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(workout.duration) min", systemImage: "clock")
                Spacer()
                Label("\(workout.caloriesBurned) kcal", systemImage: "flame")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(workout.targetMuscles, id: \.self) { muscle in
                        Text(muscle.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 