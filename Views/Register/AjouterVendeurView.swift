import SwiftUI

struct AjouterVendeurView: View {
    @StateObject private var viewModel = AjouterVendeurViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Informations du vendeur")) {
                TextField("Prénom", text: $viewModel.firstNameInput)
                    .autocapitalization(.words)
                
                TextField("Nom", text: $viewModel.nameInput)
                    .autocapitalization(.words)
                
                TextField("Email", text: $viewModel.emailInput)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                TextField("Téléphone", text: $viewModel.phoneNumberInput)
                    .keyboardType(.phonePad)
            }
            
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            if viewModel.isSuccess {
                Text("Vendeur ajouté avec succès !")
                    .foregroundColor(.green)
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Section {
                Button(action: {
                    viewModel.submitSeller()
                }) {
                    Text("Ajouter le vendeur")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .disabled(viewModel.firstNameInput.isEmpty ||
                          viewModel.nameInput.isEmpty)
                .listRowBackground(Color.blue)
            }
        }
        .navigationTitle("Ajouter un vendeur")
    }
}

struct AjouterVendeurView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AjouterVendeurView()
        }
    }
}
