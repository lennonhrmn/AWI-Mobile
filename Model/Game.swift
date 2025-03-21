struct Game: Codable, Identifiable {
    let _id: String
    let id: String
    let name: String
    let editor: String
    let price: Double
    let sellerId: String
    let sellerName: String
    let status: String
    let depositFee: Double
    let commission: Double
    let sessionId: String
    
    var identifiable: String { _id }
}
