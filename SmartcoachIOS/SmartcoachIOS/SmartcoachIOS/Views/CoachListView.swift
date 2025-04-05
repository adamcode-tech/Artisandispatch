import SwiftUI

struct CoachListView: View {
    @State private var searchText = ""
    @State private var selectedSpecialty: String?
    
    let specialties = ["Tous", "Musculation", "CrossFit", "HIIT", "Yoga", "Pilates", "Nutrition", "Perte de poids"]
    
    var filteredCoaches: [Coach] {
        let coaches = Coach.sampleCoaches
        
        if searchText.isEmpty && selectedSpecialty == nil || selectedSpecialty == "Tous" {
            return coaches
        }
        
        return coaches.filter { coach in
            let matchesSearch = searchText.isEmpty || 
                coach.name.localizedCaseInsensitiveContains(searchText) ||
                coach.specialties.contains { $0.localizedCaseInsensitiveContains(searchText) }
            
            let matchesSpecialty = selectedSpecialty == nil || selectedSpecialty == "Tous" ||
                coach.specialties.contains(selectedSpecialty!)
            
            return matchesSearch && matchesSpecialty
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Barre de recherche
                SearchBar(text: $searchText)
                    .padding()
                
                // Filtres par spécialité
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(specialties, id: \.self) { specialty in
                            SpecialtyFilterButton(
                                specialty: specialty,
                                isSelected: specialty == selectedSpecialty,
                                action: { selectedSpecialty = specialty }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Liste des coachs
                if filteredCoaches.isEmpty {
                    EmptyStateView()
                } else {
                    List(filteredCoaches) { coach in
                        NavigationLink(destination: CoachDetailView(coach: coach)) {
                            CoachRowView(coach: coach)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Coachs")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Rechercher un coach...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct SpecialtyFilterButton: View {
    let specialty: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(specialty)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color("PrimaryColor") : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct CoachRowView: View {
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
                    .font(.headline)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(coach.formattedRating)
                        .font(.subheadline)
                    Text("•")
                    Text("\(coach.experience) ans")
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
                
                Text(coach.specialties.prefix(2).joined(separator: " • "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(coach.formattedHourlyRate)
                .font(.headline)
                .foregroundColor(Color("PrimaryColor"))
        }
        .padding(.vertical, 8)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Aucun coach trouvé")
                .font(.headline)
            
            Text("Essayez de modifier vos critères de recherche")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    CoachListView()
} 