import AppKit
import Combine
import SwiftUI

@main
struct CodexProfileSwitcherApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var store = ProfileStore()

    var body: some Scene {
        MenuBarExtra("Codex Profiles", systemImage: store.statusSymbolName) {
            ProfileMenuView()
                .environmentObject(store)
        }

        Window("Codex Profile Manager", id: "profile-manager") {
            ProfileManagerView()
                .environmentObject(store)
                .frame(minWidth: 820, minHeight: 560)
        }
        .defaultSize(width: 920, height: 640)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let currentProcessID = ProcessInfo.processInfo.processIdentifier
        let runningCopies = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier ?? "")
            .filter { $0.processIdentifier != currentProcessID }

        if let existingApp = runningCopies.first {
            existingApp.activate(options: [])
            NSApp.terminate(nil)
        }
    }
}

struct ProfileMenuView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var store: ProfileStore

    var body: some View {
        if store.profiles.isEmpty {
            Button("Create Profile from Current Config") {
                store.createProfileFromCurrentConfig()
            }
        } else {
            ForEach(store.profiles) { profile in
                Toggle(profile.name, isOn: Binding(
                    get: {
                        store.activeProfileID == profile.id
                    },
                    set: { isSelected in
                        if isSelected {
                            store.apply(profile)
                        }
                    }
                ))
            }
        }

        Divider()

        Button("Manage Profiles...") {
            openWindow(id: "profile-manager")
            NSApp.activate()
        }

        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}

struct ProfileManagerView: View {
    @EnvironmentObject private var store: ProfileStore
    @State private var selectedProfileID: UUID?

    private var selectedProfile: CodexProfile? {
        guard let selectedProfileID else { return store.profiles.first }
        return store.profiles.first { $0.id == selectedProfileID } ?? store.profiles.first
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(store.profiles, selection: $selectedProfileID) { profile in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(profile.name)
                                .font(.headline)
                            Text(profile.updatedAt, style: .relative)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if store.activeProfileID == profile.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .tag(profile.id)
                }
                .listStyle(.sidebar)

                Divider()

                HStack {
                    Button {
                        store.createBlankProfile()
                        selectedProfileID = store.profiles.last?.id
                    } label: {
                        Image(systemName: "plus")
                    }
                    .help("Create blank profile")

                    Button {
                        store.createProfileFromCurrentConfig()
                        selectedProfileID = store.profiles.last?.id
                    } label: {
                        Image(systemName: "doc.badge.plus")
                    }
                    .help("Create profile from current ~/.codex/config.toml")

                    Button {
                        if let selectedProfile {
                            store.duplicate(selectedProfile)
                            selectedProfileID = store.profiles.last?.id
                        }
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .disabled(selectedProfile == nil)
                    .help("Duplicate selected profile")

                    Button {
                        if let selectedProfile {
                            store.delete(selectedProfile)
                            selectedProfileID = store.profiles.first?.id
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(selectedProfile == nil)
                    .help("Delete selected profile")
                }
                .buttonStyle(.borderless)
                .padding(10)
            }
            .navigationSplitViewColumnWidth(min: 230, ideal: 280)
        } detail: {
            if let selectedProfile {
                ProfileEditorView(profile: selectedProfile, selectedProfileID: $selectedProfileID)
            } else {
                ContentUnavailableView(
                    "No Profiles",
                    systemImage: "switch.2",
                    description: Text("Create a profile from the current Codex config to get started.")
                )
                .toolbar {
                    Button("Create from Current Config") {
                        store.createProfileFromCurrentConfig()
                        selectedProfileID = store.profiles.last?.id
                    }
                }
            }
        }
        .onAppear {
            selectedProfileID = selectedProfileID ?? store.activeProfileID ?? store.profiles.first?.id
        }
    }
}

struct ProfileEditorView: View {
    @EnvironmentObject private var store: ProfileStore
    let profile: CodexProfile
    @Binding var selectedProfileID: UUID?

    @State private var name = ""
    @State private var contents = ""

    private var hasChanges: Bool {
        name != profile.name || contents != profile.contents
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    TextField("Profile name", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3.weight(.semibold))

                    Button("Save") {
                        store.update(profile, name: name, contents: contents)
                        selectedProfileID = store.profiles.first { $0.name == name }?.id ?? profile.id
                    }
                    .keyboardShortcut("s", modifiers: .command)
                    .disabled(!hasChanges || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Apply & Restart") {
                        let updated = store.update(profile, name: name, contents: contents)
                        store.apply(updated)
                        selectedProfileID = updated.id
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || contents.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                HStack(spacing: 10) {
                    Label(store.path(for: profile).path(percentEncoded: false), systemImage: "doc.text")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Spacer()

                    Button("Reload from Disk") {
                        store.reload()
                        load(profileID: profile.id)
                    }

                    Button("Reveal") {
                        NSWorkspace.shared.activateFileViewerSelecting([store.path(for: profile)])
                    }
                }
            }
            .padding(18)

            Divider()

            TextEditor(text: $contents)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(12)
        }
        .onAppear {
            load(profileID: profile.id)
        }
        .onChange(of: profile.id) { _, newID in
            load(profileID: newID)
        }
    }

