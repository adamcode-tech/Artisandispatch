import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @State private var showingVideo = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let imageUrl = exercise.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(exercise.name)
                        .font(.title)
                        .bold()
                    
                    Text(exercise.description)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(exercise.sets) séries", systemImage: "number.circle")
                        Spacer()
                        Label("\(exercise.reps) répétitions", systemImage: "repeat")
                        Spacer()
                        Label("\(exercise.restTime)s repos", systemImage: "timer")
                    }
                    .padding(.vertical)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Muscle cible")
                            .font(.headline)
                        Text(exercise.muscleGroup.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Équipement")
                            .font(.headline)
                        Text(exercise.equipment.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Instructions")
                            .font(.headline)
                        ForEach(exercise.instructions, id: \.self) { instruction in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(instruction)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if exercise.videoUrl != nil {
                Button(action: { showingVideo = true }) {
                    Image(systemName: "play.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingVideo) {
            if let videoUrl = exercise.videoUrl {
                VideoPlayerView(url: videoUrl)
            }
        }
    }
}

struct VideoPlayerView: View {
    let url: String
    
    var body: some View {
        // Implémentation du lecteur vidéo
        Text("Lecteur vidéo pour \(url)")
    }
}

#Preview {
    NavigationView {
        ExerciseDetailView(
            exercise: Exercise(
                name: "Développé couché",
                description: "Un exercice fondamental pour développer la poitrine",
                muscleGroup: .chest,
                sets: 3,
                reps: 12,
                restTime: 60,
                difficulty: .intermediate,
                equipment: .barbell,
                instructions: [
                    "Allongez-vous sur le banc",
                    "Saisissez la barre à la largeur des épaules",
                    "Descendez la barre jusqu'à la poitrine",
                    "Remontez la barre en contrôlant le mouvement"
                ]
            )
        )
    }
} 