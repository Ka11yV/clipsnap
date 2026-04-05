import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            Section("Save Folder") {
                Text(appState.destinationFolderPath)
                    .font(.callout)
                    .textSelection(.enabled)

                Text(appState.destinationFolderDescription)
                    .foregroundStyle(.secondary)

                HStack {
                    Button("Choose Folder") {
                        appState.chooseDestinationFolder()
                    }

                    Button("Open Folder") {
                        appState.openDestinationFolder()
                    }
                    .disabled(!appState.hasDestinationFolderAccess)
                }
            }

            Section("Workflow") {
                Text("Copy an image, then use the save action from the menu bar or your configured shortcut.")
                    .foregroundStyle(.secondary)

                Text("Files will be saved into the selected folder with a timestamped name.")
                    .foregroundStyle(.secondary)

                Text("Sandboxed builds require you to approve the save folder once so the app can keep secure access.")
                    .foregroundStyle(.secondary)
            }

            Section("Shortcut") {
                KeyboardShortcuts.Recorder("Save Clipboard Image", name: .saveClipboardImage)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 460)
    }
}
