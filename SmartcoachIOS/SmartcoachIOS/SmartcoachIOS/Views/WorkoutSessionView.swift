import SwiftUI
import UserNotifications

struct WorkoutSessionView: View {
    @StateObject private var sessionManager = WorkoutSessionManager()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    let workout: Workout
    
    var body: some View {
        VStack {
            // En-tête
            HStack {
                Button(action: { 
                    confirmEndWorkout()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text(workout.name)
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    if sessionManager.isActive {
                        sessionManager.pauseWorkout()
                    } else {
                        sessionManager.resumeWorkout()
                    }
                }) {
                    Image(systemName: sessionManager.isActive ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            // Timer
            Text(timeString(from: sessionManager.elapsedTime))
                .font(.system(size: 60, weight: .bold, design: .monospaced))
                .foregroundColor(Color("PrimaryColor"))
                .padding()
            
            // Progression
            ProgressView(value: sessionManager.progress)
                .accentColor(Color("PrimaryColor"))
                .padding(.horizontal)
            
            // Exercice actuel
            if let currentExercise = sessionManager.currentExercise {
                VStack(spacing: 16) {
                    Text(currentExercise.name)
                        .font(.title3)
                        .bold()
                        .foregroundColor(Color("SecondaryColor"))
                    
                    HStack(spacing: 24) {
                        VStack {
                            Text("Série")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(sessionManager.currentSet)/\(currentExercise.sets)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        VStack {
                            Text("Répétitions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(currentExercise.reps)")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        VStack {
                            Text("Repos")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(currentExercise.restTime)s")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    if sessionManager.isResting {
                        RestTimerView(timeRemaining: sessionManager.restTimeRemaining)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding()
            }
            
            Spacer()
            
            // Contrôles de navigation entre exercices
            HStack(spacing: 40) {
                Button(action: { sessionManager.previousExercise() }) {
                    Circle()
                        .fill(Color("SecondaryColor").opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "arrow.left")
                                .font(.title3)
                                .foregroundColor(Color("SecondaryColor"))
                        )
                }
                
                // Bouton principal (suivant/terminer le repos)
                Button(action: { 
                    if sessionManager.isResting {
                        sessionManager.isResting = false
                        sessionManager.restTimeRemaining = 0
                    } else {
                        sessionManager.nextExercise()
                    }
                }) {
                    Circle()
                        .fill(Color("PrimaryColor"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: sessionManager.isResting ? "stop.fill" : "arrow.right")
                                .font(.title2)
                                .foregroundColor(.white)
                        )
                }
                
                // Bouton de repos
                Button(action: { 
                    if !sessionManager.isResting {
                        sessionManager.startRest()
                    }
                }) {
                    Circle()
                        .fill(Color("GreenAccent").opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "timer")
                                .font(.title3)
                                .foregroundColor(Color("GreenAccent"))
                        )
                }
            }
            .padding(.bottom, 30)
        }
        .onAppear {
            setupNotificationHandling()
            sessionManager.startWorkout(workout)
        }
        .onDisappear {
            // On ne met pas sessionManager.endWorkout() ici pour permettre au chronomètre 
            // de continuer en arrière-plan
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // L'app est revenue au premier plan
                print("App en premier plan")
            } else if newPhase == .background {
                // L'app est passée en arrière-plan
                print("App en arrière-plan")
            }
        }
    }
    
    private func setupNotificationHandling() {
        // Configuration du gestionnaire de notification pour répondre aux actions
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Configurer la gestion des actions de notification
        NotificationDelegate.shared.onNotificationAction = { actionIdentifier, userInfo in
            if actionIdentifier == "NEXT_ACTION" {
                DispatchQueue.main.async {
                    if sessionManager.isResting {
                        sessionManager.isResting = false
                        sessionManager.restTimeRemaining = 0
                    } else {
                        sessionManager.nextExercise()
                    }
                }
            } else if actionIdentifier == "PAUSE_ACTION" {
                DispatchQueue.main.async {
                    if sessionManager.isActive {
                        sessionManager.pauseWorkout()
                    } else {
                        sessionManager.resumeWorkout()
                    }
                }
            }
        }
    }
    
    private func confirmEndWorkout() {
        let alert = UIAlertController(
            title: "Terminer la séance ?",
            message: "Voulez-vous vraiment terminer cette séance d'entraînement ?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel))
        alert.addAction(UIAlertAction(title: "Terminer", style: .destructive) { _ in
            sessionManager.endWorkout()
            dismiss()
        })
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct RestTimerView: View {
    let timeRemaining: TimeInterval
    
    var body: some View {
        VStack(spacing: 10) {
            Text("TEMPS DE REPOS")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("\(Int(timeRemaining))")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)
            
            Text("secondes")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: Double(timeRemaining) / 60.0)
                .accentColor(.orange)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

// Délégué global pour gérer les notifications en arrière-plan
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    var onNotificationAction: ((String, [AnyHashable: Any]) -> Void)?
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        onNotificationAction?(actionIdentifier, userInfo)
        
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Afficher la notification même si l'app est au premier plan
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }
}

#Preview {
    WorkoutSessionView(workout: Workout(
        name: "Entraînement complet",
        description: "Un entraînement complet pour tout le corps",
        difficulty: .intermediate,
        duration: 45,
        exercises: [
            Exercise(
                name: "Pompes",
                description: "Exercice de base pour les pectoraux",
                muscleGroup: .chest,
                sets: 3,
                reps: 12,
                restTime: 30,
                difficulty: .intermediate,
                equipment: .bodyweight,
                instructions: ["Position de départ en planche", "Descendre jusqu'à toucher le sol", "Remonter en poussant"]
            ),
            Exercise(
                name: "Squats",
                description: "Exercice pour les jambes",
                muscleGroup: .legs,
                sets: 3,
                reps: 15,
                restTime: 30,
                difficulty: .beginner,
                equipment: .bodyweight,
                instructions: ["Pieds écartés largeur épaules", "Descendre comme pour s'asseoir", "Remonter en poussant sur les talons"]
            )
        ],
        targetMuscles: [.chest, .arms, .legs],
        equipment: [.bodyweight],
        caloriesBurned: 300
    ))
} 