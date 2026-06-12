import SwiftUI

struct RosterView: View {
    var event: Event?
    var registrations: [Registration]

    var body: some View {
        NavigationStack {
            List(registrations) { registration in
                VStack(alignment: .leading, spacing: 6) {
                    Text(registration.studentName)
                        .font(.headline)
                    Text(registration.email)
                        .font(.subheadline)

                    ForEach(registration.customInputs.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        HStack {
                            Text(key.replacingOccurrences(of: "_", with: " ").capitalized)
                            Spacer()
                            Text(value)
                                .fontWeight(.semibold)
                        }
                        .font(.caption)
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle(event?.title ?? "Roster")
        }
    }
}
