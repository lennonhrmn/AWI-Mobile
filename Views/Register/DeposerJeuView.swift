import SwiftUI

struct DeposerJeuView: View {
    @StateObject private var viewModel = DeposerJeuViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Information du jeu")) {
                TextField("Nom du jeu", text: $viewModel.gameNameInput)
                TextField("Éditeur", text: $viewModel.publisherInput)
                TextField("Prix", text: $viewModel.priceInput)
                    .keyboardType(.decimalPad)
                
                // Champ de recherche vendeur
                VStack(alignment: .leading) {
                    if let seller = viewModel.selectedSeller {
                        Text("Vendeur sélectionné : \(seller.fullName)")
                            .foregroundColor(.green)
                    }
                    
                    TextField("Rechercher un vendeur", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if !viewModel.filteredSellers.isEmpty {
                        List(viewModel.filteredSellers) { seller in
                            Button(action: {
                                viewModel.selectedSeller = seller
                                viewModel.searchText = ""
                            }) {
                                Text("\(seller.firstName) \(seller.name)")
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            if viewModel.isSuccess {
                Text("Jeu ajouté avec succès !")
                    .foregroundColor(.green)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Section {
                Button(action: {
                    guard let priceValue = Double(viewModel.priceInput) else { return }
                    viewModel.submitGame(
                        gameName: viewModel.gameNameInput,
                        publisher: viewModel.publisherInput,
                        price: priceValue
                    )
                }) {
                    Text("Déposer le jeu")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .disabled(viewModel.selectedSeller == nil ||
                         viewModel.gameNameInput.isEmpty ||
                         viewModel.publisherInput.isEmpty ||
                         viewModel.priceInput.isEmpty)
                .listRowBackground(Color.blue)
            }
        }
    }
}
