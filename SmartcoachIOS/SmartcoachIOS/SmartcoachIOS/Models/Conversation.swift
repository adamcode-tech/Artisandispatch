import Foundation
import SwiftUI

struct Conversation: Identifiable {
    let id: UUID
    let participants: [User]
    let lastMessage: Message?
    let unreadCount: Int
}

struct Message: Identifiable {
    let id: UUID
    let sender: User
    let content: String
    let timestamp: Date
    let isRead: Bool
} 