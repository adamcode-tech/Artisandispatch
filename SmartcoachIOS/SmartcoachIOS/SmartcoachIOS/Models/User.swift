import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

struct User: Identifiable {
    var id: String
    var name: String
    var email: String
    var profileImage: String?
    
    init(id: String, name: String, email: String, profileImage: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImage = profileImage
    }
}

// Modèles plus détaillés pour une utilisation future
struct UserProfile: Codable, Identifiable {
    var id: String              // UID Firebase
    var name: String
    var email: String
    var photoURL: String?
    var createdAt: Date?
    var lastLogin: Date?
    var height: Double?         // en cm
    var weight: Double?         // en kg
    var age: Int?
    var gender: String?         // "male", "female", "other"
    var activityLevel: String?  // "sedentary", "light", "moderate", "active", "very_active"
    var fitnessGoal: String?    // "lose_weight", "maintain", "build_muscle", "improve_fitness"
    var workoutIds: [String]
    var nutritionIds: [String]
    var settings: UserSettings
    var stats: UserStats
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.workoutIds = []
        self.nutritionIds = []
        self.settings = UserSettings()
        self.stats = UserStats()
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.id = document.documentID
        self.name = data["name"] as? String ?? "Utilisateur"
        self.email = data["email"] as? String ?? ""
        self.photoURL = data["photoURL"] as? String
        
        // Conversion des timestamps Firestore en Date
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        }
        
        if let timestamp = data["lastLogin"] as? Timestamp {
            self.lastLogin = timestamp.dateValue()
        }
        
        self.height = data["height"] as? Double
        self.weight = data["weight"] as? Double
        self.age = data["age"] as? Int
        self.gender = data["gender"] as? String
        self.activityLevel = data["activityLevel"] as? String
        self.fitnessGoal = data["fitnessGoal"] as? String
        
        // Récupération des tableaux d'IDs
        self.workoutIds = data["workouts"] as? [String] ?? []
        self.nutritionIds = data["nutrition"] as? [String] ?? []
        
        // Récupération des objets imbriqués
        if let settingsData = data["settings"] as? [String: Any] {
            self.settings = UserSettings(data: settingsData)
        } else {
            self.settings = UserSettings()
        }
        
        if let statsData = data["stats"] as? [String: Any] {
            self.stats = UserStats(data: statsData)
        } else {
            self.stats = UserStats()
        }
    }
    
    func toFirestoreData() -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "email": email,
            "workouts": workoutIds,
            "nutrition": nutritionIds,
            "settings": settings.toFirestoreData(),
            "stats": stats.toFirestoreData()
        ]
        
        // Ajouter les champs optionnels seulement s'ils existent
        if let photoURL = photoURL {
            data["photoURL"] = photoURL
        }
        
        if let height = height {
            data["height"] = height
        }
        
        if let weight = weight {
            data["weight"] = weight
        }
        
        if let age = age {
            data["age"] = age
        }
        
        if let gender = gender {
            data["gender"] = gender
        }
        
        if let activityLevel = activityLevel {
            data["activityLevel"] = activityLevel
        }
        
        if let fitnessGoal = fitnessGoal {
            data["fitnessGoal"] = fitnessGoal
        }
        
        return data
    }
}

// Structure pour les paramètres utilisateur
struct UserSettings: Codable {
    var notifications: Bool
    var darkMode: Bool
    var language: String
    var units: String // "metric" ou "imperial"
    var liveActivityEnabled: Bool
    
    init() {
        self.notifications = true
        self.darkMode = false
        self.language = "fr"
        self.units = "metric"
        self.liveActivityEnabled = true
    }
    
    init(data: [String: Any]) {
        self.notifications = data["notifications"] as? Bool ?? true
        self.darkMode = data["darkMode"] as? Bool ?? false
        self.language = data["language"] as? String ?? "fr"
        self.units = data["units"] as? String ?? "metric"
        self.liveActivityEnabled = data["liveActivityEnabled"] as? Bool ?? true
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "notifications": notifications,
            "darkMode": darkMode,
            "language": language,
            "units": units,
            "liveActivityEnabled": liveActivityEnabled
        ]
    }
}

// Structure pour les statistiques utilisateur
struct UserStats: Codable {
    var workoutsCompleted: Int
    var totalWorkoutTime: TimeInterval
    var caloriesBurned: Double
    var workoutStreak: Int
    var personalRecords: [String: Double]
    
    init() {
        self.workoutsCompleted = 0
        self.totalWorkoutTime = 0
        self.caloriesBurned = 0
        self.workoutStreak = 0
        self.personalRecords = [:]
    }
    
    init(data: [String: Any]) {
        self.workoutsCompleted = data["workoutsCompleted"] as? Int ?? 0
        self.totalWorkoutTime = data["totalWorkoutTime"] as? TimeInterval ?? 0
        self.caloriesBurned = data["caloriesBurned"] as? Double ?? 0
        self.workoutStreak = data["workoutStreak"] as? Int ?? 0
        self.personalRecords = data["personalRecords"] as? [String: Double] ?? [:]
    }
    
    func toFirestoreData() -> [String: Any] {
        return [
            "workoutsCompleted": workoutsCompleted,
            "totalWorkoutTime": totalWorkoutTime,
            "caloriesBurned": caloriesBurned,
            "workoutStreak": workoutStreak,
            "personalRecords": personalRecords
        ]
    }
}

enum FitnessGoal: String, CaseIterable {
    case weightLoss = "Perte de poids"
    case muscleGain = "Prise de masse"
    case endurance = "Endurance"
    case flexibility = "Souplesse"
    case generalHealth = "Santé générale"
}

enum DietaryPreference: String, CaseIterable {
    case omnivore = "Omnivore"
    case vegetarian = "Végétarien"
    case vegan = "Végétalien"
    case glutenFree = "Sans gluten"
    case dairyFree = "Sans produits laitiers"
} 