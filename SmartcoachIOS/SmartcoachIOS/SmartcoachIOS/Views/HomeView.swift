import SwiftUI

struct HomeView: View {
    @EnvironmentObject var nutritionManager: NutritionManager
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var coachManager: CoachManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // En-tête avec statistiques
                    ZStack(alignment: .bottom) {
                        // Bannière avec image de fond
                        Rectangle()
                            .fill(Color("PrimaryColor").gradient)
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                Image(systemName: "figure.run")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundColor(Color.white.opacity(0.2))
                                    .offset(x: 120)
                            )
                        
                        // Texte de bienvenue
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bonjour !")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Prêt à vous dépasser aujourd'hui ?")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal)
                    
                    // Résumé des statistiques
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
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
                            color: Color("GreenAccent")
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
                    Text("Votre programme fitness")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if let nextWorkout = workoutManager.workouts.first {
                        NavigationLink(destination: WorkoutDetailView(workout: nextWorkout)) {
                            NextWorkoutCard(workout: nextWorkout)
                        }
                    }
                    
                    // Coach recommandé
                    Text("Coach recommandé")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if let recommendedCoach = coachManager.coaches.first {
                        NavigationLink(destination: CoachDetailView(coach: recommendedCoach)) {
                            RecommendedCoachCard(coach: recommendedCoach)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color("BackgroundColor").edgesIgnoringSafeArea(.all))
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
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct NextWorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                
                // Badge difficulté
                Text(workout.difficulty.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(difficultyColor(workout.difficulty).opacity(0.1))
                    .foregroundColor(difficultyColor(workout.difficulty))
                    .cornerRadius(8)
            }
            
            Divider()
            
            HStack {
                // Icônes montrant les groupes musculaires ciblés
                ForEach(workout.targetMuscles.prefix(3), id: \.self) { muscle in
                    Text(muscle.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color("PrimaryColor").opacity(0.1))
                        .foregroundColor(Color("PrimaryColor"))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                // Bouton pour commencer
                Text("Commencer")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // Couleur selon la difficulté
    func difficultyColor(_ difficulty: WorkoutDifficulty) -> Color {
        switch difficulty {
        case .beginner:
            return Color("GreenAccent")
        case .intermediate:
            return Color.orange
        case .advanced:
            return Color.red
        }
    }
}

struct RecommendedCoachCard: View {
    let coach: Coach
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageUrl = coach.profileImage {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(Color("SecondaryColor").opacity(0.2))
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color("PrimaryColor"), lineWidth: 2)
                )
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .foregroundColor(Color("SecondaryColor").opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(Color("PrimaryColor"), lineWidth: 2)
                    )
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(coach.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                // Affichage des étoiles
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < 4 ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                    Text("4.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(coach.specialties.prefix(2).joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Bouton réserver
            VStack {
                Text("Réserver")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color("GreenAccent"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
        .environmentObject(NutritionManager())
        .environmentObject(WorkoutManager())
        .environmentObject(CoachManager())
} 