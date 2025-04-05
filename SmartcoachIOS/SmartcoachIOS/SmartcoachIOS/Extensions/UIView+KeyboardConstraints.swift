import UIKit

extension UIView {
    /// Cette méthode corrige les erreurs de contraintes de clavier en désactivant celles qui causent des conflits
    @objc func fixKeyboardConstraints() {
        let assistantClassName = "SystemInputAssistantView"
        let placeholderClassName = "_UIRemoteKeyboardPlaceholderView"
        
        for subview in subviews {
            // Parcourir récursivement la hiérarchie des vues
            subview.fixKeyboardConstraints()
            
            // Vérifier si la vue est une vue d'assistance de saisie du clavier
            if subview.description.contains(assistantClassName) {
                // Obtenir toutes les contraintes liées à cette vue
                for constraint in subview.constraints {
                    // Désactiver les contraintes de hauteur qui causent des conflits (contrainte assistantHeight)
                    if constraint.description.contains("assistantHeight") {
                        constraint.isActive = false
                    }
                }
            }
            
            // Traiter également les vues placeholder du clavier
            if subview.description.contains(placeholderClassName) {
                for constraint in subview.constraints {
                    if constraint.description.contains("assistantView.top") || 
                       constraint.description.contains("accessoryView.bottom") {
                        constraint.priority = .defaultLow
                    }
                }
            }
        }
    }
}

extension UIViewController {
    /// Configure le comportement du clavier pour éviter les problèmes de contraintes
    func setupKeyboardConstraintFixes() {
        NotificationCenter.default.addObserver(self, 
                                              selector: #selector(keyboardWillShow), 
                                              name: UIResponder.keyboardWillShowNotification, 
                                              object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        // Correction des contraintes au moment où le clavier apparaît
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Utiliser la méthode recommandée pour iOS 15+
            if #available(iOS 15.0, *) {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .forEach { $0.fixKeyboardConstraints() }
            } else {
                // Fallback pour iOS 14 et versions antérieures
                UIApplication.shared.windows.forEach { $0.fixKeyboardConstraints() }
            }
        }
    }
} 