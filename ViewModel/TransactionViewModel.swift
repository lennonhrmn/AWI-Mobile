import SwiftUI

class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchTransactions() {
        isLoading = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/transactions") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Pas de données reçues"
                    return
                }
                
                do {
                    self.transactions = try JSONDecoder().decode([Transaction].self, from: data)
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
