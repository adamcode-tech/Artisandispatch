import SwiftUI
import Firebase
import FirebaseFirestore

struct MessagingView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var conversations = [Conversation]()
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    #if DEBUG
    // Pour l'aperçu uniquement
    @State private var isPreviewing = false
    #endif
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else if conversations.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "message.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Pas de conversations")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Contactez un coach pour commencer une conversation")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: CoachListView()) {
                            Text("Trouver un coach")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    List {
                        ForEach(conversations) { conversation in
                            NavigationLink(destination: ChatView(conversation: conversation)) {
                                ConversationRow(conversation: conversation)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        await loadConversations()
                    }
                }
                
                if let error = errorMessage {
                    VStack {
                        Spacer()
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.9))
                            .cornerRadius(10)
                            .padding()
                    }
                }
            }
            .navigationTitle("Messages")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await loadConversations()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                #if DEBUG
                // Vérifier si nous sommes en mode prévisualisation
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" || authManager is PreviewAuthManager {
                    isPreviewing = true
                    // Charger des données factices pour la prévisualisation
                    self.conversations = PreviewData.conversations
                    self.isLoading = false
                } else {
                    Task {
                        await loadConversations()
                    }
                }
                #else
                Task {
                    await loadConversations()
                }
                #endif
            }
        }
    }
    
    func loadConversations() async {
        #if DEBUG
        if isPreviewing || authManager is PreviewAuthManager {
            // Utiliser des données factices pour la prévisualisation
            self.conversations = PreviewData.conversations
            self.isLoading = false
            return
        }
        #endif
        
        guard let userId = authManager.user?.uid else {
            errorMessage = "Utilisateur non connecté"
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // Récupérer les conversations depuis Firestore
            let db = Firestore.firestore()
            let conversationsRef = db.collection("conversations")
                .whereField("participantIds", arrayContains: userId)
            
            let snapshot = try await conversationsRef.getDocuments()
            
            var loadedConversations = [Conversation]()
            
            for document in snapshot.documents {
                let data = document.data()
                
                // Récupérer les IDs des participants
                guard let participantIds = data["participantIds"] as? [String] else { continue }
                
                // Récupérer les données des participants
                var participants = [User]()
                for participantId in participantIds {
                    if participantId == userId {
                        // Ajouter l'utilisateur actuel
                        if let currentUser = authManager.user {
                            participants.append(authManager.createLocalUser(from: currentUser))
                        }
                    } else {
                        // Récupérer l'autre participant (coach ou utilisateur)
                        let userDoc = try await db.collection("users").document(participantId).getDocument()
                        if let userData = userDoc.data() {
                            let user = User(
                                id: participantId,
                                name: userData["name"] as? String ?? "Utilisateur",
                                email: userData["email"] as? String ?? "",
                                profileImage: userData["profileImage"] as? String
                            )
                            participants.append(user)
                        }
                    }
                }
                
                // Récupérer le dernier message
                var lastMessage: Message?
                if let lastMessageData = data["lastMessage"] as? [String: Any],
                   let content = lastMessageData["content"] as? String,
                   let senderId = lastMessageData["senderId"] as? String,
                   let timestamp = lastMessageData["timestamp"] as? Timestamp {
                    
                    // Trouver l'expéditeur
                    let sender = participants.first { $0.id == senderId } ?? User(id: senderId, name: "Inconnu", email: "")
                    
                    lastMessage = Message(
                        id: UUID(),
                        sender: sender,
                        content: content,
                        timestamp: timestamp.dateValue(),
                        isRead: lastMessageData["isRead"] as? Bool ?? false
                    )
                }
                
                // Créer la conversation
                let conversation = Conversation(
                    id: UUID(uuidString: document.documentID) ?? UUID(),
                    participants: participants,
                    lastMessage: lastMessage,
                    unreadCount: data["unreadCount.\(userId)"] as? Int ?? 0
                )
                
                loadedConversations.append(conversation)
            }
            
            // Trier les conversations par date du dernier message
            loadedConversations.sort { (conv1, conv2) -> Bool in
                guard let date1 = conv1.lastMessage?.timestamp else { return false }
                guard let date2 = conv2.lastMessage?.timestamp else { return true }
                return date1 > date2
            }
            
            DispatchQueue.main.async {
                self.conversations = loadedConversations
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Erreur: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

struct ConversationRow: View {
    let conversation: Conversation
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar du participant (autre que l'utilisateur actuel)
            if let otherParticipant = conversation.participants.count > 1 ? conversation.participants[1] : conversation.participants.first {
                if let imageUrl = otherParticipant.profileImage, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure:
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Text(String(otherParticipant.name.prefix(1)))
                                        .font(.title)
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(otherParticipant.name.prefix(1)))
                                .font(.title)
                                .foregroundColor(.accentColor)
                        )
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Nom du participant
                if let otherParticipant = conversation.participants.count > 1 ? conversation.participants[1] : conversation.participants.first {
                    Text(otherParticipant.name)
                        .font(.headline)
                        .lineLimit(1)
                } else {
                    Text("Conversation")
                        .font(.headline)
                }
                
                // Dernier message
                if let lastMessage = conversation.lastMessage {
                    Text(lastMessage.content)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Heure du dernier message
                if let lastMessage = conversation.lastMessage {
                    Text(formatDate(lastMessage.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Badge de messages non lus
                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            // Format "10:30"
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Hier"
        } else if calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear) {
            // Format "Lundi"
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "fr_FR")
            return formatter.string(from: date).capitalized
        } else {
            // Format "12/04"
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    MessagingView()
        .environmentObject(AuthManager())
}

#if DEBUG
#Preview {
    MessagingView()
        .environmentObject(PreviewAuthManager())
}
#else
// Pas de prévisualisation en mode release
#endif 