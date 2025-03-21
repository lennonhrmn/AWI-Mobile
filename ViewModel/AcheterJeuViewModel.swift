import SwiftUI

class AcheterJeuViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var buyers: [Buyer] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var isLoadingBuyers = false
    @Published var errorMessage: String?
    @Published var alertItem: AlertItem?
    @Published var showingNewBuyerForm = false
    @Published var showingClientSearch = false
    @Published var selectedGame: Game?
    @Published var selectedBuyer: Buyer?
    
    struct AlertItem: Identifiable {
        var id = UUID()
        var title: String
        var message: String
    }
    
    var filteredGames: [Game] {
        var filtered = games
        
        // Filtre par texte
        if !searchText.isEmpty {
            filtered = filtered.filter { game in
                game.name.localizedCaseInsensitiveContains(searchText) ||
                game.editor.localizedCaseInsensitiveContains(searchText) ||
                game.sellerName.localizedCaseInsensitiveContains(searchText) ||
                game.id.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func filteredBuyers(searchText: String) -> [Buyer] {
        if searchText.isEmpty {
            return buyers
        }
        
        return buyers.filter { buyer in
            buyer.firstName.localizedCaseInsensitiveContains(searchText) ||
            buyer.name.localizedCaseInsensitiveContains(searchText) ||
            buyer.email.localizedCaseInsensitiveContains(searchText) ||
            buyer.phoneNumber.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func fetchGames() {
        isLoading = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games/rayon") else {
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
                    self.games = try JSONDecoder().decode([Game].self, from: data)
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func fetchBuyers() {
        isLoadingBuyers = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/buyers") else {
            errorMessage = "URL invalide pour récupérer les clients"
            isLoadingBuyers = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingBuyers = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "Pas de données clients reçues"
                    return
                }
                
                do {
                    self.buyers = try JSONDecoder().decode([Buyer].self, from: data)
                } catch {
                    self.errorMessage = "Erreur de décodage des clients: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func selectBuyer(_ buyer: Buyer) {
        self.selectedBuyer = buyer
    }
    
    func initiateGamePurchase(game: Game) {
        self.selectedGame = game
    }
    
    func buyGameWithoutInvoice(game: Game) {
        buyGame(game: game, buyerId: "none", buyerName: "none")
    }
    
    func buyGame(game: Game, buyerId: String, buyerName: String) {
        isLoading = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games/\(game.id)") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "status": "vendu",
            "buyerId": buyerId,
            "buyerName": buyerName
        ]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            errorMessage = "Erreur d'encodage: \(error.localizedDescription)"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "Réponse invalide du serveur"
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    // Suppression du jeu de la liste après vente
                    if let index = self.games.firstIndex(where: { $0.id == game.id }) {
                        self.games.remove(at: index)
                    }
                    
                    self.alertItem = AlertItem(
                        title: "Succès",
                        message: "Le jeu '\(game.name)' a été vendu avec succès."
                    )
                    
                    // Création de la transaction
                    self.createTransaction(game: game, buyerId: buyerId, buyerName: buyerName)
                    self.resetTransactionState()
                } else {
                    self.errorMessage = "Erreur: Code HTTP \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }
    
    func createTransaction(game: Game, buyerId: String, buyerName: String) {
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/transactions") else {
            errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let transactionData: [String: Any] = [
            "gameId": game.id,
            "gameName": game.name,
            "buyerId": buyerId,
            "buyerName": buyerName,
            "sellerId": game.sellerId,
            "sellerName": game.sellerName,
            "date": ISO8601DateFormatter().string(from: Date()), // Date actuelle
            "price": game.price,
            "depositFee": game.depositFee,
            "commission": game.commission,
            "sessionId": game.sessionId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: transactionData, options: [])
        } catch {
            errorMessage = "Erreur d'encodage JSON: \(error.localizedDescription)"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Erreur: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    self.errorMessage = "Erreur lors de la création de la transaction"
                    return
                }
                
                print("✅ Transaction créée avec succès pour \(game.name)")
            }
        }.resume()
    }
    
    func resetTransactionState() {
        selectedGame = nil
        selectedBuyer = nil
        showingNewBuyerForm = false
        showingClientSearch = false
        
        // Attendre un peu avant de réinitialiser l'alerte pour que l'utilisateur puisse la voir
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.alertItem = nil
        }
    }
}

