import SwiftUI

/// 左侧进制选择栏
struct BaseSelectorView: View {
    @ObservedObject var viewModel: CalculatorViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(NumberBase.allCases) { base in
                BaseRowView(
                    base: base,
                    value: viewModel.displayValues[base] ?? "0",
                    isActive: viewModel.activeBase == base
                ) {
                    viewModel.selectBase(base)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(width: 130)
    }
}

private struct BaseRowView: View {
    let base: NumberBase
    let value: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // 选中指示条
                Rectangle()
                    .fill(isActive ? Color.blue : Color.clear)
                    .frame(width: 3, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(base.label)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    Text(value)
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
