import SwiftUI

struct BrandHeader: View {
    var isSignedIn: Bool
    var isAdmin: Bool
    var onAccountTap: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 16) {
                Image("ADGLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Developers Group")
                        .font(.title2.weight(.bold))
                        .tracking(0.4)
                    Text("MIT Manipal")
                        .font(.caption.weight(.medium))
                        .tracking(2.4)
                        .textCase(.uppercase)
                }

                Spacer()

                Button(action: onAccountTap) {
                    Image(systemName: accountIcon)
                        .font(.title2.weight(.semibold))
                        .frame(width: 38, height: 38)
                        .foregroundStyle(isSignedIn ? ADGTheme.paper : ADGTheme.ink)
                        .background(isSignedIn ? ADGTheme.ink : ADGTheme.surface)
                        .clipShape(Circle())
                }
                .accessibilityLabel(isSignedIn ? "Account signed in" : "Sign in")
            }

            Rectangle()
                .fill(ADGTheme.ink)
                .frame(height: 1)
        }
        .padding(.horizontal, ADGTheme.pagePadding)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
    }

    private var accountIcon: String {
        if isAdmin {
            "person.crop.circle.badge.checkmark"
        } else if isSignedIn {
            "person.crop.circle.fill"
        } else {
            "person.crop.circle.badge.plus"
        }
    }
}
