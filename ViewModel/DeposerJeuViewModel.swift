import SwiftUI
import Combine

class DeposerJeuViewModel: ObservableObject {
    @Published var sellers: [Seller] = []
    @Published var searchText = ""
    @Published var filteredSellers: [Seller] = []
    @Published var selectedSeller: Seller?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
    @Published var gameNameInput = ""
    @Published var publisherInput = ""
    @Published var priceInput = ""
    
    private var cancellables = Set<AnyCancellable>()
    private let sessionViewModel = SessionViewModel()
    
    init() {
        sessionViewModel.fetchSessions()
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.searchSellers(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func searchSellers(_ query: String) {
        if query.count < 3 {
            filteredSellers = []
            return
        }
        
        let lowercasedQuery = query.lowercased()
        
        if !sellers.isEmpty {
            filteredSellers = sellers.filter { seller in
                seller.firstName.lowercased().contains(lowercasedQuery) ||
                seller.name.lowercased().contains(lowercasedQuery)
            }
        } else {
            fetchSellers()
        }
    }
    
    func fetchSellers() {
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/sellers") else {
            errorMessage = "URL invalide"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let data = data else {
                    self?.errorMessage = "Pas de données reçues"
                    return
                }
                
                do {
                    let sellers = try JSONDecoder().decode([Seller].self, from: data)
                    self?.sellers = sellers
                    if let searchText = self?.searchText, !searchText.isEmpty {
                        self?.searchSellers(searchText)
                    }
                } catch {
                    self?.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func submitGame(gameName: String, publisher: String, price: Double) {
        guard let seller = selectedSeller else {
            errorMessage = "Veuillez sélectionner un vendeur"
            return
        }
        
        guard let session = sessionViewModel.sessions.first else {
            errorMessage = "Aucune session active trouvée"
            return
        }
        
        let depositFee = session.depositFeeType == "relative" ?
            Int(Double(price) * Double(session.depositFee) / 100.0) :
            session.depositFee

        let commission = session.commissionType == "relative" ?
            Int(Double(price) * Double(session.commission) / 100.0) :
            session.commission
        
        // Étape 1: Récupérer le prochain ID
        guard let nextIdUrl = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games/nextId") else {
            errorMessage = "URL invalide pour nextId"
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: nextIdUrl) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.isLoading = false
                    self?.errorMessage = "Erreur lors de la récupération du nextId: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self?.isLoading = false
                    self?.errorMessage = "Pas de données reçues pour nextId"
                    return
                }
                
                // Essayons plusieurs formats possibles
                // 1. D'abord comme une simple chaîne de texte
                if let nextId = String(data: data, encoding: .utf8) {
                    // Nettoyage de la chaîne au cas où (enlever guillemets, espaces, etc.)
                    let cleanedNextId = nextId.trimmingCharacters(in: .whitespacesAndNewlines)
                                              .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                    
                    self?.createGameWithId(cleanedNextId, gameName: gameName, publisher: publisher,
                                          price: price, seller: seller, session: session,
                                          depositFee: depositFee, commission: commission)
                    return
                }
                
                // 2. Si ce n'est pas une simple chaîne, essayons d'autres formats JSON possibles
                do {
                    // Format {"nextId": "value"}
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let nextId = json["nextId"] as? String {
                        self?.createGameWithId(nextId, gameName: gameName, publisher: publisher,
                                              price: price, seller: seller, session: session,
                                              depositFee: depositFee, commission: commission)
                        return
                    }
                    
                    // Format ["value"]
                    if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [String],
                       let nextId = jsonArray.first {
                        self?.createGameWithId(nextId, gameName: gameName, publisher: publisher,
                                              price: price, seller: seller, session: session,
                                              depositFee: depositFee, commission: commission)
                        return
                    }
                    
                    // Format {"value"}
                    if let nextId = try JSONSerialization.jsonObject(with: data) as? String {
                        self?.createGameWithId(nextId, gameName: gameName, publisher: publisher,
                                              price: price, seller: seller, session: session,
                                              depositFee: depositFee, commission: commission)
                        return
                    }
                    
                    // Si on arrive ici, aucun format n'a fonctionné
                    self?.isLoading = false
                    self?.errorMessage = "Format de nextId non reconnu"
                    
                } catch {
                    self?.isLoading = false
                    self?.errorMessage = "Erreur lors du traitement de nextId: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // Nouvelle fonction pour créer le jeu une fois l'ID récupéré
    private func createGameWithId(_ gameId: String, gameName: String, publisher: String, price: Double, seller: Seller, session: Session, depositFee: Int, commission: Int) {
        let gameData: [String: Any] = [
            "id": gameId,
            "name": gameName,
            "editor": publisher,
            "price": price,
            "sellerId": seller.id,
            "sellerName": "\(seller.firstName) \(seller.name)",
            "status": "stock",
            "depositFee": depositFee,
            "commission": commission,
            "sessionId": session.id
        ]
        
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/games") else {
            errorMessage = "URL invalide pour la création du jeu"
            isLoading = false
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: gameData) else {
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
        selectedSeller = nil
        searchText = ""
        gameNameInput = ""
        publisherInput = ""
        priceInput = ""
    }
}
