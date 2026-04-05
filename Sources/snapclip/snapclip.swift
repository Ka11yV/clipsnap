import AppKit
import SwiftUI

@main
struct SnapClipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra("SnapClip", systemImage: "paperclip.circle.fill") {
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

                Button("Open Save Folder") {
                    appState.openDestinationFolder()
                }

                Divider()

                Button("Settings") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }

                Button("Quit") {
                    appState.quit()
                }
            }
            .padding(16)
            .frame(minWidth: 280)
        }
        .menuBarExtraStyle(.window)

        Settings {
            Form {
                Section("Save Folder") {
                    Text(appState.destinationFolderPath)
                        .font(.callout)
                        .textSelection(.enabled)

                    HStack {
                        Button("Choose Folder") {
                            appState.chooseDestinationFolder()
                        }

                        Button("Open Folder") {
                            appState.openDestinationFolder()
                        }
                    }
                }

                Section("Workflow") {
                    Text("Copy an image, then use the save action from the menu bar or your configured shortcut.")
                        .foregroundStyle(.secondary)

                    Text("Files will be saved into the selected folder with a timestamped name.")
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            .padding(20)
            .frame(width: 460)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
