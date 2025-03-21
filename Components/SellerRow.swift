//import SwiftUI
//
//struct SellerRow: View {
//    let seller: Seller
//    
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading) {
//                Text(seller.name)
//                    .font(.headline)
//                Text("ID: \(seller.id)")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//            Spacer()
//            VStack(alignment: .trailing) {
//                Text("\(seller.gamesCount) jeux")
//                Text(String(format: "%.2f€", seller.totalRevenue))
//                    .font(.caption)
//                    .foregroundColor(.green)
//            }
//        }
//        .padding(.vertical, 5)
//    }
//}
