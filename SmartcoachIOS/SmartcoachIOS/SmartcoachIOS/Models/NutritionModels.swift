import Foundation

enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast = "Petit-déjeuner"
    case lunch = "Déjeuner"
    case dinner = "Dîner"
    case snack = "Collation"
    
    var id: String { rawValue }
}

enum MealPlanDifficulty: String, Codable, CaseIterable, Identifiable {
    case beginner = "Débutant"
    case intermediate = "Intermédiaire"
    case advanced = "Avancé"
    
    var id: String { rawValue }
}

struct Meal: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: MealType
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let ingredients: [String]
    let instructions: [String]
    let preparationTime: Int
    let cookingTime: Int
    let servings: Int
    let imageUrl: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        type: MealType,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        ingredients: [String],
        instructions: [String],
        preparationTime: Int,
        cookingTime: Int,
        servings: Int,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.ingredients = ingredients
        self.instructions = instructions
        self.preparationTime = preparationTime
        self.cookingTime = cookingTime
        self.servings = servings
        self.imageUrl = imageUrl
    }
}

struct MealPlan: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let difficulty: MealPlanDifficulty
    let duration: Int
    let meals: [Meal]
    let targetCalories: Double
    let targetProtein: Double
    let targetCarbs: Double
    let targetFat: Double
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        difficulty: MealPlanDifficulty,
        duration: Int,
        meals: [Meal],
        targetCalories: Double,
        targetProtein: Double,
        targetCarbs: Double,
        targetFat: Double
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.duration = duration
        self.meals = meals
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbs = targetCarbs
        self.targetFat = targetFat
    }
}

struct NutritionLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    var meals: [Meal]
    
    var totalCalories: Double {
        meals.reduce(0) { $0 + $1.calories }
    }
    
    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.protein }
    }
    
    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbs }
    }
    
    var totalFat: Double {
        meals.reduce(0) { $0 + $1.fat }
    }
    
    init(id: UUID = UUID(), date: Date, meals: [Meal]) {
        self.id = id
        self.date = date
        self.meals = meals
    }
} 