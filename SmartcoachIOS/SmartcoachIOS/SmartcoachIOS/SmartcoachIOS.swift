import SwiftUI
import UIKit

// Classe pour initialiser les correctifs UIKit dans une application SwiftUI
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Activer la journalisation des erreurs de CoreGraphics dans la console
        UserDefaults.standard.set(true, forKey: "CG_NUMERICS_SHOW_BACKTRACE")
        
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
struct FitnessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var coachManager = CoachManager()
    @StateObject private var workoutManager = WorkoutManager()
    @StateObject private var nutritionManager = NutritionManager()
    
    var body: some Scene {
        WindowGroup {
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
        }
    }
} 