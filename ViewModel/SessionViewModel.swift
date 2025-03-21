import SwiftUI

class SessionViewModel: ObservableObject {
    @Published var sessions: [Session] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://depot-vente-api.losherrmannos.duckdns.org/api/sessions"
    
    func fetchSessions() {
        isLoading = true
        guard let url = URL(string: baseURL) else {
            errorMessage = "URL invalide"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Erreur réseau: \(error.localizedDescription)"
                    print("Erreur réseau: \(error)")
                    return
                }

                guard let data = data else {
                    self.errorMessage = "Pas de données reçues"
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .custom({ decoder in
                        let container = try decoder.singleValueContainer()
                        let dateString = try container.decode(String.self)
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                        if let date = formatter.date(from: dateString) {
                            return date
                        } else {
                            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
                        }
                    })

                    self.sessions = try decoder.decode([Session].self, from: data)
                    print("Sessions décodées avec succès: \(self.sessions)")
                } catch {
                    self.errorMessage = "Erreur de décodage: \(error.localizedDescription)"
                    print("Erreur de décodage: \(error)")
                    print("JSON reçu: \(String(data: data, encoding: .utf8) ?? "non lisible")")
                }
            }
        }.resume()
    }

    
    func addSession(_ session: Session) {
        guard let url = URL(string: baseURL) else {
            errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(session.createRequest)
        } catch {
            errorMessage = "Erreur d'encodage: \(error.localizedDescription)"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.fetchSessions()
            }
        }.resume()
    }
    
    func updateSession(_ session: Session) {
        guard let url = URL(string: "\(baseURL)/\(session._id)") else {
            errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(session.createRequest)
        } catch {
            errorMessage = "Erreur d'encodage: \(error.localizedDescription)"
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.fetchSessions()
            }
        }.resume()
    }
    
    func deleteSession(_ session: Session) {
        guard let url = URL(string: "\(baseURL)/\(session._id)") else {
            errorMessage = "URL invalide"
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.fetchSessions()
            }
        }.resume()
    }
}