    private func load(profileID: UUID) {
        name = profile.name
        contents = profile.contents
    }
}

struct CodexProfile: Identifiable, Hashable {
    let id: UUID
    var name: String
    var contents: String
    var fileName: String
    var updatedAt: Date
}

@MainActor
final class ProfileStore: ObservableObject {
    @Published private(set) var profiles: [CodexProfile] = []
    @Published private(set) var activeProfileID: UUID?
    @Published private(set) var lastMessage = ""

    let codexDirectoryURL: URL
    private let configURL: URL
    private let profilesDirectoryURL: URL
    private let stateURL: URL
    private let codexBundleIdentifier = "com.openai.codex"
    private let codexAppURL = URL(filePath: "/Applications/Codex.app", directoryHint: .isDirectory)

    var statusSymbolName: String {
        activeProfileID == nil ? "person.crop.circle.badge.questionmark" : "person.crop.circle.badge.checkmark"
    }

    init() {
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        codexDirectoryURL = homeURL.appending(path: ".codex", directoryHint: .isDirectory)
        configURL = codexDirectoryURL.appending(path: "config.toml")
        profilesDirectoryURL = codexDirectoryURL
            .appending(path: "profile-switcher", directoryHint: .isDirectory)
            .appending(path: "profiles", directoryHint: .isDirectory)
        stateURL = codexDirectoryURL
            .appending(path: "profile-switcher", directoryHint: .isDirectory)
            .appending(path: "state.json")

        ensureDirectories()
        reload()
        bootstrapIfNeeded()
        detectActiveProfile()
    }

    func path(for profile: CodexProfile) -> URL {
        profilesDirectoryURL.appending(path: profile.fileName)
    }

    func reload() {
        ensureDirectories()

        let fileURLs = (try? FileManager.default.contentsOfDirectory(
            at: profilesDirectoryURL,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        profiles = fileURLs
            .filter { $0.pathExtension.lowercased() == "toml" }
            .compactMap(loadProfile)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        activeProfileID = readActiveProfileID()
        detectActiveProfile()
    }

    @discardableResult
    func update(_ profile: CodexProfile, name: String, contents: String) -> CodexProfile {
        let cleanName = uniqueName(name.trimmingCharacters(in: .whitespacesAndNewlines), excluding: profile.id)
        let fileName = safeFileName(for: cleanName)
        let oldURL = path(for: profile)
        let newURL = profilesDirectoryURL.appending(path: fileName)
        let updated = CodexProfile(id: profile.id, name: cleanName, contents: contents, fileName: fileName, updatedAt: Date())

        do {
            try write(contents, to: newURL)
            if oldURL != newURL, FileManager.default.fileExists(atPath: oldURL.path) {
                try FileManager.default.removeItem(at: oldURL)
            }
            reload()
            lastMessage = "Saved \(cleanName)"
        } catch {
            lastMessage = "Could not save profile: \(error.localizedDescription)"
        }

        return updated
    }

    func createBlankProfile() {
        let name = uniqueName("New Profile")
        let contents = """
        personality = "pragmatic"
        model = "gpt-5.5"
        model_reasoning_effort = "high"

        """
        createProfile(name: name, contents: contents)
    }

    func createProfileFromCurrentConfig() {
        do {
            let contents = try String(contentsOf: configURL, encoding: .utf8)
            createProfile(name: uniqueName("Current Config"), contents: contents)
        } catch {
            lastMessage = "Could not read current Codex config: \(error.localizedDescription)"
        }
    }

    func duplicate(_ profile: CodexProfile) {
        createProfile(name: uniqueName("\(profile.name) Copy"), contents: profile.contents)
    }

    func delete(_ profile: CodexProfile) {
        do {
            try FileManager.default.removeItem(at: path(for: profile))
            if activeProfileID == profile.id {
                activeProfileID = nil
                writeActiveProfileID(nil)
            }
            reload()
            lastMessage = "Deleted \(profile.name)"
        } catch {
            lastMessage = "Could not delete profile: \(error.localizedDescription)"
        }
    }

    func apply(_ profile: CodexProfile) {
        do {
            try ensureBackup()
            try write(profile.contents, to: configURL)
            activeProfileID = profile.id
            writeActiveProfileID(profile.id)
            lastMessage = "Applied \(profile.name). Restarting Codex..."
            restartCodex()
        } catch {
            lastMessage = "Could not apply profile: \(error.localizedDescription)"
        }
    }

    func restartCodex() {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: codexBundleIdentifier)

        if runningApps.isEmpty {
            openCodex()
            return
        }

        for app in runningApps {
            app.terminate()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }

            let stillRunning = NSRunningApplication.runningApplications(withBundleIdentifier: self.codexBundleIdentifier)
            for app in stillRunning {
                app.forceTerminate()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.openCodex()
            }
        }
    }

