import SwiftUI

struct CoachSearchView: View {
    @EnvironmentObject var coachManager: CoachManager
    @State private var searchText = ""
    @State private var selectedSpecialties: Set<String> = []
    @State private var maxPrice: Double = 1000
    @State private var showingFilters = false
    
    var filteredCoaches: [Coach] {
        coachManager.coaches.filter { coach in
            let matchesSearch = searchText.isEmpty || 
                coach.name.localizedCaseInsensitiveContains(searchText) ||
                coach.bio.localizedCaseInsensitiveContains(searchText)
            
            let matchesSpecialties = selectedSpecialties.isEmpty ||
                !Set(coach.specialties).isDisjoint(with: selectedSpecialties)
            
            let matchesPrice = coach.hourlyRate <= maxPrice
            
            return matchesSearch && matchesSpecialties && matchesPrice
        }
    }
    
    var allSpecialties: [String] {
        Array(Set(coachManager.coaches.flatMap { $0.specialties })).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filtres
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(allSpecialties, id: \.self) { specialty in
                            FilterChip(
                                title: specialty,
                                isSelected: selectedSpecialties.contains(specialty),
                                action: {
                                    if selectedSpecialties.contains(specialty) {
                                        selectedSpecialties.remove(specialty)
                                    } else {
                                        selectedSpecialties.insert(specialty)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 10)
                
                // Liste des coachs
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredCoaches) { coach in
                            NavigationLink(destination: CoachDetailView(coach: coach)) {
                                CoachListItem(coach: coach)
                            }
                        }
                    }
                    .padding()
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher un coach")
            .navigationTitle("Rechercher un coach")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    maxPrice: $maxPrice,
                    selectedSpecialties: $selectedSpecialties,
                    allSpecialties: allSpecialties
                )
            }
        }
    }
}

struct CoachListItem: View {
    let coach: Coach
    
    var body: some View {
        HStack(spacing: 15) {
            // Photo de profil
            if let imageUrl = coach.profileImage {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(Color.gray.opacity(0.2))
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Circle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
            }
            
            // Informations du coach
            VStack(alignment: .leading, spacing: 5) {
                Text(coach.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(coach.specialties.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Label("\(coach.experience) ans", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(coach.hourlyRate))€/h")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("PrimaryColor"))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var maxPrice: Double
    @Binding var selectedSpecialties: Set<String>
    let allSpecialties: [String]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Prix maximum par heure")) {
                    VStack {
                        Slider(value: $maxPrice, in: 0...1000, step: 10)
                        Text("\(Int(maxPrice))€")
                            .font(.headline)
                    }
                }
                
                Section(header: Text("Spécialités")) {
                    ForEach(allSpecialties, id: \.self) { specialty in
                        Toggle(specialty, isOn: Binding(
                            get: { selectedSpecialties.contains(specialty) },
                            set: { isSelected in
                                if isSelected {
                                    selectedSpecialties.insert(specialty)
                                } else {
                                    selectedSpecialties.remove(specialty)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Filtres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CoachSearchView_Previews: PreviewProvider {
    static var previews: some View {
        CoachSearchView()
            .environmentObject(CoachManager())
    }
} 