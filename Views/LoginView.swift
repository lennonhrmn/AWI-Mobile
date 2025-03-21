import SwiftUI
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var userRole: String  // Suppression du '?'
    
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            Text("Connexion")
                .font(.largeTitle)
                .padding(.bottom, 20)
            
            TextField("Nom d'utilisateur", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            SecureField("Mot de passe", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                login()
            }) {
                Text("Se connecter")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
    }
    
    func login() {
        guard let url = URL(string: "https://depot-vente-api.losherrmannos.duckdns.org/api/auth/login") else { return }
        
        let parameters = ["username": username, "password": password]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    errorMessage = "Erreur réseau"
                }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let role = json["role"] as? String {
                
                DispatchQueue.main.async {
                    userRole = role
                    isLoggedIn = true
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Identifiants incorrects"
                }
            }
        }.resume()
    }
}
