import Foundation
import SwiftUI
import UserNotifications
import BackgroundTasks

class WorkoutSessionManager: ObservableObject {
    @Published var isActive = false
    @Published var currentExerciseIndex = 0
    @Published var currentSet = 1
    @Published var elapsedTime: TimeInterval = 0
    @Published var isResting = false
    @Published var restTimeRemaining: TimeInterval = 0
    @Published var workoutName: String = ""
    
    private var workout: Workout?
    private var timer: Timer?
    private var restTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var appEnterBackgroundDate: Date?
    private var notificationTimer: Timer?
    private var lastNotificationTime: Date?
    
    var currentExercise: Exercise? {
        guard let workout = workout, 
              workout.exercises.count > 0,
              currentExerciseIndex >= 0,
              currentExerciseIndex < workout.exercises.count else {
            return nil
        }
        return workout.exercises[currentExerciseIndex]
    }
    
    var progress: Double {
        guard let workout = workout, workout.exercises.count > 0 else { return 0 }
        // Calcul sécurisé de la progression
        let totalExercises = max(Double(workout.exercises.count), 1.0)
        let currentIndex = max(0.0, min(Double(currentExerciseIndex), totalExercises - 1))
        return currentIndex / totalExercises
    }
    
    init() {
        setupNotifications()
        
        // Observer les transitions en arrière/premier plan
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appMovedToForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func startWorkout(_ workout: Workout) {
        // Vérifier si le workout a des exercices
        guard !workout.exercises.isEmpty else { return }
        
        self.workout = workout
        self.workoutName = workout.name
        isActive = true
        currentExerciseIndex = 0
        currentSet = 1
        elapsedTime = 0
        isResting = false
        restTimeRemaining = 0
        
        // Arrêter les timers existants
        timer?.invalidate()
        restTimer?.invalidate()
        
        startTimer()
        
        // Demander l'autorisation pour les notifications si pas encore accordée
        requestNotificationPermission()
    }
    
    func pauseWorkout() {
        isActive = false
        timer?.invalidate()
        restTimer?.invalidate()
        notificationTimer?.invalidate()
    }
    
    func resumeWorkout() {
        isActive = true
        startTimer()
        if isResting && restTimeRemaining > 0 {
            startRestTimer()
        }
        setupPeriodicNotifications()
    }
    
    func endWorkout() {
        isActive = false
        timer?.invalidate()
        restTimer?.invalidate()
        notificationTimer?.invalidate()
        
        // Annuler toutes les notifications en attente
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        workout = nil
        currentExerciseIndex = 0
        currentSet = 1
        elapsedTime = 0
        isResting = false
        restTimeRemaining = 0
        
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func nextExercise() {
        guard let workout = workout, !workout.exercises.isEmpty else { return }
        
        let maxSets = max(currentExercise?.sets ?? 1, 1)
        
        if currentSet < maxSets {
            currentSet += 1
        } else {
            currentSet = 1
            if currentExerciseIndex < workout.exercises.count - 1 {
                currentExerciseIndex += 1
                startRest()
            } else {
                // Notification de fin d'entraînement
                sendNotification(
                    title: "Entraînement terminé !",
                    body: "Bravo ! Vous avez terminé votre séance \(workoutName).",
                    userInfo: ["action": "workoutCompleted"]
                )
                endWorkout()
            }
        }
    }
    
    func previousExercise() {
        if currentSet > 1 {
            currentSet -= 1
        } else if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
            currentSet = max(currentExercise?.sets ?? 1, 1)
        }
    }
    
    func startRest() {
        guard let exercise = currentExercise else { return }
        
        // Arrêter le timer de repos précédent s'il existe
        restTimer?.invalidate()
        
        isResting = true
        restTimeRemaining = max(TimeInterval(exercise.restTime), 0)
        
        startRestTimer()
        
        // Notification du début du repos
        if restTimeRemaining > 5 {
            sendNotification(
                title: "Repos démarré",
                body: "Temps de repos: \(Int(restTimeRemaining)) secondes",
                userInfo: ["action": "restStarted"]
            )
        }
    }
    
    private func startRestTimer() {
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
                
                // Notification quand il reste 5 secondes de repos
                if self.restTimeRemaining == 5 {
                    self.sendNotification(
                        title: "Repos presque terminé",
                        body: "Préparez-vous pour le prochain exercice !",
                        userInfo: ["action": "restEnding"]
                    )
                }
            } else {
                self.isResting = false
                timer.invalidate()
                
                // Notification de fin de repos
                self.sendNotification(
                    title: "Repos terminé",
                    body: "Commencez \(self.currentExercise?.name ?? "le prochain exercice") !",
                    userInfo: ["action": "restEnded"]
                )
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate() // S'assurer que l'ancien timer est arrêté
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isActive else { return }
            self.elapsedTime += 1
        }
        
        setupPeriodicNotifications()
    }
    
