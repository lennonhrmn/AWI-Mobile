import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subItems: [String]
}
