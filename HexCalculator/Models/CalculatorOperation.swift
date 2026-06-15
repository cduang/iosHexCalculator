import Foundation

/// 计算器操作类型
enum CalculatorOperation: Equatable {
    case add
    case subtract
    case multiply
    case divide
    case modulo
    case and
    case or
    case xor
    case leftShift
    case rightShift
    case not

    var needsSecondOperand: Bool {
        switch self {
        case .not:
            return false
        default:
            return true
        }
    }

    var symbol: String {
        switch self {
        case .add: return "+"
        case .subtract: return "−"
        case .multiply: return "×"
        case .divide: return "÷"
        case .modulo: return "Mod"
        case .and: return "And"
        case .or: return "Or"
        case .xor: return "Xor"
        case .leftShift: return "Lsh"
        case .rightShift: return "Rsh"
        case .not: return "Not"
        }
    }
}
