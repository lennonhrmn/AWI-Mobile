import SwiftUI

struct InventoryView: View {
    @StateObject private var viewModel = GameViewModel()
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
            
            // Filter Button
            HStack {
                Button(action: {
                    isShowingFilters.toggle()
                }) {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text("Filtres")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
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
                            ForEach(viewModel.filteredGames, id: \._id) { game in
                                GameCard(game: game)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    if viewModel.filteredGames.isEmpty && !viewModel.searchText.isEmpty {
                        Text("Aucun jeu trouvé pour '\(viewModel.searchText)'")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                
                if isShowingFilters {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            isShowingFilters = false
                        }
                    
                    FilterMenu(isShowingFilters: $isShowingFilters,
                             maxPrice: $viewModel.maxPrice,
                             absoluteMaxPrice: viewModel.absoluteMaxPrice)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 100)
                        .padding(.horizontal)
                }
            }
        }
        .onAppear {
            viewModel.fetchGames()
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView()
    }
}
