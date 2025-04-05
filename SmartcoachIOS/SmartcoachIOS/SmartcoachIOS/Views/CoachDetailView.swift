import SwiftUI

struct CoachDetailView: View {
    let coach: Coach
    @State private var showingBookingSheet = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CoachHeaderView(coach: coach)
                CoachInfoView(coach: coach)
                
                // Bouton de réservation
                Button(action: {
                    showingBookingSheet = true
                }) {
                    Text("Réserver une séance")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingBookingSheet) {
            BookingView(
                isPresented: $showingBookingSheet,
                selectedDate: $selectedDate,
                selectedTime: $selectedTime,
                onBooking: {
                    // Logique de réservation
                    print("Réservation confirmée pour le \(selectedDate) à \(selectedTime)")
                }
            )
        }
    }
}

#Preview {
    CoachDetailView(coach: Coach(
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