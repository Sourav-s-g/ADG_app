//
//  UpdatePasswordView.swift
//  ADG
//
//  Created by Sourav S Gaikwad on 22/06/26.
//

import SwiftUI
import Supabase

struct UpdatePasswordView: View {
    @Binding var isPresented: Bool
    @State private var newPassword = ""
    @State private var errorMessage = ""
    @State private var isSaving = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Enter your new secure password")) {
                    SecureField("New Password", text: $newPassword)
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    Task {
                        await savePassword()
                    }
                }) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Update Password")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(newPassword.isEmpty || isSaving)
            }
            .navigationTitle("Reset Password")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
    
    private func savePassword() async {
        isSaving = true
        errorMessage = ""
        do {
            // Provide the 'user' label it's looking for
            try await SupabaseProvider.shared.auth.update(
                user: UserAttributes(password: newPassword)
            )
            print("Password updated successfully!")
            isPresented = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }
}
