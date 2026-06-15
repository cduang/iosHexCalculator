import Foundation

/// 支持的数字进制
enum NumberBase: Int, CaseIterable, Identifiable {
    case hex = 16
    case dec = 10
    case oct = 8
    case bin = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .hex: return "HEX"
        case .dec: return "DEC"
        case .oct: return "OCT"
        case .bin: return "BIN"
        }
    }

    /// 当前进制允许输入的最大字符数（64 位无符号整数）
    var maxInputLength: Int {
        switch self {
        case .hex: return 16
        case .dec: return 20
        case .oct: return 22
        case .bin: return 64
        }
    }

    /// 判断字符是否合法
    func isValidCharacter(_ char: Character) -> Bool {
        switch self {
        case .hex:
            return char.isHexDigit
        case .dec:
            return char.isNumber && char <= "9"
        case .oct:
            guard let value = char.wholeNumberValue else { return false }
            return value >= 0 && value <= 7
        case .bin:
            return char == "0" || char == "1"
        }
    }

    /// 将 UInt64 格式化为当前进制字符串
    func format(_ value: UInt64) -> String {
        switch self {
        case .hex:
            return String(value, radix: 16, uppercase: true)
        case .dec:
            return String(value)
        case .oct:
            return String(value, radix: 8, uppercase: false)
        case .bin:
            return String(value, radix: 2, uppercase: false)
        }
    }

    /// 从字符串解析为 UInt64
    func parse(_ string: String) -> UInt64? {
        let trimmed = string.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return 0 }

        switch self {
        case .hex:
            return UInt64(trimmed, radix: 16)
        case .dec:
            return UInt64(trimmed, radix: 10)
        case .oct:
            return UInt64(trimmed, radix: 8)
        case .bin:
            return UInt64(trimmed, radix: 2)
        }
    }
}
