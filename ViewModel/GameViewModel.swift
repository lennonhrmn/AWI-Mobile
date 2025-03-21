import SwiftUI

class GameViewModel: ObservableObject {
    @Published var games: [Game] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var maxPrice: Double = 1000
    
    var absoluteMaxPrice: Double {
        let max = games.map { Double($0.price)}.max() ?? 1000
        return max.rounded(to: 100, roundingRule: .up)
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
        
        // Filtre par prix maximum
        filtered = filtered.filter { game in
            let price = Double(game.price)
            return price <= maxPrice
        }
        
        return filtered
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
                    // Initialiser le prix maximum au prix le plus élevé arrondi à la centaine supérieure
                    self.maxPrice = self.absoluteMaxPrice
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// Extension pour arrondir les nombres
extension Double {
    func rounded(to nearest: Double, roundingRule: FloatingPointRoundingRule) -> Double {
        (self / nearest).rounded(roundingRule) * nearest
    }
}

