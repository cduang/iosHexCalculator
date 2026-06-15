import SwiftUI

/// 主计算器界面
struct CalculatorView: View {
    @StateObject private var viewModel = CalculatorViewModel()
    @State private var showMenu = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 显示区域
                displayArea

                // 按键区域
                KeypadView(viewModel: viewModel)
                    .frame(height: keypadHeight)
            }
            .navigationTitle("Programmer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showMenu.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .confirmationDialog("关于", isPresented: $showMenu, titleVisibility: .visible) {
                Button("清除全部") {
                    viewModel.clearEntry()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("程序员进制计算器\n支持 HEX / DEC / OCT / BIN")
            }
        }
    }

    private var displayArea: some View {
        HStack(alignment: .top, spacing: 0) {
            BaseSelectorView(viewModel: viewModel)
                .padding(.top, 8)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6))
    }

    /// 根据屏幕高度自适应按键区高度
    private var keypadHeight: CGFloat {
        min(UIScreen.main.bounds.height * 0.48, 380)
    }
}

#Preview {
    CalculatorView()
}
