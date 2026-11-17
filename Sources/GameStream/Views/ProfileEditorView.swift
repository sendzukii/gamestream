#if canImport(SwiftUI)
import SwiftUI

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State var profile: ConnectionProfile
    var onSave: (ConnectionProfile) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Profile Name", text: $profile.name)
                }
                Section("Server") {
                    Picker("Protocol", selection: $profile.protocolKind) {
                        ForEach(ConnectionProfile.ProtocolKind.allCases) { kind in
                            Text(kind.rawValue).tag(kind)
                        }
                    }
                    TextField("Host", text: $profile.host)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Port", value: $profile.port, format: .number)
                        .keyboardType(.numberPad)
                }
                Section("Authentication") {
                    TextField("Username", text: $profile.username)
                        .textInputAutocapitalization(.never)
                    TextField("Domain", text: $profile.domain)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $profile.password)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(profile)
                        dismiss()
                    }
                    .disabled(profile.host.isEmpty || profile.name.isEmpty)
                }
            }
        }
    }
}
#endif
