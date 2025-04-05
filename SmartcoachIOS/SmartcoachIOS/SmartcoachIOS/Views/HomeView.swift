import SwiftUI

struct HomeView: View {
    @EnvironmentObject var nutritionManager: NutritionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var coachManager: CoachManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Résumé des statistiques
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        StatCard(
                            icon: "flame.fill",
                            title: "Calories",
                            value: String(format: "%.0f", nutritionManager.getAverageCaloriesPerDay()),
                            unit: "kcal",
                            color: .orange
                        )
                        
                        StatCard(
                            icon: "figure.walk",
                            title: "Activité",
                            value: "45",
                            unit: "min",
                            color: .green
                        )
                        
                        StatCard(
                            icon: "heart.fill",
                            title: "Fréquence",
                            value: "72",
                            unit: "bpm",
                            color: .red
                        )
                    }
                    .padding(.horizontal)
                    
                    // Prochaine séance
                    if let nextWorkout = workoutManager.workouts.first {
                        NavigationLink(destination: WorkoutDetailView(workout: nextWorkout)) {
                            NextWorkoutCard(workout: nextWorkout)
                        }
                    }
                    
                    // Coach recommandé
                    if let recommendedCoach = coachManager.coaches.first {
                        NavigationLink(destination: CoachDetailView(coach: recommendedCoach)) {
                            RecommendedCoachCard(coach: recommendedCoach)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Tableau de bord")
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct NextWorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prochaine séance")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("\(workout.duration) min • \(workout.difficulty.rawValue)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct RecommendedCoachCard: View {
    let coach: Coach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Coach recommandé")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                if let imageUrl = coach.profileImage {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(coach.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(coach.specialties.prefix(2).joined(separator: " • "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environmentObject(NutritionManager())
        .environmentObject(WorkoutManager())
        .environmentObject(CoachManager())
} 