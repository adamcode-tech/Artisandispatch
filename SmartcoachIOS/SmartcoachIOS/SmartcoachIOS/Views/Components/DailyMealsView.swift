import SwiftUI

struct DailyMealsView: View {
    let nutritionLog: NutritionLog?
    let onAddMeal: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Repas du jour")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddMeal) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color("PrimaryColor"))
                }
            }
            
            ForEach(MealType.allCases, id: \.self) { mealType in
                if let meals = nutritionLog?.meals.filter({ $0.type == mealType }),
                   !meals.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(mealType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ForEach(meals) { meal in
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

struct MealListItem: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 15) {
            if let imageUrl = meal.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(Color.gray.opacity(0.2))
                }
                .frame(width: 60, height: 60)
                .cornerRadius(10)
            } else {
                Rectangle()
                    .foregroundColor(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(meal.name)
                    .font(.headline)
                
                Text("\(Int(max(0, meal.calories))) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text("P: \(String(format: "%.1f", max(0, meal.protein)))g")
                Text("G: \(String(format: "%.1f", max(0, meal.carbs)))g")
                Text("L: \(String(format: "%.1f", max(0, meal.fat)))g")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct DailyMealsView_Previews: PreviewProvider {
    static var previews: some View {
        DailyMealsView(
            nutritionLog: NutritionLog(
                id: UUID(),
                date: Date(),
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
                ]
            ),
            onAddMeal: {}
        )
    }
} 