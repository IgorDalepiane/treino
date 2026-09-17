import SwiftUI

struct WorkoutView: View {
    @Environment(GymStore.self) private var store
    let program: GymProgram

    private var today: String { DayStamp.string() }

    private var nextSlot: ExerciseSlot? {
        program.slots.first { !store.hasLoggedSlot(date: today, programId: program.id, slotId: $0.id) }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    if let next = nextSlot {
                        Button {
                            withAnimation { proxy.scrollTo(next.id, anchor: .top) }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Próximo")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(Palette.muted)
                                        .textCase(.uppercase)
                                    Text(nextExerciseName(next))
                                        .font(.headline)
                                }
                                Spacer()
                                Image(systemName: "arrow.down")
                            }
                            .padding(14)
                            .background(program.accent.background)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("next-exercise")
                    } else {
                        Text("Treino de hoje registrado. Pode fechar o app.")
                            .font(.subheadline)
                            .foregroundStyle(Palette.run)
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Palette.runBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    ForEach(program.slots) { slot in
                        ExerciseCard(programId: program.id, date: today, slot: slot)
                            .id(slot.id)
                    }
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
    }

    private func nextExerciseName(_ slot: ExerciseSlot) -> String {
        if let variantId = store.lastVariant(slotId: slot.id) {
            return slot.options.first { $0.id == variantId }?.name ?? slot.main.name
        }
        return slot.main.name
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(program.name)
                    .font(.title2.weight(.semibold))
                Spacer()
                Text(program.tag)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(program.accent.background)
                    .foregroundStyle(program.accent.color)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            Text("Registrando em \(DayStamp.pretty(today)) (hoje), não no dia da ficha.")
                .font(.footnote)
                .foregroundStyle(Palette.muted)
            Text(program.summary)
                .font(.footnote)
                .foregroundStyle(Palette.muted)
            if let note = program.note {
                Text(note)
                    .font(.footnote)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.bg3)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(16)
        .background(Palette.bg2)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

struct ExerciseCard: View {
    @Environment(GymStore.self) private var store
    let programId: String
    let date: String
    let slot: ExerciseSlot

    @State private var variantId: String = ""
    @State private var kg: [Double] = []
    @State private var reps: [Int] = []
    @State private var showVideo = false
    @State private var hydrated = false
    @State private var sourceCaption = ""

    private var option: ExerciseOption {
        slot.options.first { $0.id == variantId } ?? slot.main
    }

    private var isLoggedToday: Bool {
        !variantId.isEmpty && store.loggedExercise(date: date, programId: programId, slotId: slot.id, variantId: variantId) != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        if slot.isWarmup {
                            Text("AQUECIMENTO")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Palette.muted)
                        }
                        Text(slot.prescription)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Palette.muted)
                    }
                    Text(option.name)
                        .font(.headline)
                    if let note = slot.note {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(Palette.muted)
                    }
                }
                Spacer()
                Button {
                    showVideo = true
                } label: {
                    Label("Execução", systemImage: "play.circle.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .accessibilityIdentifier("video-\(slot.id)")
            }

            if !slot.variants.isEmpty {
                Picker("Variante", selection: $variantId) {
                    ForEach(slot.options) { item in
                        Text("\(item.name) · \(item.kind)").tag(item.id)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("variant-\(slot.id)")
                .onChange(of: variantId) { _, _ in
                    guard hydrated else { return }
                    hydrate()
                }
            }

            if !sourceCaption.isEmpty {
                Text(sourceCaption)
                    .font(.caption)
                    .foregroundStyle(isLoggedToday ? Palette.run : Palette.muted)
                    .accessibilityIdentifier("caption-\(slot.id)")
            }

            ForEach(0..<slot.setCount, id: \.self) { index in
                SetRow(
                    index: index,
                    slotId: slot.id,
                    kg: bindingKg(index),
                    reps: bindingReps(index)
                )
            }
        }
        .padding(16)
        .background(Palette.bg2)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isLoggedToday ? Palette.run.opacity(0.45) : Palette.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onAppear { hydrate() }
        .sheet(isPresented: $showVideo) {
            VideoSheet(title: option.name, url: option.muscleWikiURL)
        }
    }

    private func bindingKg(_ index: Int) -> Binding<Double> {
        Binding(
            get: { kg.indices.contains(index) ? kg[index] : 0 },
            set: { value in
                ensureArrays()
                kg[index] = value
                persist()
            }
        )
    }

    private func bindingReps(_ index: Int) -> Binding<Int> {
        Binding(
            get: { reps.indices.contains(index) ? reps[index] : 0 },
            set: { value in
                ensureArrays()
                reps[index] = value
                persist()
            }
        )
    }

    private func ensureArrays() {
        if kg.count != slot.setCount { kg = Array(repeating: 0, count: slot.setCount) }
        if reps.count != slot.setCount { reps = Array(repeating: 0, count: slot.setCount) }
        if variantId.isEmpty { variantId = slot.main.id }
    }

    private func hydrate() {
        ensureArrays()
        if variantId.isEmpty {
            variantId = store.lastVariant(slotId: slot.id) ?? slot.main.id
        }
        if let todayLog = store.loggedExercise(date: date, programId: programId, slotId: slot.id, variantId: variantId) {
            kg = padded(todayLog.sets.map(\.kg), count: slot.setCount, fill: 0)
            reps = padded(todayLog.sets.map(\.reps), count: slot.setCount, fill: 0)
            sourceCaption = "Registrado hoje nesta variação"
        } else if let last = store.lastExercise(slotId: slot.id, variantId: variantId, before: date) {
            kg = padded(last.0.sets.map(\.kg), count: slot.setCount, fill: 0)
            reps = padded(last.0.sets.map(\.reps), count: slot.setCount, fill: 0)
            sourceCaption = "Última vez nesta variação \(DayStamp.pretty(last.1)) · edite pra gravar hoje"
        } else {
            kg = Array(repeating: 0, count: slot.setCount)
            reps = Array(repeating: 0, count: slot.setCount)
            sourceCaption = "Primeira vez nesta variação · edite pra gravar hoje"
        }
        hydrated = true
    }

    private func persist() {
        guard hydrated else { return }
        let sets = zip(kg, reps).map { LoggedSet(kg: $0.0, reps: $0.1) }
        store.saveExercise(date: date, programId: programId, slotId: slot.id, variantId: variantId, sets: sets)
        sourceCaption = "Registrado hoje nesta variação"
    }

    private func padded<T>(_ values: [T], count: Int, fill: T) -> [T] {
        if values.count >= count { return Array(values.prefix(count)) }
        return values + Array(repeating: fill, count: count - values.count)
    }
}

struct SetRow: View {
    let index: Int
    let slotId: String
    @Binding var kg: Double
    @Binding var reps: Int

    var body: some View {
        HStack(spacing: 10) {
            Text("S\(index + 1)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Palette.muted)
                .frame(width: 28, alignment: .leading)
            numberBox(kind: .kg, identifier: "kg-field-\(slotId)-\(index)")
            numberBox(kind: .reps, identifier: "reps-field-\(slotId)-\(index)")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("set-\(index + 1)")
    }

    private func numberBox(kind: GymNumberKind, identifier: String) -> some View {
        VStack(spacing: 2) {
            SelectAllNumberField(kind: kind, identifier: identifier, kg: $kg, reps: $reps)
                .frame(height: 40)
            Text(kind.caption)
                .font(.caption2)
                .foregroundStyle(Palette.muted)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Palette.bg3)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
