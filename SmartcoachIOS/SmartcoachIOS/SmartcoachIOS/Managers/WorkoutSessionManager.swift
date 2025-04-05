import Foundation
import SwiftUI

class WorkoutSessionManager: ObservableObject {
    @Published var isActive = false
    @Published var currentExerciseIndex = 0
    @Published var currentSet = 1
    @Published var elapsedTime: TimeInterval = 0
    @Published var isResting = false
    @Published var restTimeRemaining: TimeInterval = 0
    
    private var workout: Workout?
    private var timer: Timer?
    private var restTimer: Timer?
    
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
    
    func startWorkout(_ workout: Workout) {
        // Vérifier si le workout a des exercices
        guard !workout.exercises.isEmpty else { return }
        
        self.workout = workout
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
    }
    
    func pauseWorkout() {
        isActive = false
        timer?.invalidate()
        restTimer?.invalidate()
    }
    
    func resumeWorkout() {
        isActive = true
        startTimer()
        if isResting && restTimeRemaining > 0 {
            startRestTimer()
        }
    }
    
    func endWorkout() {
        isActive = false
        timer?.invalidate()
        restTimer?.invalidate()
        workout = nil
        currentExerciseIndex = 0
        currentSet = 1
        elapsedTime = 0
        isResting = false
        restTimeRemaining = 0
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
    }
    
    private func startRestTimer() {
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
            } else {
                self.isResting = false
                timer.invalidate()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate() // S'assurer que l'ancien timer est arrêté
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isActive else { return }
            self.elapsedTime += 1
        }
    }
} 