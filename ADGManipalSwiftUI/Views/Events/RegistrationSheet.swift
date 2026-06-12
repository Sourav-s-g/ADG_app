import SwiftUI

struct RegistrationSheet: View {
    var event: Event
    var initialEmail: String
    var onSubmit: (String, String, [String: String]) async -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email: String
    @State private var inputs: [String: String] = [:]
    @State private var isSubmitting = false

    init(
        event: Event,
        initialEmail: String,
        onSubmit: @escaping (String, String, [String: String]) async -> Void
    ) {
        self.event = event
        self.initialEmail = initialEmail
        self.onSubmit = onSubmit
        _email = State(initialValue: initialEmail)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(event.title) {
                    TextField("Student Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .disabled(!initialEmail.isEmpty)
                }

                Section("Details") {
                    if event.requiredFields.phone {
                        customField("Phone", key: "phone")
                    }
                    if event.requiredFields.registrationNumber {
                        customField("Registration Number", key: "registration_number")
                    }
                    if event.requiredFields.department {
                        customField("Department", key: "department")
                    }
                    if event.requiredFields.year {
                        customField("Year", key: "year")
                    }
                    if event.requiredFields.notes {
                        customField("Notes", key: "notes", axis: .vertical)
                    }
                }
            }
            .navigationTitle("Register")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isSubmitting ? "Submitting" : "Submit") {
                        Task {
                            isSubmitting = true
                            await onSubmit(name, email, inputs)
                            isSubmitting = false
                            dismiss()
                        }
                    }
                    .disabled(!isValid || isSubmitting)
                }
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty && !email.isEmpty
    }

    @ViewBuilder
    private func customField(_ label: String, key: String, axis: Axis = .horizontal) -> some View {
        TextField(label, text: Binding(
            get: { inputs[key] ?? "" },
            set: { inputs[key] = $0 }
        ), axis: axis)
    }
}
