import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let difficulty: WorkoutDifficulty
    let duration: Int
    let exercises: [Exercise]
    let targetMuscles: [MuscleGroup]
    let equipment: [Equipment]
    let caloriesBurned: Int
    let imageUrl: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        difficulty: WorkoutDifficulty,
        duration: Int,
        exercises: [Exercise],
        targetMuscles: [MuscleGroup],
        equipment: [Equipment],
        caloriesBurned: Int,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.difficulty = difficulty
        self.duration = duration
        self.exercises = exercises
        self.targetMuscles = targetMuscles
        self.equipment = equipment
        self.caloriesBurned = caloriesBurned
        self.imageUrl = imageUrl
    }
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let muscleGroup: MuscleGroup
    let sets: Int
    let reps: Int
    let restTime: Int
    let difficulty: WorkoutDifficulty
    let equipment: Equipment
    let instructions: [String]
    let videoUrl: String?
    let imageUrl: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        muscleGroup: MuscleGroup,
        sets: Int,
        reps: Int,
        restTime: Int,
        difficulty: WorkoutDifficulty,
        equipment: Equipment,
        instructions: [String],
        videoUrl: String? = nil,
        imageUrl: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.muscleGroup = muscleGroup
        self.sets = sets
        self.reps = reps
        self.restTime = restTime
        self.difficulty = difficulty
        self.equipment = equipment
        self.instructions = instructions
        self.videoUrl = videoUrl
        self.imageUrl = imageUrl
    }
} 