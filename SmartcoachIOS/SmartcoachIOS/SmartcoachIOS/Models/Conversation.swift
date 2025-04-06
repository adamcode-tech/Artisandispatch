import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Conversation: Identifiable {
    let id: UUID
    let participants: [User]
    let lastMessage: Message?
    let unreadCount: Int
    
    // Conversion de Firestore vers Conversation
    static func fromFirestore(document: DocumentSnapshot, participants: [User]) -> Conversation? {
        guard let data = document.data() else { return nil }
        
        var lastMsg: Message? = nil
        
        // Récupérer le dernier message s'il existe
        if let lastMessageData = data["lastMessage"] as? [String: Any],
           let senderId = lastMessageData["senderId"] as? String,
           let content = lastMessageData["content"] as? String,
           let timestamp = lastMessageData["timestamp"] as? Timestamp {
            
            // Trouver l'expéditeur
            let sender = participants.first { $0.id == senderId } ?? 
                         User(id: senderId, name: "Inconnu", email: "")
            
            lastMsg = Message(
                id: UUID(), 
                sender: sender,
                content: content,
                timestamp: timestamp.dateValue(),
                isRead: lastMessageData["isRead"] as? Bool ?? false
            )
        }
        
        // Récupérer le nombre de messages non lus
        var unreadCount = 0
        if let unreadCountMap = data["unreadCount"] as? [String: Int],
           let currentUserID = Auth.auth().currentUser?.uid {
            unreadCount = unreadCountMap[currentUserID] ?? 0
        }
        
        return Conversation(
            id: UUID(uuidString: document.documentID) ?? UUID(),
            participants: participants,
            lastMessage: lastMsg,
            unreadCount: unreadCount
        )
    }
    
    // Conversion de Conversation vers données pour Firestore
    func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "participants": participants.map { $0.id },
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Ajouter le dernier message s'il existe
        if let lastMessage = lastMessage {
            data["lastMessage"] = [
                "senderId": lastMessage.sender.id,
                "content": lastMessage.content,
                "timestamp": Timestamp(date: lastMessage.timestamp),
                "isRead": lastMessage.isRead
            ]
        }
        
        // Initialiser les compteurs de messages non lus
        var unreadCountMap: [String: Int] = [:]
        for participant in participants {
            unreadCountMap[participant.id] = 0
        }
        data["unreadCount"] = unreadCountMap
        
        return data
    }
} 