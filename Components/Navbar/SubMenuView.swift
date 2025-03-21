import SwiftUI

struct SubMenuView: View {
    let subItems: [String]
    @Binding var selectedView: String
    @Binding var isMenuOpen: Bool

    var body: some View {
        VStack(spacing: 2) {
            ForEach(subItems, id: \.self) { subItem in
                Button(action: {
                    selectedView = subItem
                    isMenuOpen = false
                }) {
                    Text(subItem)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.black)
                }
            }
        }
        .transition(.opacity)
        .background(Color.white)
        .cornerRadius(10)
    }
}
