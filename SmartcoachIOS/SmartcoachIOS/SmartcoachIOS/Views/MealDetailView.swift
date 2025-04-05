import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nutritionManager: NutritionManager
    @State private var showingAddDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image du repas
                if let imageUrl = meal.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(height: 200)
                    .clipped()
                }
                
                // Informations principales
                VStack(alignment: .leading, spacing: 8) {
                    Text(meal.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(meal.type.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        NutritionValueView(title: "Calories", value: String(Int(max(0, meal.calories))), unit: "kcal")
                        NutritionValueView(title: "Protéines", value: String(format: "%.1f", max(0, meal.protein)), unit: "g")
                        NutritionValueView(title: "Glucides", value: String(format: "%.1f", max(0, meal.carbs)), unit: "g")
                        NutritionValueView(title: "Lipides", value: String(format: "%.1f", max(0, meal.fat)), unit: "g")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                // Temps et portions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Temps et portions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "clock")
                                .font(.title2)
                            Text("\(max(0, meal.preparationTime + meal.cookingTime)) min")
                                .font(.subheadline)
                        }
                        
                        VStack {
                            Image(systemName: "person.2")
                                .font(.title2)
                            Text("\(max(1, meal.servings)) pers.")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Ingrédients
                VStack(alignment: .leading, spacing: 16) {
                    Text("Ingrédients")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(meal.ingredients, id: \.self) { ingredient in
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                            Text(ingredient)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Instructions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(Array(meal.instructions.enumerated()), id: \.offset) { index, instruction in
                        HStack(alignment: .top) {
                            Text("\(index + 1).")
                                .fontWeight(.bold)
                            Text(instruction)
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Bouton pour ajouter au journal
                Button(action: {
                    showingAddDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter au journal")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
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
                    nutritionManager.removeMeal(meal, for: Date())
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingAddDatePicker) {
            DatePickerView(date: $selectedDate, onSave: {
                nutritionManager.addMeal(meal, for: selectedDate)
                showingAddDatePicker = false
            })
        }
    }
}

struct DatePickerView: View {
    @Binding var date: Date
    var onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Sélectionner une date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
            }
            .navigationTitle("Ajouter au journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        onSave()
                    }
                }
            }
        }
    }
}

struct NutritionValueView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MealDetailView(meal: Meal(
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
            ))
            .environmentObject(NutritionManager())
        }
    }
} 