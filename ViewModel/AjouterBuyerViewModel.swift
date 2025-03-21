import SwiftUI
import Combine

class AjouterBuyerViewModel: ObservableObject {
    @Published var firstNameInput = ""
    @Published var nameInput = ""
    @Published var emailInput = ""
    @Published var phoneNumberInput = ""
    @Published var addressInput = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func submitBuyer() {
        guard !firstNameInput.isEmpty, !nameInput.isEmpty else {
            errorMessage = "Le prénom et le nom sont requis"
            return
        }
        
        guard isValidEmail(emailInput) else {
            errorMessage = "Adresse email invalide"
            return
        }
        
        guard isValidPhoneNumber(phoneNumberInput) else {
            errorMessage = "Numéro de téléphone invalide"
            return
        }
        
        // Génération d'un ID à 6 chiffres
        let buyerId = generateSixDigitId()
        createBuyerWithId(buyerId)
    }
    
    // Générer un ID à 6 chiffres
    private func generateSixDigitId() -> String {
        let randomNumber = Int.random(in: 100000...999999)
        return String(randomNumber)
    }
    
    private func createBuyerWithId(_ buyerId: String) {
        isLoading = true
        
        let buyerData: [String: Any] = [
            "id": buyerId,
            "firstName": firstNameInput,
            "name": nameInput,
            "email": emailInput,
            "phoneNumber": phoneNumberInput,
            "address": addressInput
        ]
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/buyers") else {
            errorMessage = "URL invalide pour la création de l'acheteur"
            isLoading = false
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: buyerData) else {
            errorMessage = "Erreur de conversion des données"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Erreur réseau: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Réponse invalide du serveur"
                    return
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    self?.isSuccess = true
                    self?.errorMessage = nil
                    self?.resetForm()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.isSuccess = false
                    }
                default:
                    if let data = data,
                       let errorResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                        self?.errorMessage = errorResponse["message"] ?? "Erreur serveur: \(httpResponse.statusCode)"
                    } else {
                        self?.errorMessage = "Erreur serveur: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
    
    private func resetForm() {
        firstNameInput = ""
        nameInput = ""
        emailInput = ""
        phoneNumberInput = ""
        addressInput = ""
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty {
            return true // On permet un email vide
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        if phoneNumber.isEmpty {
            return true // On permet un numéro de téléphone vide
        }
        
        // Valider le format français ou international
        let phoneRegex = "^(\\+33|0)[1-9][0-9]{8}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
}
