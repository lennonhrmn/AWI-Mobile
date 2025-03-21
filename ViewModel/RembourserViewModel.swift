import SwiftUI
import Combine

struct SellerSummary: Identifiable {
    var id: String { sellerId }
    let sellerId: String
    let sellerName: String
    let games: [Game]
    let totalSales: Double
    let totalCommission: Double
    let totalToRefund: Double
}

class RembourserViewModel: ObservableObject {
    @Published var soldGames: [Game] = []
    @Published var sellerSummaries: [SellerSummary] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var alertItem: AlertItem?
    @Published var showingSoldGameDetails = false
    @Published var selectedSellerSummary: SellerSummary?
    
    struct AlertItem: Identifiable {
        var id = UUID()
        var title: String
        var message: String
    }
    
    // Filtrer les vendeurs en fonction du texte de recherche
    func filteredSellerSummaries(searchText: String) -> [SellerSummary] {
        if searchText.isEmpty {
            return sellerSummaries
        }
        
        return sellerSummaries.filter { summary in
            summary.sellerName.localizedCaseInsensitiveContains(searchText) ||
            summary.sellerId.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // Récupérer tous les jeux vendus
    func fetchSoldGames() {
        isLoading = true
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games") else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
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
                    let allGames = try JSONDecoder().decode([Game].self, from: data)
                    // Filtrer seulement les jeux avec le statut "vendu"
                    self.soldGames = allGames.filter { $0.status == "vendu" }
                    self.generateSellerSummaries()
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // Grouper les jeux par vendeur et calculer les totaux
    private func generateSellerSummaries() {
        // Regrouper les jeux par vendeur
        let groupedBySeller = Dictionary(grouping: soldGames) { $0.sellerId }
        
        // Pour chaque vendeur, créer un résumé
        sellerSummaries = groupedBySeller.map { sellerId, games in
            let sellerName = games.first?.sellerName ?? "Inconnu"
            let totalSales = games.reduce(0) { $0 + $1.price }
            let totalCommission = games.reduce(0) { $0 + $1.commission }
            let totalToRefund = totalSales - totalCommission
            
            return SellerSummary(
                sellerId: sellerId,
                sellerName: sellerName,
                games: games,
                totalSales: totalSales,
                totalCommission: totalCommission,
                totalToRefund: totalToRefund
            )
        }
    }
    
    // Préparer le remboursement d'un vendeur
    func initiateSellerPayment(sellerSummary: SellerSummary) {
        self.selectedSellerSummary = sellerSummary
        self.showingSoldGameDetails = true
    }
    
    // Marquer tous les jeux d'un vendeur comme payés
    func paySellerForGames(sellerSummary: SellerSummary) {
        isLoading = true
        
        let group = DispatchGroup()
        var successCount = 0
        var failureCount = 0
        
        for game in sellerSummary.games {
            group.enter()
            
            guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games/\(game.id)") else {
                failureCount += 1
                group.leave()
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = [
                "status": "payé"
            ]
            
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                failureCount += 1
                group.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { group.leave() }
                
                if let error = error {
                    DispatchQueue.main.async {
                        failureCount += 1
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        failureCount += 1
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    successCount += 1
                }
            }.resume()
        }
        
        group.notify(queue: .main) {
            self.isLoading = false
            self.showingSoldGameDetails = false
            
            if failureCount == 0 {
                self.alertItem = AlertItem(
                    title: "Succès",
                    message: "Le vendeur \(sellerSummary.sellerName) a été remboursé avec succès pour \(successCount) jeux."
                )
                
                // Mettre à jour la liste des jeux
                self.fetchSoldGames()
            } else {
                self.alertItem = AlertItem(
                    title: "Avertissement",
                    message: "\(successCount) jeux ont été marqués comme payés, mais \(failureCount) jeux n'ont pas pu être mis à jour."
                )
                
                // Mettre à jour la liste des jeux pour refléter les changements partiels
                self.fetchSoldGames()
            }
        }
    }
}
