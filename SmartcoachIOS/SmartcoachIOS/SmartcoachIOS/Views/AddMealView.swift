import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nutritionManager: NutritionManager
    
    @State private var name = ""
    @State private var type: MealType = .breakfast
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var ingredients: [String] = []
    @State private var instructions: [String] = []
    @State private var preparationTime = ""
    @State private var cookingTime = ""
    @State private var servings = ""
    @State private var newIngredient = ""
    @State private var newInstruction = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nom du repas", text: $name)
                    
                    Picker("Type", selection: $type) {
                        ForEach(MealType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section {
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Protéines (g)", text: $protein)
                        .keyboardType(.decimalPad)
                    TextField("Glucides (g)", text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField("Lipides (g)", text: $fat)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Ingrédients")) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        Text(ingredient)
                    }
                    .onDelete { indexSet in
                        ingredients.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Nouvel ingrédient", text: $newIngredient)
                        Button(action: {
                            if !newIngredient.isEmpty {
                                ingredients.append(newIngredient)
                                newIngredient = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                
                Section(header: Text("Instructions")) {
                    ForEach(instructions, id: \.self) { instruction in
                        Text(instruction)
                    }
                    .onDelete { indexSet in
                        instructions.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        TextField("Nouvelle instruction", text: $newInstruction)
                        Button(action: {
                            if !newInstruction.isEmpty {
                                instructions.append(newInstruction)
                                newInstruction = ""
                            }
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
                
                Section {
                    TextField("Temps de préparation (min)", text: $preparationTime)
                        .keyboardType(.numberPad)
                    TextField("Temps de cuisson (min)", text: $cookingTime)
                        .keyboardType(.numberPad)
                    TextField("Nombre de portions", text: $servings)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Ajouter un repas")
            .navigationBarItems(
                leading: Button("Annuler") { dismiss() },
                trailing: Button("Sauvegarder") {
                    saveMeal()
                    dismiss()
                }
                .disabled(!isFormValid)
            )
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !calories.isEmpty &&
        !protein.isEmpty &&
        !carbs.isEmpty &&
        !fat.isEmpty &&
        !ingredients.isEmpty &&
        !instructions.isEmpty &&
        !preparationTime.isEmpty &&
        !cookingTime.isEmpty &&
        !servings.isEmpty
    }
    
    private func saveMeal() {
        let meal = Meal(
            id: UUID(),
            name: name,
            type: type,
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            ingredients: ingredients,
            instructions: instructions,
            preparationTime: Int(preparationTime) ?? 0,
            cookingTime: Int(cookingTime) ?? 0,
            servings: Int(servings) ?? 1,
            imageUrl: nil
        )
        
        nutritionManager.addMeal(meal, for: Date())
    }
} 