import SwiftUI

struct RetirerRayonView: View {
    @StateObject private var viewModel = RetirerRayonViewModel()
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
                Text("Jeux en rayon à retirer")
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
                                GameRayonCard(game: game, onRetireFromRayon: {
                                    viewModel.retireFromRayon(game: game)
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
                            Text("Aucun jeu en rayon actuellement")
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

struct GameRayonCard: View {
    let game: Game
    let onRetireFromRayon: () -> Void
    
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
                Text("Status: Rayon")
                    .font(.caption)
                    .padding(4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
                
                Spacer()
                
                Button(action: onRetireFromRayon) {
                    HStack {
                        Image(systemName: "arrow.left.circle")
                        Text("Retirer du rayon")
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange)
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

struct RetirerRayonView_Previews: PreviewProvider {
    static var previews: some View {
        RetirerRayonView()
    }
}
