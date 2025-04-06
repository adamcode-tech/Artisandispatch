import Foundation
import FirebaseFirestore

struct Message: Identifiable, Equatable {
    let id: UUID
    let sender: User
    let content: String
    let timestamp: Date
    let isRead: Bool
    
    // Implémentation de Equatable
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.sender.id == rhs.sender.id &&
               lhs.content == rhs.content &&
               lhs.timestamp == rhs.timestamp &&
               lhs.isRead == rhs.isRead
    }
    
    // Conversion de Firestore vers Message
    static func fromFirestore(document: DocumentSnapshot) -> Message? {
        guard let data = document.data() else { return nil }
        
        guard let senderId = data["senderId"] as? String,
              let content = data["content"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        
        // Créer un utilisateur basique pour le message
        let sender = User(id: senderId, name: "Inconnu", email: "")
        
        return Message(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            sender: sender,
            content: content,
            timestamp: timestamp.dateValue(),
            isRead: data["isRead"] as? Bool ?? false
        )
    }
    
    // Conversion de Message vers dictionnaire pour Firestore
    func toFirestore() -> [String: Any] {
        return [
            "senderId": sender.id,
            "content": content,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": isRead
        ]
    }
} 
