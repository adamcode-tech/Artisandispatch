import SwiftUI

struct BookingView: View {
    @Binding var isPresented: Bool
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    let onBooking: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                DatePicker("Heure", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .padding()
                
                Button(action: {
                    onBooking()
                    isPresented = false
                }) {
                    Text("Confirmer la réservation")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("PrimaryColor"))
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Réserver une séance")
            .navigationBarItems(trailing: Button("Fermer") {
                isPresented = false
            })
        }
    }
}

#Preview {
    BookingView(
        isPresented: .constant(true),
        selectedDate: .constant(Date()),
        selectedTime: .constant(Date()),
        onBooking: {}
    )
} 