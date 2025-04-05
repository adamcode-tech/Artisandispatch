import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // Application principale avec TabView
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Accueil", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    WorkoutView()
                        .tabItem {
                            Label("Entraînements", systemImage: "figure.run")
                        }
                        .tag(1)
                    
                    CoachSearchView()
                        .tabItem {
                            Label("Coach", systemImage: "person.fill")
                        }
                        .tag(2)
                    
                    NutritionView()
                        .tabItem {
                            Label("Nutrition", systemImage: "fork.knife")
                        }
                        .tag(3)
                    
                    ProfileView()
                        .tabItem {
                            Label("Profil", systemImage: "person.crop.circle")
                        }
                        .tag(4)
                }
                .accentColor(Color("PrimaryColor"))
            } else {
                // Écran d'onboarding
                OnboardingView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthManager())
            .environmentObject(CoachManager())
            .environmentObject(WorkoutManager())
            .environmentObject(NutritionManager())
    }
} 