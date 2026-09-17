import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(GymStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var exportItem: JSONFile?
    @State private var importing = false
    @State private var message: String?

    var body: some View {
        NavigationStack {
            List {
                Section("Backup") {
                    Button("Exportar JSON") {
                        do {
                            exportItem = JSONFile(data: try store.exportData())
                        } catch {
                            message = error.localizedDescription
                        }
                    }
                    Button("Importar JSON") {
                        importing = true
                    }
                    Text("Os pesos ficam neste iPhone. Exporta um arquivo se for apagar o app. Importar junta as sessões; não apaga as que já estão aqui.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                if let error = store.lastError {
                    Section("Status") {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
                if let message {
                    Section {
                        Text(message)
                    }
                }
                Section("Vídeos") {
                    Text("A execução abre a página do MuscleWiki dentro do app. Precisa de internet. Os mp4 deles não são baixados.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Dados")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                }
            }
            .fileExporter(
                isPresented: Binding(
                    get: { exportItem != nil },
                    set: { if !$0 { exportItem = nil } }
                ),
                document: exportItem,
                contentType: .json,
                defaultFilename: "treino-\(DayStamp.string())"
            ) { result in
                if case .failure(let error) = result {
                    message = error.localizedDescription
                } else {
                    message = "Exportado."
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    do {
                        guard url.startAccessingSecurityScopedResource() else {
                            message = "Sem permissão pra ler o arquivo."
                            return
                        }
                        defer { url.stopAccessingSecurityScopedResource() }
                        let data = try Data(contentsOf: url)
                        try store.importData(data, replaceAll: false)
                        message = "Importado."
                    } catch {
                        message = error.localizedDescription
                    }
                case .failure(let error):
                    message = error.localizedDescription
                }
            }
        }
    }
}

struct JSONFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
