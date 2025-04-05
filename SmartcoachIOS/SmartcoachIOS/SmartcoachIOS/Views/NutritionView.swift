import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var nutritionManager: NutritionManager
    @State private var selectedDate = Date()
    @State private var showingAddMeal = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Résumé nutritionnel
                    if let nutritionLog = nutritionManager.getNutritionLog(for: selectedDate) {
                        NutritionSummaryView(nutritionLog: nutritionLog)
                    }
                    
                    // Liste des repas
                    DailyMealsView(
                        nutritionLog: nutritionManager.getNutritionLog(for: selectedDate),
                        onAddMeal: {
                            showingAddMeal = true
                        }
                    )
                }
                .padding()
            }
            .navigationTitle("Nutrition")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddMeal = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                NavigationView {
                    AddMealView()
                        .environmentObject(nutritionManager)
                }
            }
        }
    }
}

#Preview {
    NutritionView()
        .environmentObject(NutritionManager())
} 