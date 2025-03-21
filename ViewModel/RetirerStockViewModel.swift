import SwiftUI

class RetirerStockViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var alertItem: AlertItem?
    
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
                game.sellerName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func fetchGames() {
        isLoading = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games/stock") else {
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
    
    func removeFromStock(game: Game) {
        isLoading = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games/\(game.id)") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["status": "retiré"]
        
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
                    // Remove the game from the list
                    if let index = self.games.firstIndex(where: { $0.id == game.id }) {
                        self.games.remove(at: index)
                    }
                    
                    self.alertItem = AlertItem(
                        title: "Succès",
                        message: "Le jeu '\(game.name)' a été retiré des stocks avec succès."
                    )
                } else {
                    self.errorMessage = "Erreur: Code HTTP \(httpResponse.statusCode)"
                }
            }
        }.resume()
    }

}
