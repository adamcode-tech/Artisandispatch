import Foundation
import SwiftUI

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
struct UserProfile {
    let id: String
    var displayName: String
    var email: String
    var phoneNumber: String?
    var height: Double?
    var weight: Double?
    var birthDate: Date?
    var gender: Gender?
    var fitnessGoals: [FitnessGoal]
    var fitnessLevel: FitnessLevel
    
    enum Gender: String, CaseIterable {
        case male = "Homme"
        case female = "Femme"
        case other = "Autre"
    }
    
    enum FitnessLevel: String, CaseIterable {
        case beginner = "Débutant"
        case intermediate = "Intermédiaire"
        case advanced = "Avancé"
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