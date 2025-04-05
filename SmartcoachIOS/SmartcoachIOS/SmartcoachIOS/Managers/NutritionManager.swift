import Foundation
import SwiftUI

class NutritionManager: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var mealPlans: [MealPlan] = []
    @Published var nutritionLogs: [NutritionLog] = []
    @Published var selectedMealPlan: MealPlan?
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        // Simuler le chargement des données
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Charger les repas
            self.meals = [
                Meal(
                    id: UUID(),
                    name: "Petit-déjeuner protéiné",
                    type: .breakfast,
                    calories: 450,
                    protein: 30.0,
                    carbs: 45.0,
                    fat: 15.0,
                    ingredients: ["Œufs", "Avoine", "Banane", "Protéine en poudre"],
                    instructions: ["Mélanger l'avoine avec le lait", "Ajouter les œufs", "Cuire à feu moyen", "Servir avec la banane"],
                    preparationTime: 5,
                    cookingTime: 10,
                    servings: 1,
                    imageUrl: nil
                ),
                Meal(
                    id: UUID(),
                    name: "Salade César au poulet",
                    type: .lunch,
                    calories: 550,
                    protein: 35.0,
                    carbs: 25.0,
                    fat: 20.0,
                    ingredients: ["Poulet grillé", "Laitue romaine", "Parmesan", "Croûtons", "Sauce César"],
                    instructions: ["Griller le poulet", "Préparer la salade", "Ajouter la sauce", "Mélanger"],
                    preparationTime: 10,
                    cookingTime: 15,
                    servings: 1,
                    imageUrl: nil
                )
            ]
            
            // Charger les plans de repas
            self.mealPlans = [
                MealPlan(
                    id: UUID(),
                    name: "Plan équilibré",
                    description: "Un plan équilibré pour maintenir un poids santé",
                    difficulty: .intermediate,
                    duration: 7,
                    meals: [
                        Meal(
                            id: UUID(),
                            name: "Petit-déjeuner protéiné",
                            type: .breakfast,
                            calories: 450,
                            protein: 30.0,
                            carbs: 45.0,
                            fat: 15.0,
                            ingredients: ["Œufs", "Avoine", "Banane", "Protéine en poudre"],
                            instructions: ["Mélanger l'avoine avec le lait", "Ajouter les œufs", "Cuire à feu moyen", "Servir avec la banane"],
                            preparationTime: 5,
                            cookingTime: 10,
                            servings: 1,
                            imageUrl: nil
                        )
                    ],
                    targetCalories: 2000,
                    targetProtein: 150.0,
                    targetCarbs: 250.0,
                    targetFat: 70.0
                )
            ]
            
            self.isLoading = false
        }
    }
    
    func addMeal(_ meal: Meal, for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if let existingLog = nutritionLogs.first(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
            if let index = nutritionLogs.firstIndex(where: { $0.id == existingLog.id }) {
                nutritionLogs[index].meals.append(meal)
            }
        } else {
            let newLog = NutritionLog(
                id: UUID(), 
                date: startOfDay, 
                meals: [meal]
            )
            nutritionLogs.append(newLog)
        }
    }
    
    func removeMeal(_ meal: Meal, for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        if let existingLog = nutritionLogs.first(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
            if let index = nutritionLogs.firstIndex(where: { $0.id == existingLog.id }) {
                nutritionLogs[index].meals.removeAll { $0.id == meal.id }
            }
        }
    }
    
    func getNutritionLog(for date: Date) -> NutritionLog? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return nutritionLogs.first { calendar.isDate($0.date, inSameDayAs: startOfDay) }
    }
    
    func addMealPlan(_ mealPlan: MealPlan) {
        mealPlans.append(mealPlan)
    }
    
    func removeMealPlan(_ mealPlan: MealPlan) {
        mealPlans.removeAll { $0.id == mealPlan.id }
    }
    
    func updateMealPlan(_ mealPlan: MealPlan) {
        if let index = mealPlans.firstIndex(where: { $0.id == mealPlan.id }) {
            mealPlans[index] = mealPlan
        }
    }
    
    func searchMeals(query: String) -> [Meal] {
        guard !query.isEmpty else { return meals }
        return meals.filter { meal in
            meal.name.localizedCaseInsensitiveContains(query) ||
            meal.ingredients.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    func searchMealPlans(query: String) -> [MealPlan] {
        guard !query.isEmpty else { return mealPlans }
        return mealPlans.filter { plan in
            plan.name.localizedCaseInsensitiveContains(query) ||
            plan.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getAverageCaloriesPerDay(for days: Int = 7) -> Int {
        let calendar = Calendar.current
        let endDate = Date()
        guard days > 0 else { return 0 }
        
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        
        let relevantLogs = nutritionLogs.filter { log in
            log.date >= startDate && log.date <= endDate
        }
        
        if relevantLogs.isEmpty {
            return 0
        }
        
        let totalCalories = relevantLogs.reduce(0) { $0 + $1.totalCalories }
        return Int(totalCalories / Double(max(days, 1)))
    }
    
    func getMealPlan(by id: UUID) -> MealPlan? {
        mealPlans.first { $0.id == id }
    }
} 