import Foundation
import Observation

@Observable
final class GymStore {
    var sessions: [WorkoutSession]
    var lastError: String?

    private let fileURL: URL

    init(sessions: [WorkoutSession] = [], fileURL: URL? = nil) {
        self.sessions = sessions
        self.fileURL = fileURL ?? Self.defaultURL
    }

    static var `default`: GymStore { GymStore.load() }

    static var defaultURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("Treino", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("gym.json")
    }

    static func load(url: URL = defaultURL) -> GymStore {
        let store = GymStore(fileURL: url)
        store.reload()
        return store
    }

    func reload() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            sessions = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let backup = try JSONDecoder.treino.decode(WorkoutBackup.self, from: data)
            sessions = backup.sessions
        } catch {
            lastError = "Não deu pra ler o arquivo local: \(error.localizedDescription)"
            sessions = []
        }
    }

    func save() {
        do {
            let backup = WorkoutBackup(version: 1, sessions: sessions)
            let data = try JSONEncoder.treino.encode(backup)
            try data.write(to: fileURL, options: .atomic)
            lastError = nil
        } catch {
            lastError = "Não deu pra salvar: \(error.localizedDescription)"
        }
    }

    func exportData() throws -> Data {
        let backup = WorkoutBackup(version: 1, sessions: sessions)
        return try JSONEncoder.treino.encode(backup)
    }

    func importData(_ data: Data, replaceAll: Bool) throws {
        let backup = try JSONDecoder.treino.decode(WorkoutBackup.self, from: data)
        if replaceAll {
            sessions = backup.sessions
        } else {
            var map = Dictionary(uniqueKeysWithValues: sessions.map { ($0.id, $0) })
            for incoming in backup.sessions {
                map[incoming.id] = incoming
            }
            sessions = Array(map.values)
        }
        save()
    }

    func session(date: String, programId: String) -> WorkoutSession? {
        sessions.first { $0.date == date && $0.programId == programId }
    }

    func hasLoggedSlot(date: String, programId: String, slotId: String) -> Bool {
        session(date: date, programId: programId)?.exercises.contains { $0.slotId == slotId } == true
    }

    func loggedExercise(date: String, programId: String, slotId: String, variantId: String) -> LoggedExercise? {
        session(date: date, programId: programId)?.exercises.first {
            $0.slotId == slotId && $0.variantId == variantId
        }
    }

    func lastExercise(slotId: String, variantId: String, before date: String) -> (LoggedExercise, String)? {
        let past = sessions
            .filter { $0.date < date }
            .sorted { lhs, rhs in
                if lhs.date != rhs.date { return lhs.date > rhs.date }
                return lhs.updatedAt > rhs.updatedAt
            }
        for session in past {
            if let match = session.exercises.last(where: { $0.slotId == slotId && $0.variantId == variantId }) {
                return (match, session.date)
            }
        }
        return nil
    }

    func lastVariant(slotId: String) -> String? {
        sessions
            .sorted { lhs, rhs in
                if lhs.date != rhs.date { return lhs.date > rhs.date }
                return lhs.updatedAt > rhs.updatedAt
            }
            .compactMap { session in session.exercises.last { $0.slotId == slotId }?.variantId }
            .first
    }

    func saveExercise(date: String, programId: String, slotId: String, variantId: String, sets: [LoggedSet]) {
        let now = Date()
        if let index = sessions.firstIndex(where: { $0.date == date && $0.programId == programId }) {
            var session = sessions[index]
            session.updatedAt = now
            if let exIndex = session.exercises.firstIndex(where: { $0.slotId == slotId && $0.variantId == variantId }) {
                var exercise = session.exercises.remove(at: exIndex)
                exercise.sets = sets
                session.exercises.append(exercise)
            } else {
                session.exercises.append(
                    LoggedExercise(id: UUID(), slotId: slotId, variantId: variantId, sets: sets)
                )
            }
            sessions[index] = session
        } else {
            let session = WorkoutSession(
                id: UUID(),
                date: date,
                programId: programId,
                updatedAt: now,
                exercises: [LoggedExercise(id: UUID(), slotId: slotId, variantId: variantId, sets: sets)]
            )
            sessions.append(session)
        }
        save()
    }
}

enum DayStamp {
    static func string(from date: Date = Date()) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func pretty(_ ymd: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.calendar = Calendar(identifier: .gregorian)
        inFormatter.locale = Locale(identifier: "en_US_POSIX")
        inFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = inFormatter.date(from: ymd) else { return ymd }
        let out = DateFormatter()
        out.locale = Locale(identifier: "pt_BR")
        out.dateFormat = "dd/MM"
        return out.string(from: date)
    }

    static func weekdayName(_ jsDow: Int) -> String {
        ["domingo", "segunda", "terça", "quarta", "quinta", "sexta", "sábado"][jsDow]
    }
}

private extension JSONEncoder {
    static var treino: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

private extension JSONDecoder {
    static var treino: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
