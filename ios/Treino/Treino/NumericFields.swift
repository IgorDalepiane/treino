import SwiftUI
import UIKit

enum GymNumberKind {
    case kg
    case reps

    var keyboard: UIKeyboardType {
        switch self {
        case .kg: .decimalPad
        case .reps: .numberPad
        }
    }

    var caption: String {
        switch self {
        case .kg: "kg"
        case .reps: "reps"
        }
    }
}

final class SelectAllTextField: UITextField {
    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if ok {
            DispatchQueue.main.async { self.selectAll(nil) }
        }
        return ok
    }
}

struct SelectAllNumberField: UIViewRepresentable {
    var kind: GymNumberKind
    var identifier: String
    @Binding var kg: Double
    @Binding var reps: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(kind: kind, kg: $kg, reps: $reps)
    }

    func makeUIView(context: Context) -> SelectAllTextField {
        let field = SelectAllTextField()
        field.delegate = context.coordinator
        field.keyboardType = kind.keyboard
        field.textAlignment = .center
        field.font = .monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
        field.textColor = UIColor(red: 232 / 255, green: 237 / 255, blue: 245 / 255, alpha: 1)
        field.tintColor = UIColor(red: 91 / 255, green: 159 / 255, blue: 212 / 255, alpha: 1)
        field.backgroundColor = .clear
        field.borderStyle = .none
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 16
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.smartDashesType = .no
        field.smartQuotesType = .no
        field.accessibilityIdentifier = identifier
        field.accessibilityLabel = kind.caption
        field.inputAccessoryView = context.coordinator.makeToolbar()
        field.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
        field.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        context.coordinator.field = field
        field.text = context.coordinator.displayText()
        return field
    }

    func updateUIView(_ field: SelectAllTextField, context: Context) {
        context.coordinator.kind = kind
        context.coordinator.kg = $kg
        context.coordinator.reps = $reps
        if field.isFirstResponder { return }
        let next = context.coordinator.displayText()
        if field.text != next {
            field.text = next
        }
    }

    final class Coordinator: NSObject, UITextFieldDelegate {
        var kind: GymNumberKind
        var kg: Binding<Double>
        var reps: Binding<Int>
        weak var field: UITextField?

        init(kind: GymNumberKind, kg: Binding<Double>, reps: Binding<Int>) {
            self.kind = kind
            self.kg = kg
            self.reps = reps
        }

        func displayText() -> String {
            switch kind {
            case .kg: Self.formatKg(kg.wrappedValue)
            case .reps: String(reps.wrappedValue)
            }
        }

        func makeToolbar() -> UIToolbar {
            let bar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
            bar.barStyle = .black
            bar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(done)),
            ]
            bar.sizeToFit()
            return bar
        }

        @objc func done() {
            commit(field?.text ?? "")
            field?.resignFirstResponder()
        }

        @objc func editingChanged(_ field: UITextField) {
            apply(field.text ?? "", commitEmpty: false)
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async { textField.selectAll(nil) }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            commit(textField.text ?? "")
            textField.text = displayText()
        }

        private func commit(_ raw: String) {
            apply(raw, commitEmpty: true)
        }

        private func apply(_ raw: String, commitEmpty: Bool) {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                if commitEmpty {
                    switch kind {
                    case .kg: kg.wrappedValue = 0
                    case .reps: reps.wrappedValue = 0
                    }
                }
                return
            }
            switch kind {
            case .kg:
                if let value = Self.parseKg(trimmed) {
                    kg.wrappedValue = value
                }
            case .reps:
                if let value = Int(trimmed), value >= 0 {
                    reps.wrappedValue = min(99, value)
                }
            }
        }

        static func formatKg(_ value: Double) -> String {
            if value == value.rounded() { return String(Int(value)) }
            return String(format: "%.1f", value).replacingOccurrences(of: ".", with: ",")
        }

        static func parseKg(_ raw: String) -> Double? {
            let normalized = raw.replacingOccurrences(of: ",", with: ".")
            guard let value = Double(normalized), value >= 0, value.isFinite else { return nil }
            return (value * 10).rounded() / 10
        }
    }
}
