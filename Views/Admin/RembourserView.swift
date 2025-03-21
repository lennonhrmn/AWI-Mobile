import SwiftUI

struct RembourserView: View {
    @StateObject private var viewModel = RembourserViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un vendeur...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                    } else if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredSellerSummaries(searchText: searchText), id: \.sellerId) { sellerSummary in
                                    SellerSummaryCard(sellerSummary: sellerSummary, onPay: {
                                        viewModel.initiateSellerPayment(sellerSummary: sellerSummary)
                                    })
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        if viewModel.filteredSellerSummaries(searchText: searchText).isEmpty && !viewModel.isLoading {
                            if !searchText.isEmpty {
                                Text("Aucun vendeur trouvé pour '\(searchText)'")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                Text("Aucun vendeur à rembourser actuellement")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchSoldGames()
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $viewModel.showingSoldGameDetails) {
                if let selectedSeller = viewModel.selectedSellerSummary {
                    SellerGamesDetailView(
                        viewModel: viewModel,
                        sellerSummary: selectedSeller
                    )
                }
            }
        }
    }
}

struct SellerSummaryCard: View {
    let sellerSummary: SellerSummary
    let onPay: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(sellerSummary.sellerName)
                        .font(.headline)
                    Text("ID: \(sellerSummary.sellerId)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(sellerSummary.totalToRefund))€")
                        .font(.headline)
                        .foregroundColor(.green)
                    Text("\(sellerSummary.games.count) jeux vendus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total ventes:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(sellerSummary.totalSales))€")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Commission:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(sellerSummary.totalCommission))€")
                        .font(.subheadline)
                }
                
                Spacer()
                
                Button(action: onPay) {
                    HStack {
                        Image(systemName: "eurosign.circle")
                        Text("Rembourser")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct SellerGamesDetailView: View {
    let viewModel: RembourserViewModel
    let sellerSummary: SellerSummary
    
    var body: some View {
        VStack {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(sellerSummary.sellerName)
                        .font(.title2)
                        .bold()
                    Text("ID: \(sellerSummary.sellerId)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            
            // Summary
            HStack(spacing: 20) {
                VStack {
                    Text("Total ventes")
                        .font(.caption)
                    Text("\(Int(sellerSummary.totalSales))€")
                        .bold()
                }
                
                VStack {
                    Text("Commission")
                        .font(.caption)
                    Text("\(Int(sellerSummary.totalCommission))€")
                        .bold()
                }
                
                VStack {
                    Text("À rembourser")
                        .font(.caption)
                    Text("\(Int(sellerSummary.totalToRefund))€")
                        .bold()
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Games list
            List {
                ForEach(sellerSummary.games, id: \.id) { game in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(game.name)
                                .font(.headline)
                            Text(game.editor)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(Int(game.price))€")
                                .font(.subheadline)
                            Text("Commission: \(Int(game.commission))€")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Pay button
            Button(action: {
                viewModel.paySellerForGames(sellerSummary: sellerSummary)
            }) {
                HStack {
                    Image(systemName: "eurosign.circle.fill")
                    Text("Confirmer le remboursement")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct RembourserView_Previews: PreviewProvider {
    static var previews: some View {
        RembourserView()
    }
}
