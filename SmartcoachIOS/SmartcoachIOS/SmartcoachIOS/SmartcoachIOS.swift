import SwiftUI
import UIKit

// Classe pour initialiser les correctifs UIKit dans une application SwiftUI
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        return true
    }
    
    // Correctif pour les contraintes de clavier
    func application(_ application: UIApplication, didFinishLaunching notification: Notification) {
        // Installe les correctifs pour les problèmes de contraintes de clavier
        fixAllKeyboardConstraints(in: application)
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.fixAllKeyboardConstraints(in: application)
            }
        }
    }
    
    private func fixAllKeyboardConstraints(in application: UIApplication) {
        if #available(iOS 15.0, *) {
            application.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .forEach { $0.fixKeyboardConstraints() }
        } else {
            // Fallback pour iOS 14 et versions antérieures
            application.windows.forEach { $0.fixKeyboardConstraints() }
        }
    }
}

@main
struct SmartcoachIOS: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var coachManager = CoachManager()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var nutritionManager = NutritionManager()
    
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(authManager)
                    .environmentObject(coachManager)
                    .environmentObject(workoutManager)
                    .environmentObject(nutritionManager)
                    .onAppear {
                        // Configuration globale pour éviter les NaN dans les calculs
                        UserDefaults.standard.set(true, forKey: "CG_NUMERICS_SHOW_BACKTRACE")
                        
                        // Appliquer correctifs supplémentaires pour l'UI
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if #available(iOS 15.0, *) {
                                UIApplication.shared.connectedScenes
                                    .compactMap { $0 as? UIWindowScene }
                                    .flatMap { $0.windows }
                                    .forEach { $0.fixKeyboardConstraints() }
                            } else {
                                // Fallback pour iOS 14 et versions antérieures
                                UIApplication.shared.windows.forEach { $0.fixKeyboardConstraints() }
                            }
                        }
                    }
                
                if isLoading {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Simuler un temps de chargement pour le SplashScreen
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        isLoading = false
                    }
                }
                
                // Initialisation des données - les managers chargent déjà leurs données dans leur init()
                // Pas besoin d'appeler des méthodes supplémentaires car elles sont déjà appelées
                // dans les constructeurs des managers respectifs
            }
        }
    }
}

struct SplashScreenView: View {
    @State private var isRotating = false
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("SmartCoach")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryColor"))
                
                Image(systemName: "figure.run")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color("PrimaryColor"))
                    .rotationEffect(.degrees(isRotating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: isRotating
                    )
                    .onAppear {
                        isRotating = true
                    }
                
                Text("Votre coach personnel")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
                    .padding(.top, 10)
            }
        }
    }
} 