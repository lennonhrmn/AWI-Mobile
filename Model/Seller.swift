import SwiftUI

struct Seller: Codable, Identifiable {
    let id: String
    let _id: String
    let firstName: String
    let name: String
    let email: String
    let phoneNumber: String
    let stocks: [String]
    let sales: [String]
    let turnover: Double
    
    var fullName: String {
        "\(firstName) \(name)"
    }
}
