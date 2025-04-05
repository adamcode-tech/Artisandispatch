import Foundation

enum WorkoutDifficulty: String, Codable, CaseIterable, Identifiable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    
    var id: String { rawValue }
}

enum MuscleGroup: String, Codable, CaseIterable, Identifiable {
    case chest = "Poitrine"
    case back = "Dos"
    case shoulders = "Épaules"
    case legs = "Jambes"
    case arms = "Bras"
    case abs = "Abdominaux"
    case fullBody = "Corps entier"
    
    var id: String { rawValue }
}

enum Equipment: String, Codable, CaseIterable, Identifiable {
    case bodyweight = "Poids du corps"
    case dumbbell = "Haltères"
    case barbell = "Barre"
    case kettlebell = "Kettlebell"
    case resistanceBand = "Élastique"
    case machine = "Machine"
    case bench = "Banc"
    
    var id: String { rawValue }
} 