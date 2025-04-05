import SwiftUI

struct CoachHeaderView: View {
    let coach: Coach
    
    var body: some View {
        VStack(spacing: 16) {
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
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 8) {
                Text(coach.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", coach.rating))
                        .font(.headline)
                }
                
                Text("\(coach.experience) ans d'expérience")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("\(coach.hourlyRate)€/heure")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryColor"))
            }
        }
        .padding()
    }
}

#Preview {
    CoachHeaderView(coach: Coach(
        id: "1",
        name: "John Doe",
        experience: 5,
        rating: 4.5,
        hourlyRate: 50,
        specialties: ["Fitness", "Nutrition"],
        bio: "Coach professionnel avec 5 ans d'expérience",
        certifications: ["NASM", "ACE"],
        profileImage: nil
    ))
} 