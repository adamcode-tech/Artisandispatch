import Foundation
import SwiftUI
import MapKit
import Combine

class CoachManager: ObservableObject {
    @Published var coaches: [Coach] = []
    @Published var selectedCoach: Coach?
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    init() {
        loadCoaches()
    }
    
    private func loadCoaches() {
        isLoading = true
        let workItem = DispatchWorkItem {
            self.coaches = Coach.sampleCoaches
            self.isLoading = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
    }
    
    func getCoach(by id: String) -> Coach? {
        return coaches.first { $0.id == id }
    }
    
    func searchCoaches(query: String, specialties: [String]? = nil) -> [Coach] {
        var filteredCoaches = coaches
        
        if !query.isEmpty {
            filteredCoaches = filteredCoaches.filter { coach in
                coach.name.localizedCaseInsensitiveContains(query) ||
                coach.specialties.contains { $0.localizedCaseInsensitiveContains(query) }
            }
        }
        
        if let specialties = specialties, !specialties.isEmpty {
            filteredCoaches = filteredCoaches.filter { coach in
                !Set(coach.specialties).isDisjoint(with: Set(specialties))
            }
        }
        
        return filteredCoaches
    }
    
    func getCoachDetails(id: String) {
        isLoading = true
        error = nil
        
        // Simuler la récupération des détails d'un coach
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.selectedCoach = self.coaches.first(where: { $0.id == id })
            self.isLoading = false
        }
    }
    
    func bookSession(coachId: String, date: Date, duration: Int) -> Bool {
        // Simuler la réservation d'une séance
        return true
    }
} 