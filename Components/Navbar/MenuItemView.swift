import SwiftUI

struct MenuItemView: View {
    let item: MenuItem
    @Binding var expandedMenuItem: String?
    @Binding var selectedView: String
    @Binding var isMenuOpen: Bool

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                handleMenuAction(item: item)
            }) {
                HStack {
                    Text(item.title)
                        .foregroundColor(.black)
                    Spacer()
                    if !item.subItems.isEmpty {
                        Image(systemName: expandedMenuItem == item.title ? "chevron.up" : "chevron.down")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }

            if expandedMenuItem == item.title {
                SubMenuView(subItems: item.subItems, selectedView: $selectedView, isMenuOpen: $isMenuOpen)
            }
        }
        .background(Color.white)
        .cornerRadius(10)
    }

    private func handleMenuAction(item: MenuItem) {
        if item.subItems.isEmpty {
            selectedView = item.title
            isMenuOpen = false
        } else {
            expandedMenuItem = expandedMenuItem == item.title ? nil : item.title
        }
    }
}
