import SwiftUI

struct BilanReport: Codable {
    let totalSales: Double
    let amountToReimburse: Double
    let amountReimbursed: Double
    let gamesSoldNumber: Int
    let gamesInStockNumber: Int
    let potentialSales: Int
    let commissionsEarnings: Double
    let depositEarnings: Double
    let totalBuyers: Int
    let totalSellers: Int
}
