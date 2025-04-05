import SwiftUI

struct CreateMealPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nutritionManager: NutritionManager
    
    @State private var name = ""
    @State private var description = ""
    @State private var difficulty: MealPlanDifficulty = .beginner
    @State private var duration = ""
    @State private var targetCalories = ""
    @State private var targetProtein = ""
    @State private var targetCarbs = ""
    @State private var targetFat = ""
    @State private var selectedMeals: [Meal] = []
    @State private var showingMealPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Nom du plan", text: $name)
                    TextField("Description", text: $description)
                    
                    Picker("Difficulté", selection: $difficulty) {
                        ForEach(MealPlanDifficulty.allCases) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    
                    TextField("Durée (jours)", text: $duration)
                        .keyboardType(.numberPad)
                }
                
                Section {
                    TextField("Calories cibles", text: $targetCalories)
                        .keyboardType(.numberPad)
                    TextField("Protéines cibles (g)", text: $targetProtein)
                        .keyboardType(.decimalPad)
                    TextField("Glucides cibles (g)", text: $targetCarbs)
                        .keyboardType(.decimalPad)
                    TextField("Lipides cibles (g)", text: $targetFat)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Repas")) {
                    ForEach(selectedMeals) { meal in
                        VStack(alignment: .leading) {
                            Text(meal.name)
                                .font(.headline)
                            Text("\(meal.calories) kcal • \(meal.type.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        selectedMeals.remove(atOffsets: indexSet)
                    }
                    
                    Button(action: { showingMealPicker = true }) {
                        Label("Ajouter un repas", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Créer un plan de repas")
            .navigationBarItems(
                leading: Button("Annuler") { dismiss() },
                trailing: Button("Sauvegarder") {
                    saveMealPlan()
                    dismiss()
                }
                .disabled(!isFormValid)
            )
            .sheet(isPresented: $showingMealPicker) {
                MealPickerView(selectedMeals: $selectedMeals)
                    .environmentObject(nutritionManager)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        !description.isEmpty &&
        !duration.isEmpty &&
        !targetCalories.isEmpty &&
        !targetProtein.isEmpty &&
        !targetCarbs.isEmpty &&
        !targetFat.isEmpty &&
        !selectedMeals.isEmpty
    }
    
    private func saveMealPlan() {
        let mealPlan = MealPlan(
            id: UUID(),
            name: name,
            description: description,
            difficulty: difficulty,
            duration: Int(duration) ?? 7,
            meals: selectedMeals,
            targetCalories: Double(targetCalories) ?? 2000,
            targetProtein: Double(targetProtein) ?? 150,
            targetCarbs: Double(targetCarbs) ?? 250,
            targetFat: Double(targetFat) ?? 70
        )
        
        nutritionManager.addMealPlan(mealPlan)
    }
}

struct MealPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nutritionManager: NutritionManager
    @Binding var selectedMeals: [Meal]
    @State private var searchText = ""
    
    var filteredMeals: [Meal] {
        if searchText.isEmpty {
            return nutritionManager.meals
        } else {
            return nutritionManager.meals.filter { meal in
                meal.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredMeals) { meal in
                Button(action: {
                    if !selectedMeals.contains(where: { $0.id == meal.id }) {
                        selectedMeals.append(meal)
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(meal.name)
                                .font(.headline)
                            Text("\(meal.calories) kcal • \(meal.type.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedMeals.contains(where: { $0.id == meal.id }) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Rechercher un repas")
            .navigationTitle("Sélectionner des repas")
            .navigationBarItems(trailing: Button("Terminé") { dismiss() })
        }
    }
} 