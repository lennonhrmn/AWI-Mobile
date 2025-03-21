import SwiftUI

struct TransactionView: View {
    @StateObject private var viewModel = TransactionViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(viewModel.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .onAppear {
                viewModel.fetchTransactions()
            }
        }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(transaction.gameName)
                    .font(.headline)
                
                Spacer()
                
                Text("\(transaction.price, specifier: "%.2f") €")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("Vendeur: \(transaction.sellerName)")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Acheteur: \(transaction.buyerName == "none" ? "" : transaction.buyerName)")
                            .font(.subheadline)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Frais: \(transaction.depositFee, specifier: "%.2f") €")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Commission: \(transaction.commission, specifier: "%.2f") €")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Date au lieu du badge
            HStack {
                Spacer()
                Text(formattedDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 5)
    }
    
    private func formattedDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            displayFormatter.timeStyle = .short
            displayFormatter.locale = Locale(identifier: "fr_FR")
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct TransactionView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionView()
    }
}
