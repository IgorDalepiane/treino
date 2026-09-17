import SwiftUI

struct RootView: View {
    @Environment(GymStore.self) private var store
    @State private var selectedJsDow = Catalog.jsWeekday()
    @State private var showSettings = false

    private var todayJs: Int { Catalog.jsWeekday() }
    private var selectedDay: DayPlan { Catalog.day(selectedJsDow) }
    private var isBrowsingOtherDay: Bool { selectedJsDow != todayJs }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                WeekStrip(selectedJsDow: $selectedJsDow, todayJs: todayJs)
                if isBrowsingOtherDay {
                    Text("Hoje é \(DayStamp.weekdayName(todayJs)). Isso é o plano de \(DayStamp.weekdayName(selectedJsDow)) — pode treinar mesmo assim.")
                        .font(.footnote)
                        .foregroundStyle(Palette.muted)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Palette.bg2)
                }
                switch selectedDay.kind {
                case .gym(let programId):
                    WorkoutView(program: Catalog.program(programId))
                case .info:
                    InfoDayView(day: selectedDay) { programId in
                        if let match = Catalog.orderedWeek.first(where: { $0.gymProgramId == programId }) {
                            selectedJsDow = match.id
                        }
                    }
                }
            }
            .background(Palette.bg.ignoresSafeArea())
            .navigationTitle("Treino")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Exportar e importar")
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
        }
        .tint(Palette.text)
    }
}

struct WeekStrip: View {
    @Binding var selectedJsDow: Int
    var todayJs: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Catalog.orderedWeek) { day in
                Button {
                    selectedJsDow = day.id
                } label: {
                    VStack(spacing: 6) {
                        Text(day.shortName.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.6)
                        Text(shortPill(day))
                            .font(.system(size: 10, weight: .semibold))
                            .lineLimit(1)
                            .foregroundStyle(day.accent.color)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(background(for: day))
                    .foregroundStyle(day.id == todayJs ? Palette.bg : Palette.text)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(day.id == selectedJsDow ? Palette.text.opacity(0.85) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("week-\(day.shortName)")
                .accessibilityLabel("\(day.shortName), \(day.title)")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Palette.bg.opacity(0.92))
    }

    private func shortPill(_ day: DayPlan) -> String {
        switch day.kind {
        case .gym(let id):
            id == "push" ? "Push" : Catalog.program(id).name
        case .info:
            day.accent == .run ? "Run" : "Vôlei"
        }
    }

    private func background(for day: DayPlan) -> Color {
        if day.id == todayJs { return Palette.text }
        return Palette.bg2
    }
}

struct InfoDayView: View {
    let day: DayPlan
    var openProgram: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(day.title)
                        .font(.title2.weight(.semibold))
                    Text(day.subtitle)
                        .foregroundStyle(day.accent.color)
                        .font(.subheadline.weight(.semibold))
                    Text(day.body)
                        .foregroundStyle(Palette.muted)
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Palette.bg2)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text("Treinar agora")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Palette.muted)
                    .textCase(.uppercase)
                    .tracking(1)

                Text("O plano da semana não trava o dia. Se pulou a terça, abre o Pull.")
                    .font(.footnote)
                    .foregroundStyle(Palette.muted)

                ForEach(Catalog.programs, id: \.id) { program in
                    Button {
                        openProgram(program.id)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(program.name)
                                    .font(.headline)
                                    .foregroundStyle(program.accent.color)
                                Text(program.tag)
                                    .font(.caption)
                                    .foregroundStyle(Palette.muted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Palette.muted)
                        }
                        .padding(16)
                        .background(Palette.bg2)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("open-program-\(program.id)")
                }
            }
            .padding(16)
        }
    }
}
