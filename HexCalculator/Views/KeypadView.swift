import SwiftUI

/// 5×6 按键网格
struct KeypadView: View {
    @ObservedObject var viewModel: CalculatorViewModel

    private let rows: [[KeypadItem]] = [
        [.op("Lsh", .leftShift), .op("Rsh", .rightShift), .op("Or", .or), .op("Xor", .xor), .op("Not", .not)],
        [.op("And", .and), .op("Mod", .modulo), .action("CE", .clearEntry), .action("⌫", .backspace), .action("=", .equals)],
        [.digit("A"), .digit("B"), .digit("7"), .digit("8"), .digit("9")],
        [.digit("C"), .digit("D"), .digit("4"), .digit("5"), .digit("6")],
        [.digit("E"), .digit("F"), .digit("1"), .digit("2"), .digit("3")],
        [.op("÷", .divide), .op("×", .multiply), .op("−", .subtract), .digit("0"), .op("+", .add)]
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, item in
                        KeypadButton(
                            item: item,
                            isEnabled: isEnabled(item),
                            isGray: isGrayBackground(item)
                        ) {
                            handleTap(item)
                        }
                    }
                }
            }
        }
        .overlay(
            GridLinesOverlay(columns: 5, rows: 6)
        )
    }

    private func isGrayBackground(_ item: KeypadItem) -> Bool {
        switch item {
        case .op, .action:
            return true
        case .digit(let d):
            return ["A", "B", "C", "D", "E", "F", "÷", "×", "−", "+"].contains(d)
        }
    }

    private func isEnabled(_ item: KeypadItem) -> Bool {
        switch item {
        case .digit(let d):
            if ["A", "B", "C", "D", "E", "F"].contains(d) {
                return viewModel.isHexLetterEnabled(d)
            }
            return viewModel.isDigitEnabled(d)
        case .op, .action:
            return true
        }
    }

    private func handleTap(_ item: KeypadItem) {
        switch item {
        case .digit(let d):
            viewModel.inputDigit(d)
        case .op(_, let op):
            viewModel.setOperation(op)
        case .action(_, let action):
            switch action {
            case .clearEntry:
                viewModel.clearEntry()
            case .backspace:
                viewModel.backspace()
            case .equals:
                viewModel.calculateResult()
            }
        }
    }
}

// MARK: - 按键模型

private enum KeypadItem {
    case digit(String)
    case op(String, CalculatorOperation)
    case action(String, KeypadAction)
}

private enum KeypadAction {
    case clearEntry
    case backspace
    case equals
}

// MARK: - 单个按键

private struct KeypadButton: View {
    let item: KeypadItem
    let isEnabled: Bool
    let isGray: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(isEnabled ? .primary : Color(.systemGray3))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isGray ? Color(.systemGray5) : Color(.systemBackground))
        }
        .disabled(!isEnabled)
        .buttonStyle(KeypadButtonStyle())
    }

    private var label: String {
        switch item {
        case .digit(let d): return d
        case .op(let s, _): return s
        case .action(let s, _): return s
        }
    }
}

private struct KeypadButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

// MARK: - 网格分隔线

private struct GridLinesOverlay: View {
    let columns: Int
    let rows: Int

    var body: some View {
        GeometryReader { geo in
            let colWidth = geo.size.width / CGFloat(columns)
            let rowHeight = geo.size.height / CGFloat(rows)

            Path { path in
                // 竖线
                for i in 1..<columns {
                    let x = CGFloat(i) * colWidth
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                }
                // 横线
                for i in 1..<rows {
                    let y = CGFloat(i) * rowHeight
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color(.systemGray4), lineWidth: 0.5)
        }
        .allowsHitTesting(false)
    }
}
