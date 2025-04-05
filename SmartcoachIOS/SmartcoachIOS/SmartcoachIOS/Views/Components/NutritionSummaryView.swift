import SwiftUI

struct NutritionSummaryView: View {
    let nutritionLog: NutritionLog?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Résumé du jour")
                .font(.headline)
            
            HStack(spacing: 20) {
                NutritionSummaryCard(
                    title: "Calories",
                    value: "\(Int(max(0, nutritionLog?.totalCalories ?? 0)))",
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
                
                NutritionSummaryCard(
                    title: "Protéines",
                    value: String(format: "%.1f", max(0, nutritionLog?.totalProtein ?? 0)),
                    unit: "g",
                    icon: "p.circle.fill",
                    color: .blue
                )
                
                NutritionSummaryCard(
                    title: "Glucides",
                    value: String(format: "%.1f", max(0, nutritionLog?.totalCarbs ?? 0)),
                    unit: "g",
                    icon: "c.circle.fill",
                    color: .green
                )
                
                NutritionSummaryCard(
                    title: "Lipides",
                    value: String(format: "%.1f", max(0, nutritionLog?.totalFat ?? 0)),
                    unit: "g",
                    icon: "f.circle.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct NutritionSummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct NutritionSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionSummaryView(nutritionLog: NutritionLog(
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
        ))
    }
} 