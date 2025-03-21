import SwiftUI

struct AcheterJeuView: View {
    @StateObject private var viewModel = AcheterJeuViewModel()
    @State private var isShowingFilters = false
    @State private var showingPurchaseOptions = false
    @State private var showingClientSearch = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Rechercher un jeu...", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                // Title to indicate purpose of view
                HStack {
                    Text("Jeux en vente")
                        .font(.headline)
                    Spacer()
                }
                .padding(.horizontal)
                
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
                                ForEach(viewModel.filteredGames, id: \.id) { game in
                                    GameBuyCard(game: game, onBuyGame: {
                                        viewModel.initiateGamePurchase(game: game)
                                        showingPurchaseOptions = true
                                    })
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                        
                        if viewModel.filteredGames.isEmpty && !viewModel.isLoading {
                            if !viewModel.searchText.isEmpty {
                                Text("Aucun jeu trouvé pour '\(viewModel.searchText)'")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                Text("Aucun jeu en stock actuellement")
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                    }
                }
                
                NavigationLink(
                    destination: AjouterBuyerView(
                        acheterViewModel: viewModel,
                        game: viewModel.selectedGame,
                        onBuyerAdded: {
                            viewModel.fetchBuyers()
                        }
                    ),
                    isActive: $viewModel.showingNewBuyerForm
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: SearchClientView(
                        viewModel: viewModel,
                        game: viewModel.selectedGame ?? Game(
                            _id: "",
                            id: "",
                            name: "",
                            editor: "",
                            price: 0,
                            sellerId: "",
                            sellerName: "",
                            status: "",
                            depositFee: 0,
                            commission: 0,
                            sessionId: ""
                        )
                    ),
                    isActive: $viewModel.showingClientSearch
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                viewModel.fetchGames()
                viewModel.resetTransactionState()
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Alerte avec 3 options
            .actionSheet(isPresented: $showingPurchaseOptions) {
                ActionSheet(
                    title: Text("Options de vente"),
                    message: Text("Comment souhaitez-vous procéder?"),
                    buttons: [
                        .default(Text("Sans facture")) {
                            if let game = viewModel.selectedGame {
                                viewModel.buyGameWithoutInvoice(game: game)
                            }
                        },
                        .default(Text("Avec facture")) {
                            viewModel.showingClientSearch = true
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct GameBuyCard: View {
    let game: Game
    let onBuyGame: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(game.name)
                        .font(.headline)
                    Text(game.editor)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("\(Int(game.price))€")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Vendeur: \(game.sellerName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            HStack {
                Text("Status: \(game.status)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: onBuyGame) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Vendre")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.blue)
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

struct AcheterJeuView_Previews: PreviewProvider {
    static var previews: some View {
        AcheterJeuView()
    }
}
