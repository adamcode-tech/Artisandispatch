import Foundation
import SwiftUI

struct Coach: Identifiable, Codable {
    let id: String
    let name: String
    let experience: Int
    let rating: Double
    let hourlyRate: Double
    let specialties: [String]
    let bio: String
    let certifications: [String]
    let profileImage: URL?
    
    // Computed properties
    var formattedHourlyRate: String {
        return String(format: "%.2f€", hourlyRate)
    }
    
    var formattedRating: String {
        return String(format: "%.1f", rating)
    }
}

// Extension pour les données de test
extension Coach {
    static let sampleCoaches = [
        Coach(
            id: "1",
            name: "Jean Dupont",
            experience: 8,
            rating: 4.8,
            hourlyRate: 60,
            specialties: ["Musculation", "CrossFit", "HIIT"],
            bio: "Coach certifié avec 8 ans d'expérience en musculation et CrossFit. Spécialisé dans les programmes de transformation physique.",
            certifications: ["NASM CPT", "CrossFit Level 2", "TRX Trainer"],
            profileImage: nil
        ),
        Coach(
            id: "2",
            name: "Marie Martin",
            experience: 5,
            rating: 4.6,
            hourlyRate: 50,
            specialties: ["Yoga", "Pilates", "Stretching"],
            bio: "Passionnée par le bien-être et le développement personnel. Je vous accompagne dans votre pratique du yoga et du Pilates.",
            certifications: ["Yoga Alliance RYT-200", "Pilates Mat Instructor"],
            profileImage: nil
        ),
        Coach(
            id: "3",
            name: "Thomas Bernard",
            experience: 10,
            rating: 4.9,
            hourlyRate: 70,
            specialties: ["Nutrition", "Perte de poids", "Remise en forme"],
            bio: "Nutritionniste et coach sportif. Je vous aide à atteindre vos objectifs de perte de poids et de remise en forme de manière durable.",
            certifications: ["Precision Nutrition Level 2", "ACE Certified", "Weight Management Specialist"],
            profileImage: nil
        )
    ]
}

struct CoachReview: Identifiable {
    let id: String
    let userName: String
    let content: String
    let rating: Int
    let date: Date
}

struct Session: Identifiable {
    let id: String
    let title: String
    let date: Date
    let duration: Int
    let type: SessionType
    
    enum SessionType: String {
        case coaching = "Coaching"
        case training = "Entraînement"
        case consultation = "Consultation"
        
        var icon: String {
            switch self {
            case .coaching: return "person.fill"
            case .training: return "figure.run"
            case .consultation: return "message.fill"
            }
        }
    }
} 