import SwiftUI

struct MettreEnRayonView: View {
    @StateObject private var viewModel = MettreEnRayonViewModel()
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
                Text("Jeux en stock à mettre en rayon")
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
                                GameStockCard(game: game, onMoveToRayon: {
                                    viewModel.moveToRayon(game: game)
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

struct GameStockCard: View {
    let game: Game
    let onMoveToRayon: () -> Void
    
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
                
                Button(action: onMoveToRayon) {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Mettre en rayon")
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

struct MettreEnRayonView_Previews: PreviewProvider {
    static var previews: some View {
        MettreEnRayonView()
    }
}
