import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        // Vérifier si l'utilisateur est déjà connecté
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            self.isAuthenticated = user != nil
            self.user = user
        }
    }
    
    func signIn(email: String, password: String) {
        self.isLoading = true
        self.error = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                self.isAuthenticated = result?.user != nil
                self.user = result?.user
                
                // Sauvegarder l'ID utilisateur dans UserDefaults
                if let uid = result?.user.uid {
                    UserDefaults.standard.set(uid, forKey: "userID")
                }
                
                // Synchroniser les données utilisateur après connexion
                self.syncUserData()
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        self.isLoading = true
        self.error = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }
                
                guard let user = result?.user else { return }
                
                // Mettre à jour le profil utilisateur avec son nom
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Erreur lors de la mise à jour du profil: \(error.localizedDescription)")
                    }
                }
                
                // Créer un document utilisateur dans Firestore
                self.createUserDocument(user: user, name: name)
                
                self.isAuthenticated = true
                self.user = user
                
                // Sauvegarder l'ID utilisateur dans UserDefaults
                UserDefaults.standard.set(user.uid, forKey: "userID")
            }
        }
    }
    
    private func createUserDocument(user: FirebaseAuth.User, name: String) {
        let db = Firestore.firestore()
        
        // Créer le document utilisateur avec les informations de base
        db.collection("users").document(user.uid).setData([
            "name": name,
            "email": user.email ?? "",
            "uid": user.uid,
            "createdAt": FieldValue.serverTimestamp(),
            "lastLogin": FieldValue.serverTimestamp(),
            "photoURL": user.photoURL?.absoluteString ?? "",
            "workouts": [],
            "nutrition": []
        ]) { error in
            if let error = error {
                print("Erreur lors de la création du document utilisateur: \(error.localizedDescription)")
            } else {
                print("Document utilisateur créé avec succès")
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.user = nil
            
            // Nettoyer les données utilisateur
            UserDefaults.standard.removeObject(forKey: "userID")
        } catch let error {
            self.error = error.localizedDescription
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // Connecter l'utilisateur avec Google (à implémenter ultérieurement)
    func signInWithGoogle() {
        self.error = "Connexion avec Google pas encore implémentée"
    }
    
    // Connecter l'utilisateur avec Apple (à implémenter ultérieurement)
    func signInWithApple() {
        self.error = "Connexion avec Apple pas encore implémentée"
    }
    
    // Synchroniser les données utilisateur après connexion
    private func syncUserData() {
        guard let user = user else { return }
        
        let db = Firestore.firestore()
        
        // Mettre à jour la date de dernière connexion
        db.collection("users").document(user.uid).updateData([
            "lastLogin": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Erreur lors de la mise à jour de la date de connexion: \(error.localizedDescription)")
            }
        }
        
        // Récupérer les données de l'utilisateur
        db.collection("users").document(user.uid).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let document = document, document.exists {
                print("Données utilisateur récupérées avec succès")
                
                // Récupérer et traiter les données utilisateur
                // Note: Ces données devront être gérées par les managers appropriés (WorkoutManager, etc.)
            } else {
                print("Document utilisateur introuvable: \(error?.localizedDescription ?? "erreur inconnue")")
                
                // Si le document n'existe pas, le créer
                if let displayName = user.displayName {
                    self.createUserDocument(user: user, name: displayName)
                } else {
                    self.createUserDocument(user: user, name: "Utilisateur")
                }
            }
        }
    }
    
    // Convertir Firebase User vers notre modèle User
    func createLocalUser(from firebaseUser: FirebaseAuth.User) -> User {
        return User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? "Utilisateur",
            email: firebaseUser.email ?? "",
            profileImage: firebaseUser.photoURL?.absoluteString
        )
    }
    
    // Obtenir l'utilisateur courant au format de notre modèle User
    var currentUser: User? {
        guard let firebaseUser = user else { return nil }
        return createLocalUser(from: firebaseUser)
    }
} 