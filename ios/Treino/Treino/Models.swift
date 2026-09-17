import Foundation

struct WorkoutBackup: Codable {
    var version: Int
    var sessions: [WorkoutSession]
}

struct WorkoutSession: Codable, Identifiable, Hashable {
    var id: UUID
    var date: String
    var programId: String
    var updatedAt: Date
    var exercises: [LoggedExercise]
}

struct LoggedExercise: Codable, Identifiable, Hashable {
    var id: UUID
    var slotId: String
    var variantId: String
    var sets: [LoggedSet]
}

struct LoggedSet: Codable, Hashable {
    var kg: Double
    var reps: Int
}

enum PlanKind {
    case gym(programId: String)
    case info
}

struct DayPlan: Identifiable {
    /// JavaScript-style weekday: 0 Sunday … 6 Saturday.
    var id: Int
    var shortName: String
    var title: String
    var subtitle: String
    var body: String
    var kind: PlanKind
    var accent: Accent

    var gymProgramId: String? {
        if case .gym(let id) = kind { return id }
        return nil
    }
}

struct ExerciseOption: Identifiable, Hashable {
    var id: String
    var name: String
    var kind: String
    var muscleWikiURL: URL
}

struct ExerciseSlot: Identifiable, Hashable {
    var id: String
    var prescription: String
    var setCount: Int
    var isWarmup: Bool
    var note: String?
    var main: ExerciseOption
    var variants: [ExerciseOption]

    var options: [ExerciseOption] { [main] + variants }
}

struct GymProgram: Identifiable {
    var id: String
    var name: String
    var tag: String
    var summary: String
    var note: String?
    var accent: Accent
    var slots: [ExerciseSlot]
}

enum Catalog {
    static func mw(_ slug: String) -> URL {
        URL(string: "https://musclewiki.com/pt-br/exercise/\(slug)")!
    }

    static let programs: [GymProgram] = [pull, legs, push]

    static func program(_ id: String) -> GymProgram {
        programs.first { $0.id == id } ?? pull
    }

    static let week: [DayPlan] = [
        DayPlan(
            id: 1, shortName: "Seg", title: "Vôlei",
            subtitle: "21:00 · areia",
            body: "Sem academia, sem corrida. Depois do longão de domingo.",
            kind: .info, accent: .volei
        ),
        DayPlan(
            id: 2, shortName: "Ter", title: "Pull",
            subtitle: "12:00 · academia",
            body: "Costas + bíceps. Fallback 8h se a daily comer o meio-dia.",
            kind: .gym(programId: "pull"), accent: .pull
        ),
        DayPlan(
            id: 3, shortName: "Qua", title: "Corrida fácil",
            subtitle: "~8:00 · Runna",
            body: "Só o encaixe. Volume e ritmo ficam no Runna. Sem academia nesse dia — mas você pode abrir o Pull, Pernas ou Push se quiser treinar.",
            kind: .info, accent: .run
        ),
        DayPlan(
            id: 4, shortName: "Qui", title: "Vôlei",
            subtitle: "20:00 · areia",
            body: "Sem academia. Quarta foi só corrida.",
            kind: .info, accent: .volei
        ),
        DayPlan(
            id: 5, shortName: "Sex", title: "Pernas",
            subtitle: "12:00 · academia",
            body: "Sai andando, não mancando. Sem panturrilha pesada — domingo tem longão.",
            kind: .info, accent: .legs
        ).withGym("legs"),
        DayPlan(
            id: 6, shortName: "Sáb", title: "Push · peito",
            subtitle: "8:00–9:30",
            body: "Melhor dia de peito: longe do vôlei. Inclinação primeiro.",
            kind: .gym(programId: "push"), accent: .push
        ),
        DayPlan(
            id: 0, shortName: "Dom", title: "Corrida longa",
            subtitle: "Runna · qualidade",
            body: "Dia livre, sem academia. Não correr sábado nem segunda.",
            kind: .info, accent: .run
        ),
    ]

    static func day(_ jsDow: Int) -> DayPlan {
        week.first { $0.id == jsDow } ?? week[0]
    }

    static var orderedWeek: [DayPlan] {
        [1, 2, 3, 4, 5, 6, 0].compactMap { id in week.first { $0.id == id } }
    }

    static func jsWeekday(from date: Date = Date()) -> Int {
        Calendar.current.component(.weekday, from: date) - 1
    }
}

private extension DayPlan {
    func withGym(_ programId: String) -> DayPlan {
        var copy = self
        copy.kind = .gym(programId: programId)
        copy.accent = programId == "legs" ? .legs : copy.accent
        return copy
    }
}

