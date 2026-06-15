import Foundation
import Combine

/// 程序员计算器核心逻辑
/// 状态机：accumulator 保存第一操作数/连算中间结果，pendingOperation 保存待执行运算符
final class CalculatorViewModel: ObservableObject {
    @Published var activeBase: NumberBase = .hex
    @Published var displayValues: [NumberBase: String] = [:]

    private var accumulator: UInt64 = 0
    private var pendingOperation: CalculatorOperation?
    /// 为 true 表示刚按过运算符或等号，下一次输入数字会覆盖而非追加
    private var startNewEntryOnNextDigit = false
    private var hasError = false
    private var inputBuffer = "0"

    init() {
        syncDisplay(0)
    }

    // MARK: - 进制切换

    func selectBase(_ base: NumberBase) {
        guard base != activeBase else { return }

        let value = activeBase.parse(inputBuffer) ?? 0
        activeBase = base
        inputBuffer = base.format(value)
        syncDisplay(value)
    }

    // MARK: - 数字输入

    func inputDigit(_ digit: String) {
        guard !hasError else { return }
        guard let char = digit.first, activeBase.isValidCharacter(char) else { return }

        if startNewEntryOnNextDigit {
            inputBuffer = String(char)
            startNewEntryOnNextDigit = false
        } else if inputBuffer == "0" {
            inputBuffer = String(char)
        } else if inputBuffer.count < activeBase.maxInputLength {
            inputBuffer.append(char)
        } else {
            return
        }

        syncDisplay(currentValue)
    }

    // MARK: - 控制键

    /// CE：清除当前输入；若刚按过运算符则恢复显示第一操作数
    func clearEntry() {
        if hasError {
            resetAll()
            return
        }

        if pendingOperation != nil && startNewEntryOnNextDigit {
            inputBuffer = activeBase.format(accumulator)
            syncDisplay(accumulator)
        } else {
            inputBuffer = "0"
            syncDisplay(0)
        }
    }

    /// 清除全部状态
    func clearAll() {
        resetAll()
    }

    func backspace() {
        guard !hasError else { return }

        if startNewEntryOnNextDigit {
            return
        }

        if inputBuffer.count <= 1 {
            inputBuffer = "0"
        } else {
            inputBuffer.removeLast()
        }

        syncDisplay(currentValue)
    }

    func setOperation(_ operation: CalculatorOperation) {
        guard !hasError else { return }

        if operation == .not {
            applyUnary(.not)
            return
        }

        let current = currentValue

        if let pending = pendingOperation, !startNewEntryOnNextDigit {
            // 连算：已输入第二个操作数，先结算
            guard let result = compute(accumulator, current, pending) else { return }
            accumulator = result
        } else {
            // 首次按运算符，或替换运算符（尚未输入第二个数）→ 只保存第一操作数
            accumulator = current
        }

        pendingOperation = operation
        startNewEntryOnNextDigit = true
        inputBuffer = activeBase.format(accumulator)
        syncDisplay(accumulator)
    }

    func calculateResult() {
        guard !hasError, let pending = pendingOperation else { return }

        let current = currentValue
        guard let result = compute(accumulator, current, pending) else { return }

        accumulator = result
        pendingOperation = nil
        startNewEntryOnNextDigit = true
        inputBuffer = activeBase.format(result)
        syncDisplay(result)
    }

    // MARK: - 按键可用性

    func isDigitEnabled(_ digit: String) -> Bool {
        guard let char = digit.first else { return false }
        return activeBase.isValidCharacter(char)
    }

    func isHexLetterEnabled(_ letter: String) -> Bool {
        activeBase == .hex
    }

    // MARK: - 私有方法

    private var currentValue: UInt64 {
        activeBase.parse(inputBuffer) ?? 0
    }

    private func applyUnary(_ operation: CalculatorOperation) {
        let current = currentValue
        guard let result = compute(current, 0, operation) else { return }

        accumulator = result
        pendingOperation = nil
        startNewEntryOnNextDigit = true
        inputBuffer = activeBase.format(result)
        syncDisplay(result)
    }

    private func resetAll() {
        hasError = false
        accumulator = 0
        pendingOperation = nil
        startNewEntryOnNextDigit = false
        inputBuffer = "0"
        syncDisplay(0)
    }

    private func syncDisplay(_ value: UInt64) {
        for base in NumberBase.allCases {
            displayValues[base] = base.format(value)
        }
    }

    private func compute(_ lhs: UInt64, _ rhs: UInt64, _ op: CalculatorOperation) -> UInt64? {
        switch op {
        case .add:
            let result = lhs.addingReportingOverflow(rhs)
            if result.overflow { setError(); return nil }
            return result.partialValue

        case .subtract:
            if rhs > lhs { setError(); return nil }
            return lhs - rhs

        case .multiply:
            let result = lhs.multipliedReportingOverflow(by: rhs)
            if result.overflow { setError(); return nil }
            return result.partialValue

        case .divide:
            if rhs == 0 { setError(); return nil }
            return lhs / rhs

        case .modulo:
            if rhs == 0 { setError(); return nil }
            return lhs % rhs

        case .and:
            return lhs & rhs

        case .or:
            return lhs | rhs

        case .xor:
            return lhs ^ rhs

        case .leftShift:
            guard rhs < 64 else { setError(); return nil }
            return lhs << rhs

        case .rightShift:
            guard rhs < 64 else { setError(); return nil }
            return lhs >> rhs

        case .not:
            return ~lhs
        }
    }

    private func setError() {
        hasError = true
        inputBuffer = "错误"
        for base in NumberBase.allCases {
            displayValues[base] = "—"
        }
    }
}
