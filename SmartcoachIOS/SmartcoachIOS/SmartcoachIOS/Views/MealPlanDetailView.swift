import SwiftUI

struct MealPlanDetailView: View {
    let mealPlan: MealPlan
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nutritionManager: NutritionManager
    @State private var showingApplyConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // En-tête
                VStack(alignment: .leading, spacing: 8) {
                    Text(mealPlan.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(mealPlan.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(mealPlan.duration) jours", systemImage: "calendar")
                        Spacer()
                        Label(mealPlan.difficulty.rawValue, systemImage: "chart.bar")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                Divider()
                
                // Liste des repas
                VStack(alignment: .leading, spacing: 16) {
                    Text("Repas du plan")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(MealType.allCases) { mealType in
                        if let meal = mealPlan.meals.first(where: { $0.type == mealType }) {
                            NavigationLink(destination: MealDetailView(meal: meal)) {
                                MealPlanMealRow(meal: meal)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            EmptyMealRow(mealType: mealType)
                        }
                    }
                }
                
                // Résumé nutritionnel
                VStack(alignment: .leading, spacing: 16) {
                    Text("Résumé nutritionnel")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        NutritionValueView(
                            title: "Calories/jour",
                            value: String(Int(max(0, mealPlan.targetCalories))),
                            unit: "kcal"
                        )
                        
                        NutritionValueView(
                            title: "Protéines",
                            value: String(format: "%.1f", max(0, mealPlan.targetProtein)),
                            unit: "g"
                        )
                        
                        NutritionValueView(
                            title: "Glucides",
                            value: String(format: "%.1f", max(0, mealPlan.targetCarbs)),
                            unit: "g"
                        )
                        
                        NutritionValueView(
                            title: "Lipides",
                            value: String(format: "%.1f", max(0, mealPlan.targetFat)),
                            unit: "g"
                        )
                    }
                    .padding(.horizontal)
                }
                
                // Bouton pour appliquer le plan
                Button(action: {
                    showingApplyConfirmation = true
                }) {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text("Appliquer ce plan")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    nutritionManager.removeMealPlan(mealPlan)
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Appliquer le plan", isPresented: $showingApplyConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Appliquer") {
                applyMealPlan()
            }
        } message: {
            Text("Voulez-vous appliquer ce plan de repas pour les \(mealPlan.duration) prochains jours?")
        }
    }
    
    private func applyMealPlan() {
        let calendar = Calendar.current
        let today = Date()
        
        for day in 0..<min(mealPlan.duration, 28) {
            if let dayDate = calendar.date(byAdding: .day, value: day, to: today) {
                for meal in mealPlan.meals {
                    nutritionManager.addMeal(meal, for: dayDate)
                }
            }
        }
    }
}

struct MealPlanMealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageUrl = meal.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                
                Text("\(Int(max(0, meal.calories))) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("P: \(String(format: "%.1f", max(0, meal.protein)))g")
                    Text("G: \(String(format: "%.1f", max(0, meal.carbs)))g")
                    Text("L: \(String(format: "%.1f", max(0, meal.fat)))g")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
}

struct EmptyMealRow: View {
    let mealType: MealType
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
            
            Text("Aucun repas pour \(mealType.rawValue)")
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct MealPlanDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealPlanDetailView(mealPlan: MealPlan(
                id: UUID(),
                name: "Plan de repas équilibré",
                description: "Un plan de repas équilibré pour une journée",
                difficulty: .intermediate,
                duration: 7,
                meals: [
                    Meal(
                        id: UUID(),
                        name: "Petit-déjeuner équilibré",
                        type: .breakfast,
                        calories: 450,
                        protein: 25,
                        carbs: 45,
                        fat: 20,
                        ingredients: ["Œufs", "Pain complet", "Avocat"],
                        instructions: ["Faire cuire les œufs", "Griller le pain", "Écraser l'avocat"],
                        preparationTime: 10,
                        cookingTime: 15,
                        servings: 2,
                        imageUrl: nil
                    )
                ],
                targetCalories: 2000,
                targetProtein: 150,
                targetCarbs: 200,
                targetFat: 70
            ))
            .environmentObject(NutritionManager())
        }
    }
} 