extension Catalog {
    static let pull = GymProgram(
        id: "pull",
        name: "Pull",
        tag: "Terça · 12h",
        summary: "Costas + bíceps. 3×8–12, parar 1–2 reps antes da falha.",
        note: "Ombro: rotação externa no aquecimento, lado direito em cima, amplitude sem dor.",
        accent: .pull,
        slots: [
            ExerciseSlot(
                id: "pull-warmup",
                prescription: "3×12–15",
                setCount: 3,
                isWarmup: true,
                note: "1–2 kg. Lado direito em cima.",
                main: ExerciseOption(id: "pull-warmup-main", name: "Rotação externa deitado", kind: "livre", muscleWikiURL: mw("dumbbell-external-rotation")),
                variants: []
            ),
            ExerciseSlot(
                id: "pull-pulldown",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "pull-pulldown-main", name: "Puxada frente barra longa", kind: "máquina", muscleWikiURL: mw("machine-pulldown")),
                variants: [
                    ExerciseOption(id: "pull-pulldown-v1", name: "Puxada na máquina", kind: "máquina", muscleWikiURL: mw("machine-plate-loaded-pulldown")),
                    ExerciseOption(id: "pull-pulldown-v2", name: "Barra fixa", kind: "corpo", muscleWikiURL: mw("pull-ups")),
                    ExerciseOption(id: "pull-pulldown-v3", name: "Pullover com halter", kind: "livre", muscleWikiURL: mw("dumbbell-pullover")),
                ]
            ),
            ExerciseSlot(
                id: "pull-row",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "pull-row-main", name: "Remada máquina peito apoiado", kind: "máquina", muscleWikiURL: mw("machine-chest-supported-t-bar-row")),
                variants: [
                    ExerciseOption(id: "pull-row-v1", name: "Remada polia baixa", kind: "cabo", muscleWikiURL: mw("machine-seated-cable-row")),
                    ExerciseOption(id: "pull-row-v2", name: "Remada cavalinho", kind: "livre", muscleWikiURL: mw("dumbbell-row-unilateral")),
                    ExerciseOption(id: "pull-row-v3", name: "Remada curvada com barra", kind: "livre", muscleWikiURL: mw("barbell-pronated-row")),
                ]
            ),
            ExerciseSlot(
                id: "pull-neutral",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "pull-neutral-main", name: "Puxada triângulo", kind: "máquina", muscleWikiURL: mw("neutral-pulldown")),
                variants: [
                    ExerciseOption(id: "pull-neutral-v1", name: "Puxada frente", kind: "máquina", muscleWikiURL: mw("machine-pulldown")),
                    ExerciseOption(id: "pull-neutral-v2", name: "Barra fixa", kind: "corpo", muscleWikiURL: mw("pull-ups")),
                    ExerciseOption(id: "pull-neutral-v3", name: "Pullover com halter", kind: "livre", muscleWikiURL: mw("dumbbell-pullover")),
                ]
            ),
            ExerciseSlot(
                id: "pull-face",
                prescription: "3×12–15",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "pull-face-main", name: "Face pull", kind: "cabo", muscleWikiURL: mw("machine-face-pulls")),
                variants: [
                    ExerciseOption(id: "pull-face-v1", name: "Peck-deck inverso", kind: "máquina", muscleWikiURL: mw("machine-reverse-fly")),
                    ExerciseOption(id: "pull-face-v2", name: "Crucifixo inverso halteres", kind: "livre", muscleWikiURL: mw("dumbbell-rear-delt-fly")),
                    ExerciseOption(id: "pull-face-v3", name: "Crucifixo inverso no cabo", kind: "cabo", muscleWikiURL: mw("cable-high-single-arm-rear-delt-fly")),
                ]
            ),
            ExerciseSlot(
                id: "pull-curl",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "pull-curl-main", name: "Rosca direta halteres", kind: "livre", muscleWikiURL: mw("dumbbell-curl")),
                variants: [
                    ExerciseOption(id: "pull-curl-v1", name: "Rosca na polia", kind: "cabo", muscleWikiURL: mw("cable-bar-curl")),
                    ExerciseOption(id: "pull-curl-v2", name: "Rosca com barra", kind: "livre", muscleWikiURL: mw("barbell-curl")),
                    ExerciseOption(id: "pull-curl-v3", name: "Rosca martelo", kind: "livre", muscleWikiURL: mw("dumbbell-hammer-curl")),
                ]
            ),
            ExerciseSlot(
                id: "pull-hammer",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "pull-hammer-main", name: "Rosca martelo", kind: "livre", muscleWikiURL: mw("dumbbell-hammer-curl")),
                variants: [
                    ExerciseOption(id: "pull-hammer-v1", name: "Rosca direta", kind: "livre", muscleWikiURL: mw("dumbbell-curl")),
                    ExerciseOption(id: "pull-hammer-v2", name: "Rosca na polia", kind: "cabo", muscleWikiURL: mw("cable-bar-curl")),
                    ExerciseOption(id: "pull-hammer-v3", name: "Rosca com barra", kind: "livre", muscleWikiURL: mw("barbell-curl")),
                ]
            ),
        ]
    )

    static let legs = GymProgram(
        id: "legs",
        name: "Pernas",
        tag: "Sexta · 12h",
        summary: "Sai andando, não mancando. Sem panturrilha pesada.",
        note: "Uma sessão de força. Já tem 2 vôlei + 2 corrida.",
        accent: .legs,
        slots: [
            ExerciseSlot(
                id: "legs-press",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "legs-press-main", name: "Leg press 45°", kind: "máquina", muscleWikiURL: mw("machine-leg-press")),
                variants: [
                    ExerciseOption(id: "legs-press-v1", name: "Hack squat", kind: "máquina", muscleWikiURL: mw("machine-hack-squat")),
                    ExerciseOption(id: "legs-press-v2", name: "Agachamento goblet", kind: "livre", muscleWikiURL: mw("dumbbell-goblet-squat")),
                    ExerciseOption(id: "legs-press-v3", name: "Agachamento com barra", kind: "livre", muscleWikiURL: mw("barbell-squat")),
                ]
            ),
            ExerciseSlot(
                id: "legs-rdl",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "legs-rdl-main", name: "Stiff / RDL com halteres", kind: "livre", muscleWikiURL: mw("dumbbell-romanian-deadlift")),
                variants: [
                    ExerciseOption(id: "legs-rdl-v1", name: "Stiff com barra", kind: "livre", muscleWikiURL: mw("barbell-stiff-leg-deadlifts")),
                    ExerciseOption(id: "legs-rdl-v2", name: "Mesa flexora", kind: "máquina", muscleWikiURL: mw("machine-hamstring-curl")),
                    ExerciseOption(id: "legs-rdl-v3", name: "Cadeira flexora", kind: "máquina", muscleWikiURL: mw("machine-seated-leg-curl")),
                ]
            ),
            ExerciseSlot(
                id: "legs-ext",
                prescription: "3×10–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "legs-ext-main", name: "Cadeira extensora", kind: "máquina", muscleWikiURL: mw("machine-leg-extension")),
                variants: [
                    ExerciseOption(id: "legs-ext-v1", name: "Avanço / lunge", kind: "livre", muscleWikiURL: mw("dumbbell-goblet-reverse-lunge")),
                    ExerciseOption(id: "legs-ext-v2", name: "Agachamento búlgaro", kind: "livre", muscleWikiURL: mw("barbell-bulgarian-split-squat")),
                    ExerciseOption(id: "legs-ext-v3", name: "Hack squat", kind: "máquina", muscleWikiURL: mw("machine-hack-squat")),
                ]
            ),
            ExerciseSlot(
                id: "legs-curl",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "legs-curl-main", name: "Mesa flexora", kind: "máquina", muscleWikiURL: mw("machine-hamstring-curl")),
                variants: [
                    ExerciseOption(id: "legs-curl-v1", name: "Cadeira flexora", kind: "máquina", muscleWikiURL: mw("machine-seated-leg-curl")),
                    ExerciseOption(id: "legs-curl-v2", name: "Avanço / lunge", kind: "livre", muscleWikiURL: mw("dumbbell-goblet-reverse-lunge")),
                    ExerciseOption(id: "legs-curl-v3", name: "Agachamento búlgaro", kind: "livre", muscleWikiURL: mw("barbell-bulgarian-split-squat")),
                ]
            ),
            ExerciseSlot(
                id: "legs-glute",
                prescription: "3×10–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "legs-glute-main", name: "Elevação pélvica", kind: "livre", muscleWikiURL: mw("dumbbell-glute-bridge")),
                variants: [
                    ExerciseOption(id: "legs-glute-v1", name: "Hip thrust com barra", kind: "livre", muscleWikiURL: mw("barbell-hip-thrust")),
                    ExerciseOption(id: "legs-glute-v2", name: "Hip thrust com halter", kind: "livre", muscleWikiURL: mw("dumbbell-hip-thrust")),
                    ExerciseOption(id: "legs-glute-v3", name: "Agachamento goblet", kind: "livre", muscleWikiURL: mw("dumbbell-goblet-squat")),
                ]
            ),
        ]
    )

    static let push = GymProgram(
        id: "push",
        name: "Push · peito",
        tag: "Sábado · 8h",
        summary: "Inclinação primeiro. Sem push pesado no dia do vôlei nem no dia seguinte.",
        note: "Ombro: mesma rotação externa 3×12–15 no aquecimento. Se puxar, encurta amplitude e segue.",
        accent: .push,
        slots: [
            ExerciseSlot(
                id: "push-warmup",
                prescription: "3×12–15",
                setCount: 3,
                isWarmup: true,
                note: "1–2 kg. Lado direito em cima.",
                main: ExerciseOption(id: "push-warmup-main", name: "Rotação externa deitado", kind: "livre", muscleWikiURL: mw("dumbbell-external-rotation")),
                variants: []
            ),
            ExerciseSlot(
                id: "push-incline",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "push-incline-main", name: "Supino inclinado halteres", kind: "livre", muscleWikiURL: mw("dumbbell-incline-bench-press")),
                variants: [
                    ExerciseOption(id: "push-incline-v1", name: "Supino inclinado com barra", kind: "livre", muscleWikiURL: mw("barbell-high-incline-bench-press")),
                    ExerciseOption(id: "push-incline-v2", name: "Crossover baixo → cima", kind: "cabo", muscleWikiURL: mw("cable-standing-single-arm-incline-chest-fly")),
                    ExerciseOption(id: "push-incline-v3", name: "Flexão de braço", kind: "corpo", muscleWikiURL: mw("push-ups")),
                ]
            ),
            ExerciseSlot(
                id: "push-pec",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "push-pec-main", name: "Peck-deck", kind: "máquina", muscleWikiURL: mw("machine-pec-fly")),
                variants: [
                    ExerciseOption(id: "push-pec-v1", name: "Supino reto com halteres", kind: "livre", muscleWikiURL: mw("dumbbell-bench-press")),
                    ExerciseOption(id: "push-pec-v2", name: "Crucifixo com halteres", kind: "livre", muscleWikiURL: mw("dumbbell-chest-fly")),
                    ExerciseOption(id: "push-pec-v3", name: "Crossover", kind: "cabo", muscleWikiURL: mw("cable-standing-single-arm-incline-chest-fly")),
                ]
            ),
            ExerciseSlot(
                id: "push-ohp",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "push-ohp-main", name: "Desenvolvimento halteres", kind: "livre", muscleWikiURL: mw("dumbbell-seated-overhead-press")),
                variants: [
                    ExerciseOption(id: "push-ohp-v1", name: "Desenvolvimento na máquina", kind: "máquina", muscleWikiURL: mw("machine-neutral-overhead-press")),
                    ExerciseOption(id: "push-ohp-v2", name: "Desenvolvimento militar", kind: "livre", muscleWikiURL: mw("barbell-overhead-press")),
                    ExerciseOption(id: "push-ohp-v3", name: "Landmine press", kind: "livre", muscleWikiURL: mw("landmine-overhead-press")),
                ]
            ),
            ExerciseSlot(
                id: "push-lateral",
                prescription: "3×10–15",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "push-lateral-main", name: "Elevação lateral", kind: "livre", muscleWikiURL: mw("seated-lateral-raise")),
                variants: [
                    ExerciseOption(id: "push-lateral-v1", name: "Elevação lateral na polia", kind: "cabo", muscleWikiURL: mw("cable-low-bilateral-lateral-raise")),
                    ExerciseOption(id: "push-lateral-v2", name: "Elevação lateral na máquina", kind: "máquina", muscleWikiURL: mw("machine-standing-lateral-raise")),
                    ExerciseOption(id: "push-lateral-v3", name: "Elevação lateral em pé", kind: "livre", muscleWikiURL: mw("dumbbell-lateral-raise")),
                ]
            ),
            ExerciseSlot(
                id: "push-skull",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "push-skull-main", name: "Tríceps testa ou barra W", kind: "livre", muscleWikiURL: mw("barbell-skullcrusher")),
                variants: [
                    ExerciseOption(id: "push-skull-v1", name: "Tríceps francês no cabo", kind: "cabo", muscleWikiURL: mw("cable-rope-skullcrusher")),
                    ExerciseOption(id: "push-skull-v2", name: "Tríceps coice", kind: "livre", muscleWikiURL: mw("dumbbell-tricep-kickback")),
                    ExerciseOption(id: "push-skull-v3", name: "Flexão de braço", kind: "corpo", muscleWikiURL: mw("push-ups")),
                ]
            ),
            ExerciseSlot(
                id: "push-pushdown",
                prescription: "3×8–12",
                setCount: 3,
                isWarmup: false,
                note: nil,
                main: ExerciseOption(id: "push-pushdown-main", name: "Tríceps corda", kind: "cabo", muscleWikiURL: mw("cable-rope-pushdown")),
                variants: [
                    ExerciseOption(id: "push-pushdown-v1", name: "Tríceps testa / barra W", kind: "livre", muscleWikiURL: mw("barbell-skullcrusher")),
                    ExerciseOption(id: "push-pushdown-v2", name: "Tríceps coice", kind: "livre", muscleWikiURL: mw("dumbbell-tricep-kickback")),
                    ExerciseOption(id: "push-pushdown-v3", name: "Tríceps francês no cabo", kind: "cabo", muscleWikiURL: mw("cable-rope-skullcrusher")),
                ]
            ),
        ]
    )
}
