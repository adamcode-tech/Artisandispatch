import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var userProfile: UserProfile?
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    func signIn(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simulation d'une connexion réussie
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentUser = User(id: "1", name: "Utilisateur Test", email: email)
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func signUp(name: String, email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simulation d'une inscription réussie
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.currentUser = User(id: "1", name: name, email: email)
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    func signOut() {
        isAuthenticated = false
        currentUser = nil
        userProfile = nil
    }
    
    func updateProfile(profile: UserProfile) {
        userProfile = profile
    }
} 