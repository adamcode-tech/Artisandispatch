import SwiftUI

struct CoachInfoView: View {
    let coach: Coach
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Bio
            VStack(alignment: .leading, spacing: 8) {
                Text("À propos")
                    .font(.headline)
                Text(coach.bio)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Spécialités
            VStack(alignment: .leading, spacing: 8) {
                Text("Spécialités")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    ForEach(coach.specialties, id: \.self) { specialty in
                        Text(specialty)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color("PrimaryColor").opacity(0.1))
                            .foregroundColor(Color("PrimaryColor"))
                            .cornerRadius(20)
                    }
                }
            }
            
            // Certifications
            VStack(alignment: .leading, spacing: 8) {
                Text("Certifications")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    ForEach(coach.certifications, id: \.self) { certification in
                        Text(certification)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(.gray)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    CoachInfoView(coach: Coach(
        id: "1",
        name: "John Doe",
        experience: 5,
        rating: 4.5,
        hourlyRate: 50,
        specialties: ["Fitness", "Nutrition", "Musculation", "Perte de poids"],
        bio: "Coach professionnel avec 5 ans d'expérience dans le domaine du fitness et de la nutrition. Spécialisé dans la perte de poids et la musculation.",
        certifications: ["NASM", "ACE", "CrossFit Level 1"],
        profileImage: nil
    ))
} 