import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var ideas: [Idea]

    @State private var exportDocument: BackupDocument?
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var alertMessage: String?

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    private var backupFilename: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "ideas-backup-\(f.string(from: Date()))"
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Your ideas") {
                    LabeledContent("Total", value: "\(ideas.count)")
                    ForEach(IdeaStatus.allCases) { status in
                        LabeledContent {
                            Text("\(ideas.filter { $0.status == status }.count)")
                        } label: {
                            Label(status.title, systemImage: status.symbol)
                        }
                    }
                }

                Section {
                    Button {
                        startExport()
                    } label: {
                        Label("Export Backup", systemImage: "square.and.arrow.up")
                    }
                    .disabled(ideas.isEmpty)

                    Button {
                        showImporter = true
                    } label: {
                        Label("Import Backup", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Backup")
                } footer: {
                    Text("Export saves all your ideas as a JSON file to Files or iCloud Drive. Do it every so often so your ideas are safe even if the app gets deleted. Importing merges by idea, so you won't get duplicates.")
                }
                .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
                    handleImport(result)
                }

                Section {
                    Label("Refresh this app in SideStore / AltStore at least every 7 days. Your ideas stay on the phone either way.", systemImage: "arrow.clockwise.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Reminder")
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .fileExporter(
                isPresented: $showExporter,
                document: exportDocument,
                contentType: .json,
                defaultFilename: backupFilename
            ) { result in
                switch result {
                case .success:
                    alertMessage = "Backup saved."
                case .failure(let error):
                    alertMessage = "Export failed: \(error.localizedDescription)"
                }
            }
            .alert(
                "Backup",
                isPresented: Binding(
                    get: { alertMessage != nil },
                    set: { if !$0 { alertMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func startExport() {
        do {
            exportDocument = BackupDocument(data: try Backup.encode(ideas))
            showExporter = true
        } catch {
            alertMessage = "Couldn't create backup: \(error.localizedDescription)"
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            alertMessage = "Import failed: \(error.localizedDescription)"
        case .success(let url):
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            do {
                let data = try Data(contentsOf: url)
                let outcome = try Backup.merge(data, into: context, existing: ideas)
                alertMessage = "Imported \(outcome.added) new and updated \(outcome.updated) existing ideas."
            } catch {
                alertMessage = "That file doesn't look like an Ideas backup.\n\(error.localizedDescription)"
            }
        }
    }
}
