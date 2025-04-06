import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                // Application principale avec TabView
                ZStack(alignment: .topTrailing) {
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
                        
                        MessagingView()
                            .tabItem {
                                Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                            }
                            .tag(3)
                        
                        NutritionView()
                            .tabItem {
                                Label("Nutrition", systemImage: "fork.knife")
                            }
                            .tag(4)
                        
                        ProfileView()
                            .tabItem {
                                Label("Profil", systemImage: "person.crop.circle")
                            }
                            .tag(5)
                    }
                    .accentColor(Color("PrimaryColor"))
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color("PrimaryColor"))
                            .padding()
                            .background(Circle().fill(Color(.systemBackground)))
                            .shadow(radius: 2)
                    }
                    .padding(.top, 10)
                    .padding(.trailing, 10)
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                }
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
            .environmentObject(WorkoutSessionManager())
    }
} 