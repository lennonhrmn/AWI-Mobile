import SwiftUI

struct FilterMenu: View {
    @Binding var isShowingFilters: Bool
    @Binding var maxPrice: Double
    let absoluteMaxPrice: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Filtres")
                .font(.headline)
                .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Prix maximum: \(Int(maxPrice))€")
                    .font(.subheadline)
                
                Slider(value: $maxPrice,
                       in: 0...absoluteMaxPrice,
                       step: 1)
                .accentColor(.blue)
            }
            
            Divider()
            
            Button(action: {
                isShowingFilters = false
            }) {
                Text("Appliquer")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