    // MARK: - Gestion des notifications
    
    private func setupNotifications() {
        // Configurer les catégories de notifications avec des actions
        let nextAction = UNNotificationAction(
            identifier: "NEXT_ACTION",
            title: "Suivant",
            options: .foreground
        )
        
        let pauseAction = UNNotificationAction(
            identifier: "PAUSE_ACTION",
            title: "Pause",
            options: .foreground
        )
        
        let workoutCategory = UNNotificationCategory(
            identifier: "WORKOUT_CATEGORY",
            actions: [nextAction, pauseAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([workoutCategory])
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notifications autorisées")
                } else if let error = error {
                    print("Erreur d'autorisation de notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setupPeriodicNotifications() {
        // Annuler le timer précédent
        notificationTimer?.invalidate()
        
        // Créer un timer qui envoie une mise à jour périodique pendant la séance
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isActive else { return }
            
            // Éviter les notifications trop fréquentes
            if let lastTime = self.lastNotificationTime, Date().timeIntervalSince(lastTime) < 25 {
                return
            }
            
            self.sendWorkoutStatusNotification()
        }
    }
    
    private func sendWorkoutStatusNotification() {
        guard isActive, let currentExercise = currentExercise else { return }
        
        let title = isResting ? "Repos en cours" : "\(workoutName) - En cours"
        
        let formattedTime = formatTime(elapsedTime)
        let exerciseInfo = "\(currentExercise.name) - Série \(currentSet)/\(currentExercise.sets)"
        let statusInfo = isResting ? "Repos: \(Int(restTimeRemaining))s" : "Répétitions: \(currentExercise.reps)"
        
        let body = "\(formattedTime) | \(exerciseInfo) | \(statusInfo)"
        
        sendNotification(
            title: title,
            body: body,
            userInfo: ["action": "workoutStatus"],
            categoryIdentifier: "WORKOUT_CATEGORY"
        )
        
        lastNotificationTime = Date()
    }
    
    private func sendNotification(title: String, body: String, userInfo: [String: Any], categoryIdentifier: String = "") {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Ajouter la catégorie si elle est fournie
        if !categoryIdentifier.isEmpty {
            content.categoryIdentifier = categoryIdentifier
        }
        
        // Ajouter les données supplémentaires
        content.userInfo = userInfo
        
        // Déclencher immédiatement
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur d'envoi de notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Gestion de l'arrière-plan
    
    @objc private func appMovedToBackground() {
        appEnterBackgroundDate = Date()
        
        // Démarrer une tâche d'arrière-plan
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            guard let self = self else { return }
            if self.backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
        
        // Envoyer une notification immédiate en arrière-plan
        if isActive {
            sendWorkoutStatusNotification()
        }
    }
    
    @objc private func appMovedToForeground() {
        // Calculer le temps passé en arrière-plan
        if let enterDate = appEnterBackgroundDate, isActive {
            let timeInBackground = Date().timeIntervalSince(enterDate)
            elapsedTime += timeInBackground
            
            // Mettre à jour le temps de repos si nécessaire
            if isResting {
                let newRestTime = restTimeRemaining - timeInBackground
                restTimeRemaining = max(newRestTime, 0)
                
                if restTimeRemaining <= 0 {
                    isResting = false
                }
            }
        }
        
        // Fin de la tâche d'arrière-plan
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        
        // Redémarrer les timers
        if isActive {
            startTimer()
            if isResting && restTimeRemaining > 0 {
                startRestTimer()
            }
        }
    }
    
    // MARK: - Utilitaires
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 