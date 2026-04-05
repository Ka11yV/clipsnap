import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SnapClip")
                    .font(.headline)

                Text(appState.statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("Save Clipboard Image") {
                appState.saveClipboardImage()
            }
            .disabled(!appState.hasDestinationFolderAccess)

            Button("Open Save Folder") {
                appState.openDestinationFolder()
            }
            .disabled(!appState.hasDestinationFolderAccess)

            if appState.canRevealLastSavedFile {
                Button("Reveal Last Saved File") {
                    appState.revealLastSavedFile()
                }
            }

            if !appState.hasDestinationFolderAccess {
                Text("Choose a save folder in Settings before using SnapClip.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            Button {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            } label: {
                Label("Settings", systemImage: "gearshape")
            }

            Button("Quit") {
                appState.quit()
            }
        }
        .padding(16)
        .frame(minWidth: 280)
    }
}
