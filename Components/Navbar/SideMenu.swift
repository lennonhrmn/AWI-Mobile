import SwiftUI

struct SideMenu: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedView: String
    @Binding var userRole: String
    @Binding var expandedMenuItem: String?
    @Binding var isLoggedIn: Bool
    
    private var menuItems: [MenuItem] {
        var items = [
            MenuItem(title: "Enregistrement", subItems: ["Deposer Jeu", "Acheter Jeu", "Mettre en Rayon", "Retirer des Rayons", "Retirer des Stocks", "Ajouter Vendeur"]),
            MenuItem(title: "Inventaire", subItems: []),
        ]
        if userRole == "admin" {
            items.append(MenuItem(title: "Admin", subItems: ["Transactions", "Bilan Général", "Rembourser Vendeur", "Sessions"]))
        }
        return items
    }
    
    var body: some View {
        VStack{
            
            
            VStack(spacing: 5) {
                ForEach(menuItems) { item in
                    MenuItemView(
                        item: item,
                        expandedMenuItem: $expandedMenuItem,
                        selectedView: $selectedView,
                        isMenuOpen: $isMenuOpen
                    )
                }
                
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .frame(width: UIScreen.main.bounds.width * 0.75)
            .background(Color.white.opacity(0.95))
            .cornerRadius(20)
            .shadow(radius: 5)
            .transition(.move(edge: .leading))
            
            Spacer()  // Pousse le bouton vers le bas
            HStack{
                
                Spacer(minLength: 30)
                Button(action: logout) {
                    HStack {
                        Image(systemName: "arrow.backward.square")
                            .font(.title2)
                        Text("Se déconnecter")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(1))
                    .cornerRadius(10)
                }
                .padding()
                Spacer(minLength: 30)
            }
        }
    }
    
    private func logout() {
        isLoggedIn = false
        userRole = "guest"
        withAnimation {
            isMenuOpen = false
        }
    }
}
