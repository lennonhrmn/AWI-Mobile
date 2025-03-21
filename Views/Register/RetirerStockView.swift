import SwiftUI

struct RetirerStockView: View {
    @StateObject private var viewModel = RetirerStockViewModel()
    @State private var isShowingFilters = false
    
    var body: some View {
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
                Text("Jeux en stock à retirer")
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
                                GameStockRemoveCard(game: game, onRemoveFromStock: {
                                    viewModel.removeFromStock(game: game)
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
        }
        .onAppear {
            viewModel.fetchGames()
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(
                title: Text(alertItem.title),
                message: Text(alertItem.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct GameStockRemoveCard: View {
    let game: Game
    let onRemoveFromStock: () -> Void
    
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
                Text("Status: Stock")
                    .font(.caption)
                    .padding(4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: onRemoveFromStock) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Retirer définitivement")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.red)
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

struct RetirerStockView_Previews: PreviewProvider {
    static var previews: some View {
        RetirerStockView()
    }
}
