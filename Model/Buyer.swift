import SwiftUI

struct Buyer: Codable, Identifiable {
    var id: String?
    var firstName: String
    var name: String
    var email: String
    var phoneNumber: String
    var address: String
    
    var fullName: String {
            return "\(firstName) \(name)"
        }
}