    private func bootstrapIfNeeded() {
        guard profiles.isEmpty, FileManager.default.fileExists(atPath: configURL.path) else { return }
        createProfileFromCurrentConfig()
    }

    private func createProfile(name: String, contents: String) {
        let cleanName = uniqueName(name)
        let fileName = safeFileName(for: cleanName)
        let profileURL = profilesDirectoryURL.appending(path: fileName)

        do {
            try write(contents, to: profileURL)
            reload()
            lastMessage = "Created \(cleanName)"
        } catch {
            lastMessage = "Could not create profile: \(error.localizedDescription)"
        }
    }

    private func loadProfile(from url: URL) -> CodexProfile? {
        guard let contents = try? String(contentsOf: url, encoding: .utf8) else { return nil }

        let values = try? url.resourceValues(forKeys: [.contentModificationDateKey])
        let fileName = url.lastPathComponent
        let name = url.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "-", with: " ")

        return CodexProfile(
            id: UUID(uuidString: stableIDSeed(for: fileName)) ?? UUID(),
            name: name,
            contents: contents,
            fileName: fileName,
            updatedAt: values?.contentModificationDate ?? Date.distantPast
        )
    }

    private func detectActiveProfile() {
        guard let currentConfig = try? String(contentsOf: configURL, encoding: .utf8) else {
            activeProfileID = readActiveProfileID()
            return
        }

        if let matchingProfile = profiles.first(where: { $0.contents == currentConfig }) {
            activeProfileID = matchingProfile.id
            writeActiveProfileID(matchingProfile.id)
        } else {
            activeProfileID = nil
            writeActiveProfileID(nil)
        }
    }

    private func openCodex() {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true

        NSWorkspace.shared.openApplication(at: codexAppURL, configuration: configuration) { [weak self] _, error in
            DispatchQueue.main.async {
                if let error {
                    self?.lastMessage = "Could not open Codex: \(error.localizedDescription)"
                } else {
                    self?.lastMessage = "Codex restarted"
                }
            }
        }
    }

    private func ensureDirectories() {
        try? FileManager.default.createDirectory(
            at: profilesDirectoryURL,
            withIntermediateDirectories: true
        )
    }

    private func ensureBackup() throws {
        guard FileManager.default.fileExists(atPath: configURL.path) else { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let backupURL = codexDirectoryURL.appending(path: "config.toml.profile-switcher-backup-\(formatter.string(from: Date()))")
        try FileManager.default.copyItem(at: configURL, to: backupURL)
    }

    private func write(_ contents: String, to url: URL) throws {
        let temporaryURL = url.deletingLastPathComponent().appending(path: ".\(url.lastPathComponent).tmp")
        try contents.write(to: temporaryURL, atomically: true, encoding: .utf8)

        if FileManager.default.fileExists(atPath: url.path) {
            _ = try FileManager.default.replaceItemAt(url, withItemAt: temporaryURL)
        } else {
            try FileManager.default.moveItem(at: temporaryURL, to: url)
        }
    }

    private func uniqueName(_ baseName: String, excluding excludedID: UUID? = nil) -> String {
        let fallbackName = baseName.isEmpty ? "Profile" : baseName
        let existingNames = Set(profiles.filter { $0.id != excludedID }.map(\.name))

        if !existingNames.contains(fallbackName) {
            return fallbackName
        }

        var index = 2
        while existingNames.contains("\(fallbackName) \(index)") {
            index += 1
        }

        return "\(fallbackName) \(index)"
    }

    private func safeFileName(for name: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_ "))
        let cleanedScalars = name.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let baseName = String(cleanedScalars)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "-")

        return "\(baseName.isEmpty ? "profile" : baseName).toml"
    }

    private func stableIDSeed(for value: String) -> String {
        let bytes = Array(value.utf8)
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in bytes {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }

        return String(format: "00000000-0000-4000-8000-%012llx", hash & 0xffffffffffff)
    }

    private func readActiveProfileID() -> UUID? {
        guard
            let data = try? Data(contentsOf: stateURL),
            let state = try? JSONDecoder().decode(ProfileSwitcherState.self, from: data)
        else {
            return nil
        }

        return state.activeProfileID
    }

    private func writeActiveProfileID(_ id: UUID?) {
        let state = ProfileSwitcherState(activeProfileID: id)

        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: stateURL, options: [.atomic])
        } catch {
            lastMessage = "Could not persist active profile: \(error.localizedDescription)"
        }
    }
}

struct ProfileSwitcherState: Codable {
    var activeProfileID: UUID?
}

#Preview {
    ProfileManagerView()
        .environmentObject(ProfileStore())
}
