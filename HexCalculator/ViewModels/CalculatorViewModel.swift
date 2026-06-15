import Foundation
import Combine

/// 程序员计算器核心逻辑
final class CalculatorViewModel: ObservableObject {
    @Published var activeBase: NumberBase = .hex
    @Published var displayValues: [NumberBase: String] = [:]
    @Published var inputString: String = "0"

    private var storedValue: UInt64 = 0
    private var pendingOperation: CalculatorOperation?
    private var isEnteringNumber = true
    private var hasError = false

    init() {
        updateAllDisplays(from: 0)
    }

    // MARK: - 进制切换

    func selectBase(_ base: NumberBase) {
        guard base != activeBase else { return }

        // 切换进制时，用当前数值在新进制下继续输入
        if let value = activeBase.parse(inputString) {
            activeBase = base
            inputString = base.format(value)
            isEnteringNumber = true
            updateAllDisplays(from: value)
        } else {
            activeBase = base
        }
    }

    // MARK: - 数字输入

    func inputDigit(_ digit: String) {
        guard !hasError else { return }
        guard let char = digit.first, activeBase.isValidCharacter(char) else { return }

        if !isEnteringNumber {
            inputString = String(char)
            isEnteringNumber = true
        } else if inputString == "0" {
            inputString = String(char)
        } else if inputString.count < activeBase.maxInputLength {
            inputString += String(char)
        } else {
            return
        }

        if let value = activeBase.parse(inputString) {
            updateAllDisplays(from: value)
        }
    }

    // MARK: - 控制键

    func clearEntry() {
        hasError = false
        inputString = "0"
        isEnteringNumber = true
        updateAllDisplays(from: 0)
    }

    func backspace() {
        guard !hasError else { return }

        if inputString.count <= 1 {
            inputString = "0"
        } else {
            inputString.removeLast()
        }

        if let value = activeBase.parse(inputString) {
            updateAllDisplays(from: value)
        }
    }

    func setOperation(_ operation: CalculatorOperation) {
        guard !hasError else { return }

        if operation == .not {
            applyUnaryOperation(.not)
            return
        }

        // 连续运算：已有待执行操作时，先结算再挂新操作
        if let pending = pendingOperation, isEnteringNumber {
            if let current = activeBase.parse(inputString) {
                storedValue = calculate(storedValue, current, pending) ?? storedValue
            }
        } else if pendingOperation == nil {
            storedValue = activeBase.parse(inputString) ?? 0
        }

        pendingOperation = operation
        isEnteringNumber = false
        inputString = activeBase.format(storedValue)
        updateAllDisplays(from: storedValue)
    }

    func calculateResult() {
        guard !hasError else { return }

        guard let operation = pendingOperation else { return }

        let current = activeBase.parse(inputString) ?? 0

        if let result = calculate(storedValue, current, operation) {
            applyResult(result)
        }

        pendingOperation = nil
        isEnteringNumber = false
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

    private func applyUnaryOperation(_ operation: CalculatorOperation) {
        guard let current = activeBase.parse(inputString) else { return }

        if let result = calculate(current, 0, operation) {
            applyResult(result)
        }

        pendingOperation = nil
        isEnteringNumber = false
    }

    private func applyResult(_ result: UInt64) {
        inputString = activeBase.format(result)
        updateAllDisplays(from: result)
        storedValue = result
    }

    private func setError() {
        hasError = true
        inputString = "错误"
        for base in NumberBase.allCases {
            displayValues[base] = "—"
        }
    }

    private func updateAllDisplays(from value: UInt64) {
        for base in NumberBase.allCases {
            displayValues[base] = base.format(value)
        }
    }

    private func calculate(_ lhs: UInt64, _ rhs: UInt64, _ op: CalculatorOperation) -> UInt64? {
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
}
