import SwiftUI

struct BilanGeneralView: View {
    @State private var selectedReportType: String = "Général"
    @State private var totalSales: Double = 0
    @State private var amountToReimburse: Double = 0
    @State private var amountReimbursed: Double = 0
    @State private var gamesSoldNumber: Int = 0
    @State private var gamesInStockNumber: Int = 0
    @State private var potentialSales: Int = 0
    @State private var commissionsEarnings: Double = 0
    @State private var depositEarnings: Double = 0
    @State private var totalBuyers: Int = 0
    @State private var totalSellers: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Sélecteur pour choisir le rapport
                Picker("Type de rapport", selection: $selectedReportType) {
                    Text("Général").tag("Général")
                    Text("Session").tag("Session")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .onChange(of: selectedReportType) { _ in
                    // Recharger les données dès que le type de rapport change
                    loadBilanData()
                }

                Text(selectedReportType == "Général" ? "Bilan Général" : "Bilan de la Session")
                    .font(.title)
                    

                // Cartes de statistiques
                HStack(spacing: 20) {
                    StatCard(title: "Totales", value: String(format: "%.2f€", totalSales))
                    StatCard(title: "Potentielles", value: "\(potentialSales)")
                }
                
                Text("Jeux")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 20) {
                    StatCard(title: "Vendus", value: "\(gamesSoldNumber)")
                    StatCard(title: "En stock", value: "\(gamesInStockNumber)")
                }
                
                Text("Dettes")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 20) {
                    StatCard(title: "À rembourser", value: String(format: "%.2f€", amountToReimburse))
                    StatCard(title: "Remboursé", value: String(format: "%.2f€", amountReimbursed))
                }
                
                Text("Earnings")
                    .font(.headline)
                    .foregroundColor(.primary)
                VStack(spacing: 20){
                    HStack(spacing: 20) {
                        StatCard(title: "Commissions", value: String(format: "%.2f€", commissionsEarnings))
                        StatCard(title: "Dépôts", value: String(format: "%.2f€", depositEarnings))
                    }
                    StatCard(title: "Total earnings", value: String(format: "%.2f€", commissionsEarnings + depositEarnings))
                }
                
                VStack(spacing: 20){
                    Text("Clients")
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack(spacing: 20) {
                        StatCard(title: "Acheteurs", value: "\(totalBuyers)")
                        StatCard(title: "Vendeurs", value: "\(totalSellers)")
                    }
                }
            }
        }
        .onAppear {
            loadBilanData() // Charger les données lors de l'apparition de la vue
        }
    }
    
    private func loadBilanData() {
        let urlString: String
        
        // Choisir l'URL en fonction du type de rapport sélectionné
        if selectedReportType == "Général" {
            urlString = "https://depot-vente-api.losherrmannos.duckdns.org/api/report"
        } else {
            urlString = "https://depot-vente-api.losherrmannos.duckdns.org/api/report/session"
        }

        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Erreur lors de la récupération des données : \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Données non disponibles")
                return
            }
            
            do {
                let report = try JSONDecoder().decode(BilanReport.self, from: data)
                
                DispatchQueue.main.async {
                    self.totalSales = report.totalSales
                    self.amountToReimburse = report.amountToReimburse
                    self.amountReimbursed = report.amountReimbursed
                    self.gamesSoldNumber = report.gamesSoldNumber
                    self.gamesInStockNumber = report.gamesInStockNumber
                    self.potentialSales = report.potentialSales
                    self.commissionsEarnings = report.commissionsEarnings
                    self.depositEarnings = report.depositEarnings
                    self.totalBuyers = report.totalBuyers
                    self.totalSellers = report.totalSellers
                }
            } catch {
                print("Erreur de décodage JSON : \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct BilanGeneralView_Previews: PreviewProvider {
    static var previews: some View {
        BilanGeneralView()
    }
}
