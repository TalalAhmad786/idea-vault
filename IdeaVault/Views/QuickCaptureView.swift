import SwiftUI
import SwiftData

/// The fastest possible way to get an idea out of your head.
struct QuickCaptureView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var details = ""
    @FocusState private var titleFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What's the idea?", text: $title, axis: .vertical)
                        .font(.title3.weight(.semibold))
                        .lineLimit(1...3)
                        .focused($titleFocused)
                    TextField("Quick notes (optional)", text: $details, axis: .vertical)
                        .lineLimit(3...8)
                } footer: {
                    Text("Just get it down. You can add the problem, next step and tags later.")
                }
            }
            .navigationTitle("Quick Idea")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(title.trimmed.isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let idea = Idea(title: title.trimmed, details: details.trimmed)
        context.insert(idea)
        try? context.save()
        dismiss()
    }
}
