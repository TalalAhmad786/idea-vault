import SwiftUI
import SwiftData

struct IdeaDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let idea: Idea

    @State private var showEditor = false
    @State private var confirmDelete = false

    private var statusBinding: Binding<IdeaStatus> {
        Binding(
            get: { idea.status },
            set: { newValue in
                idea.status = newValue
                idea.touch()
                try? context.save()
            }
        )
    }

    private var priorityBinding: Binding<IdeaPriority> {
        Binding(
            get: { idea.priority },
            set: { newValue in
                idea.priority = newValue
                idea.touch()
                try? context.save()
            }
        )
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(idea.displayTitle)
                        .font(.title2.bold())
                    HStack(spacing: 8) {
                        StatusPill(status: idea.status)
                        PriorityBadge(priority: idea.priority)
                        if idea.isPinned {
                            Image(systemName: "pin.fill")
                                .font(.caption)
                                .foregroundStyle(Color.orange)
                        }
                        Spacer()
                    }
                    if !idea.details.isEmpty {
                        Text(idea.details)
                            .font(.body)
                            .textSelection(.enabled)
                    }
                }
                .padding(.vertical, 6)
            }

            if !idea.problem.isEmpty {
                Section("Problem it solves") {
                    Text(idea.problem)
                        .textSelection(.enabled)
                }
            }

            Section("Next step") {
                if idea.nextStep.isEmpty {
                    Button {
                        showEditor = true
                    } label: {
                        Label("Add a next step", systemImage: "plus.circle")
                    }
                } else {
                    Label(idea.nextStep, systemImage: "arrow.right.circle.fill")
                }
            }

            Section("Progress") {
                Picker(selection: statusBinding) {
                    ForEach(IdeaStatus.allCases) { s in
                        Label(s.title, systemImage: s.symbol).tag(s)
                    }
                } label: {
                    Text("Status")
                }
                Picker("Priority", selection: priorityBinding) {
                    ForEach(IdeaPriority.allCases) { p in
                        Text(p.title).tag(p)
                    }
                }
                .pickerStyle(.segmented)
            }

            if !idea.category.isEmpty || !idea.tags.isEmpty {
                Section("Organize") {
                    if !idea.category.isEmpty {
                        LabeledContent("Category", value: idea.category)
                    }
                    if !idea.tags.isEmpty {
                        Text(idea.tags.map { "#" + $0 }.joined(separator: "  "))
                            .foregroundStyle(Color.orange)
                    }
                }
            }

            Section {
                LabeledContent("Created", value: idea.createdAt.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Updated", value: idea.updatedAt.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.footnote)

            Section {
                Button(role: .destructive) {
                    confirmDelete = true
                } label: {
                    Label("Delete Idea", systemImage: "trash")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    idea.isPinned.toggle()
                    try? context.save()
                } label: {
                    Image(systemName: idea.isPinned ? "pin.slash" : "pin")
                }
                .accessibilityLabel(idea.isPinned ? "Unpin" : "Pin")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditor = true }
            }
        }
        .sheet(isPresented: $showEditor) {
            IdeaEditorView(idea: idea)
        }
        .confirmationDialog("Delete this idea?", isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) { deleteIdea() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This can't be undone.")
        }
    }

    private func deleteIdea() {
        let target = idea
        let ctx = context
        dismiss()
        // Delete after the pop animation so this screen never renders a deleted object.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            ctx.delete(target)
            try? ctx.save()
        }
    }
}
