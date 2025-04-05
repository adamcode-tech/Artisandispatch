import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                TabView(selection: $currentStep) {
                    // Étape 1 : Bienvenue
                    WelcomeStep()
                        .tag(0)
                    
                    // Étape 2 : Informations personnelles
                    PersonalInfoStep(name: $name, email: $email, password: $password)
                        .tag(1)
                    
                    // Étape 3 : Objectifs
                    GoalsStep()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                // Boutons de navigation
                HStack {
                    if currentStep > 0 {
                        Button("Précédent") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if currentStep < 2 {
                        Button("Suivant") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    } else {
                        Button("Commencer") {
                            // Accéder directement à l'application sans délai
                            authManager.isAuthenticated = true
                        }
                        // Ne pas désactiver le bouton pour permettre un accès facile
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
        }
    }
}

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("Bienvenue sur SmartCoach")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Votre coach personnel pour atteindre vos objectifs de fitness")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

struct PersonalInfoStep: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var password: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Créez votre compte")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Nom", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Mot de passe", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
        }
    }
}

struct GoalsStep: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Définissez vos objectifs")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                GoalOption(icon: "figure.walk", title: "Perte de poids")
                GoalOption(icon: "figure.strengthtraining.traditional", title: "Prise de masse")
                GoalOption(icon: "heart.fill", title: "Bien-être général")
                GoalOption(icon: "figure.run", title: "Performance")
            }
            .padding(.horizontal)
        }
    }
}

struct GoalOption: View {
    let icon: String
    let title: String
    @State private var isSelected = false
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.body)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .foregroundColor(.primary)
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthManager())
} 