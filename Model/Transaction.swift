import SwiftUI

struct Transaction: Identifiable, Codable {
    let id: String
    let gameId: String
    let gameName: String
    let buyerId: String
    let buyerName: String
    let sellerId: String
    let sellerName: String
    let date: String
    let price: Double
    let depositFee: Double
    let commission: Double
    let sessionId: String
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case gameId
        case gameName
        case buyerId
        case buyerName
        case sellerId
        case sellerName
        case date
        case price
        case depositFee
        case commission
        case sessionId
    }
}
