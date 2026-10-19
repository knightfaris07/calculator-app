import SwiftUI

enum CalcButton: String {
    case zero = "0", one = "1", two = "2", three = "3", four = "4"
    case five = "5", six = "6", seven = "7", eight = "8", nine = "9"
    case dot = ".", equals = "="
    case plus = "+", minus = "−", multiply = "×", divide = "÷"
    case clear = "AC", plusMinus = "+/-", percent = "%"
    case delete = "⌫"

    var color: Color {
        switch self {
        case .clear, .plusMinus, .percent, .delete:
            return Color(.darkGray).opacity(0.8)
        case .plus, .minus, .multiply, .divide, .equals:
            return Color.orange
        default:
            return Color(.systemGray).opacity(0.5)
        }
    }
}

struct CalculatorView: View {
    @State private var display = "0"
    @State private var currentValue: Double = 0
    @State private var previousValue: Double = 0
    @State private var currentOp: CalcButton? = nil
    @State private var freshEntry = true

    let buttons: [[CalcButton]] = [
        [.clear, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .dot, .delete, .equals],
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                HStack {
                    Spacer()
                    Text(display)
                        .foregroundColor(.white)
                        .font(.system(size: displayFontSize, weight: .light))
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)
                        .padding(.horizontal, 24)
                }

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { button in
                            Button(action: { tap(button) }) {
                                Text(button.rawValue)
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(button.color)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.bottom, 4)
            }
            .padding(.bottom, 16)
        }
        .frame(width: 340, height: 560)
    }

    private var buttonSize: CGFloat { 72 }

    private var displayFontSize: CGFloat {
        display.count > 9 ? 42 : display.count > 6 ? 56 : 72
    }

    private func tap(_ button: CalcButton) {
        switch button {
        case .clear:
            display = "0"
            currentValue = 0
            previousValue = 0
            currentOp = nil
            freshEntry = true

        case .delete:
            if display.count > 1 {
                display.removeLast()
            } else {
                display = "0"
            }
            currentValue = Double(display) ?? 0

        case .plusMinus:
            if let v = Double(display) {
                let result = -v
                display = formatted(result)
                currentValue = result
            }

        case .percent:
            if let v = Double(display) {
                let result = v / 100
                display = formatted(result)
                currentValue = result
            }

        case .dot:
            if freshEntry {
                display = "0."
                freshEntry = false
            } else if !display.contains(".") {
                display += "."
            }

        case .plus, .minus, .multiply, .divide:
            previousValue = Double(display) ?? currentValue
            currentOp = button
            freshEntry = true

        case .equals:
            let rhs = Double(display) ?? 0
            let lhs = previousValue
            var result: Double = 0
            switch currentOp {
            case .plus:     result = lhs + rhs
            case .minus:    result = lhs - rhs
            case .multiply: result = lhs * rhs
            case .divide:   result = rhs != 0 ? lhs / rhs : 0
            default:        result = rhs
            }
            display = formatted(result)
            currentValue = result
            previousValue = result
            freshEntry = true

        default:
            let digit = button.rawValue
            if freshEntry {
                display = digit
                freshEntry = false
            } else {
                display = display == "0" ? digit : display + digit
            }
            currentValue = Double(display) ?? 0
        }
    }

    private func formatted(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 && abs(value) < 1e15 {
            return String(Int64(value))
        }
        let s = String(format: "%.10g", value)
        return s
    }
}
