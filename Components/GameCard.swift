import SwiftUI

struct GameCard: View {
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(game.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(game.editor)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Prix: \(String(format: "%.2f", game.price))€")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.blue)
                
                Spacer()
                
                Text("Status: \(game.status)")
                    .font(.caption)
                    .padding(4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(4)
            }
            
            Text("Vendeur: \(game.sellerName)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
