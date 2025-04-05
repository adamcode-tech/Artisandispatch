import SwiftUI

struct MealPlanSectionView: View {
    let mealPlan: MealPlan?
    let onAddMealPlan: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Plan de repas")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddMealPlan) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color("PrimaryColor"))
                }
            }
            
            if let mealPlan = mealPlan {
                MealPlanCard(mealPlan: mealPlan)
            } else {
                Text("Aucun plan de repas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MealPlanCard: View {
    let mealPlan: MealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(mealPlan.name)
                .font(.headline)
            
            Text(mealPlan.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(MealType.allCases, id: \.self) { mealType in
                let mealsForType = mealPlan.meals.filter({ $0.type == mealType })
                if !mealsForType.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(mealType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(mealsForType) { meal in
                            MealListItem(meal: meal)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct MealPlanSectionView_Previews: PreviewProvider {
    static var previews: some View {
        MealPlanSectionView(
            mealPlan: MealPlan(
                id: UUID(),
                name: "Plan équilibré",
                description: "Un plan de repas équilibré pour une alimentation saine",
                difficulty: .intermediate,
                duration: 7,
                meals: [
                    Meal(
                        id: UUID(),
                        name: "Petit-déjeuner",
                        type: .breakfast,
                        calories: 500,
                        protein: 20.0,
                        carbs: 60.0,
                        fat: 20.0,
                        ingredients: ["Œufs", "Pain complet", "Avocat"],
                        instructions: ["Cuire les œufs", "Griller le pain"],
                        preparationTime: 10,
                        cookingTime: 5,
                        servings: 1,
                        imageUrl: nil
                    )
                ],
                targetCalories: 2000,
                targetProtein: 150.0,
                targetCarbs: 250.0,
                targetFat: 70.0
            ),
            onAddMealPlan: {}
        )
    }
} 