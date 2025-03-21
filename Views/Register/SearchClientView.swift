import SwiftUI

struct SearchClientView: View {
    @ObservedObject var viewModel: AcheterJeuViewModel
    @State private var searchText = ""
    @State private var showingAddBuyerView = false
    @Environment(\.presentationMode) var presentationMode
    var game: Game
    
    var body: some View {
        VStack {
            // Barre de recherche
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Rechercher un client...", text: $searchText)
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
            
            // Liste des clients
            if viewModel.isLoadingBuyers {
                ProgressView()
            } else {
                List(viewModel.filteredBuyers(searchText: searchText), id: \.id) { buyer in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(buyer.firstName) \(buyer.name)")
                                .font(.headline)
                            if let email = buyer.email, !email.isEmpty {
                                Text(email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            if let phoneNumber = buyer.phoneNumber, !phoneNumber.isEmpty {
                                Text(phoneNumber)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.selectBuyer(buyer)
                            viewModel.buyGame(game: game, buyerId: buyer.id ?? "", buyerName: "\(buyer.firstName) \(buyer.name)")
                            presentationMode.wrappedValue.dismiss()
                            viewModel.resetTransactionState()
                        }) {
                            Text("Sélectionner")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .navigationTitle("Rechercher un client")
        .navigationBarItems(trailing: Button(action: {
            showingAddBuyerView = true
        }) {
            Image(systemName: "plus")
        })
        .onAppear {
            viewModel.fetchBuyers()
        }
        .sheet(isPresented: $showingAddBuyerView) {
            NavigationView {
                AjouterBuyerView(onBuyerAdded: {
                    showingAddBuyerView = false
                    viewModel.fetchBuyers()  // Recharger la liste après l'ajout
                })
                .navigationBarItems(trailing: Button("Fermer") {
                    showingAddBuyerView = false
                })
            }
        }
    }
}
