import SwiftUI

struct AjouterBuyerView: View {
    @StateObject private var viewModel = AjouterBuyerViewModel()
        @Environment(\.presentationMode) var presentationMode
        var acheterViewModel: AcheterJeuViewModel? // Ajout de ce paramètre
        var game: Game? // Ajout de ce paramètre
        var onBuyerAdded: (() -> Void)?
    
    var body: some View {
        Form {
            Section(header: Text("Informations de l'acheteur")) {
                TextField("Prénom", text: $viewModel.firstNameInput)
                    .autocapitalization(.words)
                
                TextField("Nom", text: $viewModel.nameInput)
                    .autocapitalization(.words)
                
                TextField("Email", text: $viewModel.emailInput)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                TextField("Téléphone", text: $viewModel.phoneNumberInput)
                    .keyboardType(.phonePad)
                
                TextField("Adresse", text: $viewModel.addressInput)
                    .autocapitalization(.words)
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            if viewModel.isSuccess {
                Text("Acheteur ajouté avec succès !")
                    .foregroundColor(.green)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Section {
                Button(action: {
                    viewModel.submitBuyer()
                }) {
                    Text("Ajouter l'acheteur")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .disabled(viewModel.firstNameInput.isEmpty ||
                          viewModel.nameInput.isEmpty)
                .listRowBackground(Color.blue)
            }
        }
        .navigationTitle("Ajouter un acheteur")
        .onReceive(viewModel.$isSuccess) { success in
            if success {
                // Attendre un peu pour que l'utilisateur voie le message de succès
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onBuyerAdded?()
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct AjouterBuyerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AjouterBuyerView()
        }
    }
}
