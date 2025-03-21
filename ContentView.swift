import SwiftUI

struct ContentView: View {
    @State private var isMenuOpen = false
    @State private var selectedView = "Inventaire"
    @State private var expandedMenuItem: String? = nil  // Ajout de l'état pour gérer l'expansion des menus
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userRole") private var userRole: String = "guest"


    var body: some View {
        ZStack {
            VStack {
                Spacer().frame(height: 50)
                
                if isLoggedIn {
                    switch selectedView {
                    case "Transactions":
                        TransactionView()
                    case "Bilan Général":
                        BilanGeneralView()
                    case "Rembourser Vendeur":
                        RembourserView()
                    case "Sessions":
                        SessionView()
                    case "Deposer Jeu":
                        DeposerJeuView()
                    case "Acheter Jeu":
                        AcheterJeuView()
                    case "Mettre en Rayon":
                        MettreEnRayonView()
                    case "Retirer des Rayons":
                        RetirerRayonView()
                    case "Retirer des Stocks":
                        RetirerStockView()
                    case "Ajouter Vendeur":
                        AjouterVendeurView()
                    default:
                        InventoryView()
                    }
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, userRole: $userRole)
                }
            }
            
            if isLoggedIn {
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.black)
                                .padding()
                        }
                        Spacer()
                        Text(selectedView)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.clear)
                            .padding()
                    }
                    .background(Color.white)
                    .shadow(radius: 2)
                    Spacer()
                }
            }
            
            if isMenuOpen && isLoggedIn {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen = false
                        }
                    }
                
                SideMenu(isMenuOpen: $isMenuOpen, selectedView: $selectedView, userRole: $userRole , expandedMenuItem: $expandedMenuItem, isLoggedIn: $isLoggedIn)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Extension pour aider à la prévisualisation
#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
