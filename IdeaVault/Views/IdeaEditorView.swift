import SwiftUI
import SwiftData

/// Create a new idea (idea == nil) or edit an existing one.
struct IdeaEditorView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var allIdeas: [Idea]

    let idea: Idea?

    @State private var title: String
    @State private var details: String
    @State private var problem: String
    @State private var nextStep: String
    @State private var category: String
    @State private var tagsText: String
    @State private var status: IdeaStatus
    @State private var priority: IdeaPriority
    @State private var isPinned: Bool

    init(idea: Idea?) {
        self.idea = idea
        _title = State(initialValue: idea?.title ?? "")
        _details = State(initialValue: idea?.details ?? "")
        _problem = State(initialValue: idea?.problem ?? "")
        _nextStep = State(initialValue: idea?.nextStep ?? "")
        _category = State(initialValue: idea?.category ?? "")
        _tagsText = State(initialValue: idea?.tags.joined(separator: ", ") ?? "")
        _status = State(initialValue: idea?.status ?? .idea)
        _priority = State(initialValue: idea?.priority ?? .none)
        _isPinned = State(initialValue: idea?.isPinned ?? false)
    }

    private var existingCategories: [String] {
        let all = Set(allIdeas.map { $0.category.trimmed }.filter { !$0.isEmpty })
        return all.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Idea") {
                    TextField("Title", text: $title, axis: .vertical)
                        .font(.headline)
                        .lineLimit(1...3)
                    TextField("Describe it", text: $details, axis: .vertical)
                        .lineLimit(3...10)
                }

                Section {
                    TextField("Who has this problem? Why does it matter?", text: $problem, axis: .vertical)
                        .lineLimit(2...8)
                } header: {
                    Text("Problem it solves")
                }

                Section {
                    TextField("e.g. Sketch the main screen", text: $nextStep, axis: .vertical)
                        .lineLimit(1...4)
                } header: {
                    Text("Next step")
                } footer: {
                    Text("One small, concrete action makes it much easier to actually start.")
                }

                Section("Progress") {
                    Picker("Status", selection: $status) {
                        ForEach(IdeaStatus.allCases) { s in
                            Label(s.title, systemImage: s.symbol).tag(s)
                        }
                    }
                    Picker("Priority", selection: $priority) {
                        ForEach(IdeaPriority.allCases) { p in
                            Text(p.title).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle("Pin to top", isOn: $isPinned)
                }

                Section {
                    HStack {
                        TextField("Category (e.g. SaaS, Mobile, AI)", text: $category)
                        if !existingCategories.isEmpty {
                            Menu {
                                ForEach(existingCategories, id: \.self) { c in
                                    Button(c) { category = c }
                                }
                            } label: {
                                Image(systemName: "chevron.down.circle")
                            }
                        }
                    }
                    TextField("Tags, separated by commas", text: $tagsText)
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("Organize")
                }
            }
            .navigationTitle(idea == nil ? "New Idea" : "Edit Idea")
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
        }
    }

    private func save() {
        let target: Idea
        if let idea {
            target = idea
        } else {
            target = Idea(title: title.trimmed)
            context.insert(target)
        }
        target.title = title.trimmed
        target.details = details.trimmed
        target.problem = problem.trimmed
        target.nextStep = nextStep.trimmed
        target.category = category.trimmed
        target.tags = parseTags(tagsText)
        target.status = status
        target.priority = priority
        target.isPinned = isPinned
        target.touch()
        try? context.save()
        dismiss()
    }
}
