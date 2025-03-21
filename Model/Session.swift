import Foundation

struct Session: Identifiable, Codable {
    let _id: String
    let id: String
    let startDate: Date
    let endDate: Date
    let endDepositGame: Date
    let commissionType: String
    let commission: Int
    let depositFeeType: String
    let depositFee: Int
    let __v: Int
    
    enum CodingKeys: String, CodingKey {
        case _id
        case id
        case startDate
        case endDate
        case endDepositGame
        case commissionType
        case commission
        case depositFeeType
        case depositFee
        case __v
    }
    
    enum FeeType: String, Codable {
        case fixed = "fixed"
        case relative = "relative"
    }
    
    // Conformité à Identifiable
    var uniqueId: String { _id }
}

extension Session {
    static var empty: Session {
        Session(
            _id: "",
            id: "",
            startDate: Date(),
            endDate: Date(),
            endDepositGame: Date(),
            commissionType: "relative",
            commission: 20,
            depositFeeType: "fixed",
            depositFee: 2,
            __v: 0
        )
    }
    
    // Structure pour l'envoi des données (sans _id et __v)
    struct CreateRequest: Codable {
        let id: String
        let startDate: Date
        let endDate: Date
        let endDepositGame: Date
        let commissionType: String
        let commission: Int
        let depositFeeType: String
        let depositFee: Int
    }
    
    var createRequest: CreateRequest {
        CreateRequest(
            id: id,
            startDate: startDate,
            endDate: endDate,
            endDepositGame: endDepositGame,
            commissionType: commissionType,
            commission: commission,
            depositFeeType: depositFeeType,
            depositFee: depositFee
        )
    }
}

extension Session: Hashable {
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
