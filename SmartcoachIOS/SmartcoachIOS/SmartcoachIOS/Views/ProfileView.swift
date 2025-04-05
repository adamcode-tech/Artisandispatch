import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = authManager.currentUser {
                    // Avatar et nom
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color("PrimaryColor"))
                        
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    
                    // Liste des options
                    List {
                        Section(header: Text("Compte")) {
                            NavigationLink(destination: Text("Éditer le profil")) {
                                SettingsRow(icon: "person.fill", title: "Éditer le profil", color: .blue)
                            }
                            
                            NavigationLink(destination: Text("Objectifs de fitness")) {
                                SettingsRow(icon: "target", title: "Objectifs de fitness", color: .green)
                            }
                            
                            NavigationLink(destination: Text("Historique des activités")) {
                                SettingsRow(icon: "clock.fill", title: "Historique des activités", color: .orange)
                            }
                        }
                        
                        Section(header: Text("Préférences")) {
                            NavigationLink(destination: Text("Notifications")) {
                                SettingsRow(icon: "bell.fill", title: "Notifications", color: .red)
                            }
                            
                            NavigationLink(destination: Text("Préférences alimentaires")) {
                                SettingsRow(icon: "leaf.fill", title: "Préférences alimentaires", color: .green)
                            }
                            
                            NavigationLink(destination: Text("Unités de mesure")) {
                                SettingsRow(icon: "ruler.fill", title: "Unités de mesure", color: .purple)
                            }
                        }
                        
                        Section(header: Text("Application")) {
                            NavigationLink(destination: Text("Confidentialité")) {
                                SettingsRow(icon: "lock.fill", title: "Confidentialité", color: .gray)
                            }
                            
                            NavigationLink(destination: Text("À propos")) {
                                SettingsRow(icon: "info.circle.fill", title: "À propos", color: .blue)
                            }
                            
                            Button(action: {
                                showingLogoutAlert = true
                            }) {
                                SettingsRow(icon: "arrow.right.square.fill", title: "Déconnexion", color: .red)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    Text("Non connecté")
                        .font(.title)
                        .padding()
                    
                    Button("Se connecter") {
                        // Action pour se connecter
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Profil")
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Déconnexion"),
                    message: Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
                    primaryButton: .destructive(Text("Déconnecter")) {
                        authManager.signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct SettingsRow: View {
    var icon: String
    var title: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            Text(title)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthManager())
    }
} 