#if DEBUG
import SwiftUI
import Foundation

// Version simplifiée de AuthManager pour les prévisualisations
class PreviewAuthManager: ObservableObject {
    @Published var user: User? = User(id: "preview-user", name: "Utilisateur Preview", email: "test@example.com")
    @Published var isAuthenticated = true
    @Published var isLoading = false
    @Published var error: String? = nil
    
    func signOut() {}
    func signIn(email: String, password: String) {}
    func signUp(email: String, password: String, name: String) {}
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        completion(true, nil)
    }
    
    var currentUser: User? {
        return User(id: "preview-user", name: "Utilisateur Preview", email: "test@example.com")
    }
    
    func createLocalUser(from firebaseUser: Any) -> User {
        return User(id: "preview-user", name: "Utilisateur Preview", email: "test@example.com")
    }
}

// Version simplifiée du WorkoutManager pour les prévisualisations
class PreviewWorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = [
        Workout(
            id: UUID(),
            name: "Full Body Workout",
            description: "Un entraînement complet du corps pour tous les niveaux",
            difficulty: "Intermédiaire",
            duration: 45,
            exercises: [],
            targetMuscles: ["Poitrine", "Dos", "Jambes"],
            equipment: ["Haltères"]
        ),
        Workout(
            id: UUID(),
            name: "Cardio HIIT",
            description: "Entraînement par intervalles à haute intensité",
            difficulty: "Avancé",
            duration: 30,
            exercises: [],
            targetMuscles: ["Cardio", "Jambes", "Corps entier"],
            equipment: ["Aucun"]
        )
    ]
}

// Version simplifiée du NutritionManager pour les prévisualisations
class PreviewNutritionManager: ObservableObject {
    @Published var meals: [String: Any] = [:]
    @Published var nutritionGoals: [String: Any] = [:]
}

// Version simplifiée du CoachManager pour les prévisualisations
class PreviewCoachManager: ObservableObject {
    @Published var coaches: [Coach] = [
        Coach(
            id: "coach1",
            name: "Jean Dupont",
            specialties: ["Musculation", "Perte de poids"],
            experience: 5,
            rating: 4.8,
            reviewCount: 48,
            bio: "Coach certifié avec 5 ans d'expérience",
            hourlyRate: 50,
            availability: ["Lundi", "Mercredi", "Vendredi"],
            profileImage: nil
        ),
        Coach(
            id: "coach2",
            name: "Marie Martin",
            specialties: ["Yoga", "Nutrition"],
            experience: 8,
            rating: 4.9,
            reviewCount: 72,
            bio: "Spécialiste en yoga et nutrition holistique",
            hourlyRate: 60,
            availability: ["Mardi", "Jeudi", "Samedi"],
            profileImage: nil
        )
    ]
}

// Données de prévisualisation pour la messagerie
struct PreviewData {
    static let conversation = Conversation(
        id: UUID(),
        participants: [
            User(id: "user1", name: "Utilisateur", email: "user@example.com"),
            User(id: "coach1", name: "Coach", email: "coach@example.com")
        ],
        lastMessage: Message(
            id: UUID(),
            sender: User(id: "coach1", name: "Coach", email: "coach@example.com"),
            content: "Bonjour, comment puis-je vous aider ?",
            timestamp: Date(),
            isRead: false
        ),
        unreadCount: 1
    )
    
    static let messages = [
        Message(
            id: UUID(),
            sender: User(id: "coach1", name: "Coach", email: "coach@example.com"),
            content: "Bonjour, comment puis-je vous aider ?",
            timestamp: Date().addingTimeInterval(-3600),
            isRead: true
        ),
        Message(
            id: UUID(),
            sender: User(id: "user1", name: "Utilisateur", email: "user@example.com"),
            content: "J'ai besoin d'aide avec mon programme d'entraînement",
            timestamp: Date().addingTimeInterval(-3000),
            isRead: true
        ),
        Message(
            id: UUID(),
            sender: User(id: "coach1", name: "Coach", email: "coach@example.com"),
            content: "Bien sûr, je peux vous aider. Quels sont vos objectifs ?",
            timestamp: Date(),
            isRead: false
        )
    ]
    
    static let conversations = [
        conversation,
        Conversation(
            id: UUID(),
            participants: [
                User(id: "user1", name: "Utilisateur", email: "user@example.com"),
                User(id: "coach2", name: "Marie", email: "marie@example.com")
            ],
            lastMessage: Message(
                id: UUID(),
                sender: User(id: "user1", name: "Utilisateur", email: "user@example.com"),
                content: "Merci pour la séance d'hier",
                timestamp: Date().addingTimeInterval(-86400),
                isRead: true
            ),
            unreadCount: 0
        )
    ]
}

// Structure Coach simplifiée pour les prévisualisations
struct Coach: Identifiable {
    var id: String
    var name: String
    var specialties: [String]
    var experience: Int
    var rating: Double
    var reviewCount: Int
    var bio: String
    var hourlyRate: Double
    var availability: [String]
    var profileImage: URL?
}
#endif 