#if canImport(SwiftUI)
import SwiftUI

// ... (код ConnectionListView, который я давал выше) ...
struct ConnectionListView: View {
    @StateObject private var store = ProfileStore()
    @State private var editing: ConnectionProfile?
    @State private var activeSession: ConnectionProfile?

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.profiles) { profile in
                    Button {
                        activeSession = profile
                    } label: {
                        VStack(alignment: .leading) {
                            Text(profile.name).font(.headline)
                            Text("\(profile.protocolKind.rawValue) • \(profile.host):\(profile.port)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            store.delete(profile)
                        } label: { Label("Delete", systemImage: "trash") }

                        Button {
                            editing = profile
                        } label: { Label("Edit", systemImage: "pencil") }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("GameStream")
            .toolbar {
                Button {
                    editing = ConnectionProfile(name: "", host: "", username: "")
                } label: { Image(systemName: "plus") }
            }
            .sheet(item: $editing) { profile in
                ProfileEditorView(profile: profile) { saved in
                    store.upsert(saved)
                }
            }
        }
    }
}
#endif
