import SwiftUI
import Firebase
import FirebaseFirestore

struct ChatView: View {
    let conversation: Conversation
    @EnvironmentObject var authManager: AuthManager
    @State private var messageText = ""
    @State private var messages = [Message]()
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var scrollToBottom = false
    @State private var currentUserId: String?
    
    #if DEBUG
    // Pour l'aperçu uniquement
    @State private var isPreviewing = false
    #endif
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            MessagesView(
                messages: messages,
                isLoading: isLoading,
                scrollToBottom: $scrollToBottom,
                currentUserId: currentUserId
            )
            
            MessageInputView(
                messageText: $messageText,
                onSend: sendMessage
            )
        }
        .navigationTitle(otherParticipantName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            #if DEBUG
            // Vérifier si nous sommes en mode prévisualisation
            if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" || authManager is PreviewAuthManager {
                isPreviewing = true
                // Définir l'ID utilisateur courant pour la prévisualisation
                currentUserId = "user1"
                // Charger des données factices pour la prévisualisation
                self.messages = PreviewData.messages
                self.isLoading = false
            } else {
                // Marquer les messages comme lus
                markMessagesAsRead()
                
                // Charger les messages
                loadMessages()
                
                // Surveiller les nouveaux messages
                setupMessagesListener()
                
                // Récupérer l'ID utilisateur courant
                currentUserId = authManager.user?.uid
            }
            #else
            // Marquer les messages comme lus
            markMessagesAsRead()
            
            // Charger les messages
            loadMessages()
            
            // Surveiller les nouveaux messages
            setupMessagesListener()
            
            // Récupérer l'ID utilisateur courant
            currentUserId = authManager.user?.uid
            #endif
        }
    }
    
    // Nom de l'autre participant pour le titre
    private var otherParticipantName: String {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            if let otherParticipant = conversation.participants.first(where: { $0.id != "user1" }) {
                return otherParticipant.name
            }
            return "Coach"
        }
        #endif
        
        guard let currentUserId = authManager.user?.uid else {
            return "Conversation"
        }
        
        if let otherParticipant = conversation.participants.first(where: { $0.id != currentUserId }) {
            return otherParticipant.name
        }
        return "Conversation"
    }
    
    // Charger les messages existants
    private func loadMessages() {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            return
        }
        #endif
        
        isLoading = true
        
        let conversationId = conversation.id.uuidString
        let messagesRef = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .limit(to: 100)
        
        messagesRef.getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Erreur: \(error.localizedDescription)"
                isLoading = false
                return
            }
            
            guard let documents = snapshot?.documents else {
                isLoading = false
                return
            }
            
            var fetchedMessages = [Message]()
            
            for document in documents {
                let data = document.data()
                if let senderId = data["senderId"] as? String,
                   let content = data["content"] as? String,
                   let timestamp = data["timestamp"] as? Timestamp {
                    
                    // Trouver l'expéditeur
                    let sender: User
                    if let currentUserId = authManager.user?.uid, senderId == currentUserId,
                       let currentUser = authManager.user {
                        // Créer un User à partir des données de Firebase Auth
                        sender = User(id: currentUser.uid, name: currentUser.displayName ?? "Utilisateur", email: currentUser.email ?? "")
                    } else if let otherParticipant = conversation.participants.first(where: { $0.id == senderId }) {
                        sender = otherParticipant
                    } else {
                        sender = User(id: senderId, name: "Inconnu", email: "")
                    }
                    
                    let message = Message(
                        id: UUID(uuidString: document.documentID) ?? UUID(),
                        sender: sender,
                        content: content,
                        timestamp: timestamp.dateValue(),
                        isRead: data["isRead"] as? Bool ?? false
                    )
                    
                    fetchedMessages.append(message)
                }
            }
            
            // Trier par date
            fetchedMessages.sort { $0.timestamp < $1.timestamp }
            
            DispatchQueue.main.async {
                self.messages = fetchedMessages
                self.isLoading = false
                self.scrollToBottom = true
            }
        }
    }
    
    // Observer les nouveaux messages
    private func setupMessagesListener() {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            return
        }
        #endif
        
        let conversationId = conversation.id.uuidString
        
        db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot else {
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    if change.type == .added {
                        let data = change.document.data()
                        
                        if let senderId = data["senderId"] as? String,
                           let content = data["content"] as? String,
                           let timestamp = data["timestamp"] as? Timestamp {
                            
                            // Vérifier si le message existe déjà
                            let messageId = UUID(uuidString: change.document.documentID) ?? UUID()
                            if !messages.contains(where: { $0.id == messageId }) {
                                // Trouver l'expéditeur
                                let sender: User
                                if let currentUserId = authManager.user?.uid, senderId == currentUserId,
                                   let currentUser = authManager.user {
                                    // Créer un User à partir des données de Firebase Auth
                                    sender = User(id: currentUser.uid, name: currentUser.displayName ?? "Utilisateur", email: currentUser.email ?? "")
                                } else if let otherParticipant = conversation.participants.first(where: { $0.id == senderId }) {
                                    sender = otherParticipant
                                } else {
                                    sender = User(id: senderId, name: "Inconnu", email: "")
                                }
                                
                                let message = Message(
                                    id: messageId,
                                    sender: sender,
                                    content: content,
                                    timestamp: timestamp.dateValue(),
                                    isRead: data["isRead"] as? Bool ?? false
                                )
                                
                                DispatchQueue.main.async {
                                    self.messages.append(message)
                                    self.scrollToBottom = true
                                    
                                    // Si le message est d'un autre utilisateur, le marquer comme lu
                                    if let currentUserId = authManager.user?.uid, senderId != currentUserId {
                                        self.markMessageAsRead(messageId: change.document.documentID)
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    // Envoyer un nouveau message
    private func sendMessage() {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            // Simuler l'envoi d'un message en mode prévisualisation
            let newMessage = Message(
                id: UUID(),
                sender: User(id: "user1", name: "Utilisateur", email: "user@example.com"),
                content: messageText,
                timestamp: Date(),
                isRead: false
            )
            messages.append(newMessage)
            messageText = ""
            scrollToBottom = true
            return
        }
        #endif
        
        guard let userId = authManager.user?.uid,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        let conversationId = conversation.id.uuidString
        let messageText = self.messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.messageText = ""
        
        // Récupérer l'autre participant
        guard let otherParticipant = conversation.participants.first(where: { $0.id != userId }) else {
            return
        }
        
        // Créer une référence pour un nouveau message
        let messageRef = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document()
        
        // Données du message
        let messageData: [String: Any] = [
            "senderId": userId,
            "content": messageText,
            "timestamp": FieldValue.serverTimestamp(),
            "isRead": false
        ]
        
        // Mettre à jour le dernier message dans la conversation
        let lastMessageData: [String: Any] = [
            "lastMessage": [
                "senderId": userId,
                "content": messageText,
                "timestamp": FieldValue.serverTimestamp(),
                "isRead": false
            ],
            "unreadCount.\(otherParticipant.id)": FieldValue.increment(Int64(1)),
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        // Transaction pour assurer la cohérence des données
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // Ajouter le message
            transaction.setData(messageData, forDocument: messageRef)
            
            // Mettre à jour la conversation
            let conversationRef = self.db.collection("conversations").document(conversationId)
            transaction.updateData(lastMessageData, forDocument: conversationRef)
            
            return nil
        }) { object, error in
            if let error = error {
                print("Erreur lors de l'envoi du message: \(error.localizedDescription)")
            }
        }
    }
    
    // Marquer tous les messages comme lus
    private func markMessagesAsRead() {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            return
        }
        #endif
        
        guard let userId = authManager.user?.uid else { return }
        
        let conversationId = conversation.id.uuidString
        let conversationRef = db.collection("conversations").document(conversationId)
        
        // Mettre à jour le compteur de non lus
        conversationRef.updateData([
            "unreadCount.\(userId)": 0
        ])
        
        // Récupérer les messages non lus
        db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .whereField("isRead", isEqualTo: false)
            .whereField("senderId", isNotEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                // Mettre à jour chaque message
                for document in documents {
                    self.markMessageAsRead(messageId: document.documentID)
                }
            }
    }
    
    // Marquer un message spécifique comme lu
    private func markMessageAsRead(messageId: String) {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            return
        }
        #endif
        
        let conversationId = conversation.id.uuidString
        let messageRef = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(messageId)
        
        messageRef.updateData(["isRead": true])
    }
}

// Sous-vue pour afficher les messages
struct MessagesView: View {
    let messages: [Message]
    let isLoading: Bool
    @Binding var scrollToBottom: Bool
    let currentUserId: String?
    
    // Utiliser State pour suivre le nombre de messages
    @State private var messageCount: Int = 0
    
    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .padding(.top, 40)
                    } else if messages.isEmpty {
                        Text("Pas de messages")
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                    } else {
                        ForEach(messages) { message in
                            let isCurrentUser = message.sender.id == currentUserId
                            MessageBubble(message: message, isCurrentUser: isCurrentUser)
                                .id(message.id)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 8)
            }
            .onChange(of: messages.count) { _, newCount in
                if newCount > messageCount {
                    scrollToBottom = true
                    messageCount = newCount
                }
            }
            .onChange(of: scrollToBottom) { _, value in
                if value, let lastMessageId = messages.last?.id {
                    withAnimation {
                        scrollView.scrollTo(lastMessageId, anchor: .bottom)
                    }
                    scrollToBottom = false
                }
            }
            .onAppear {
                messageCount = messages.count
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let lastMessageId = messages.last?.id {
                        withAnimation {
                            scrollView.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

// Sous-vue pour la zone de saisie de message
struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            TextField("Message", text: $messageText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .padding(.leading, 16)
            
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)
                    .padding(10)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.trailing, 16)
        }
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(10)
                    .background(isCurrentUser ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(formatMessageTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    private func formatMessageTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ChatView(
            conversation: Conversation(
                id: UUID(),
                participants: [
                    User(id: "user1", name: "Utilisateur", email: "user@example.com"),
                    User(id: "coach1", name: "Coach", email: "coach@example.com")
                ],
                lastMessage: Message(
                    id: UUID(),
                    sender: User(id: "coach1", name: "Coach", email: "coach@example.com"),
                    content: "Bonjour, comment puis-je vous aider ?",
                    timestamp: Date(),
                    isRead: false
                ),
                unreadCount: 1
            )
        )
        .environmentObject(AuthManager())
    }
}

#if DEBUG
#Preview {
    NavigationView {
        ChatView(
            conversation: PreviewData.conversation
        )
        .environmentObject(PreviewAuthManager())
    }
}
#else
// Pas de prévisualisation en mode release
#endif 