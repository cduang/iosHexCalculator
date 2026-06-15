# HexCalculator - 程序员进制计算器

仿 iOS 原生「Programmer」模式的进制计算器，支持 HEX / DEC / OCT / BIN 实时互转，可打包为 `.tipa` 通过 TrollStore（巨魔）安装。

## 功能

| 功能 | 说明 |
|------|------|
| 四进制显示 | HEX、DEC、OCT、BIN 同步显示当前数值 |
| 进制切换 | 点击左侧进制标签切换输入进制 |
| 算术运算 | `+` `−` `×` `÷` `Mod` |
| 位运算 | `And` `Or` `Xor` `Not` `Lsh` `Rsh` |
| 输入限制 | HEX 可用 A-F；DEC 仅 0-9；BIN 仅 0/1 |
| 64 位整数 | 基于 `UInt64`，溢出/除零会提示错误 |

## 界面预览

- 顶部导航栏标题 **Programmer**
- 左侧四行进制标签 + 实时数值
- 底部 5×6 按键网格（与系统计算器布局一致）

## 环境要求

- **编译**: macOS + Xcode 15+（iOS 应用无法在 Windows 上直接编译）
- **安装**: iPhone/iPad + [TrollStore](https://github.com/opa334/TrollStore)（iOS 14.0 – 16.6.1 等支持版本）
- **最低系统**: iOS 15.0

## 快速开始

### 1. 用 Xcode 打开项目

```bash
open HexCalculator.xcodeproj
```

在 Xcode 中选择真机或模拟器运行调试。

### 2. 打包为 .tipa（TrollStore 安装包）

在 macOS 终端中执行：

```bash
chmod +x build_tipa.sh
./build_tipa.sh
```

成功后输出文件位于：

```
build/HexCalculator.tipa
```

### 3. 安装到设备

1. 将 `HexCalculator.tipa` 传到 iPhone（AirDrop、Filza、爱思助手等）
2. 用 TrollStore 打开该文件
3. 点击安装

## 项目结构

```
HexCalculator/
├── HexCalculator.xcodeproj/     # Xcode 工程
├── HexCalculator/
│   ├── HexCalculatorApp.swift   # 应用入口
│   ├── Models/                  # 数据模型
│   ├── ViewModels/              # 计算逻辑
│   ├── Views/                   # SwiftUI 界面
│   └── Assets.xcassets/         # 资源
├── HexCalculator.entitlements   # 签名权限
├── build_tipa.sh                # 打包脚本
└── README.md
```

## 使用说明

1. **输入数字**：在当前选中的进制下按键输入，四种进制会同步更新
2. **切换进制**：点击左侧 HEX/DEC/OCT/BIN，数值保持不变，输入限制随之改变
3. **运算**：输入第一个数 → 按运算符 → 输入第二个数 → 按 `=`
4. **单目运算**：`Not` 对当前数值取反，无需第二个操作数
5. **清除**：`CE` 清除当前输入；左上角菜单可清除全部

## 自定义

- **应用名称**：修改 `Info.plist` 中的 `CFBundleDisplayName`
- **Bundle ID**：修改 Xcode 工程中的 `PRODUCT_BUNDLE_IDENTIFIER`
- **应用图标**：在 `Assets.xcassets/AppIcon.appiconset` 中添加 1024×1024 图标

## 常见问题

**Q: Windows 能编译吗？**  
A: 不能。iOS 应用必须使用 macOS 上的 Xcode 编译。可将项目拷贝到 Mac 或使用 macOS 虚拟机/云 Mac 服务。

**Q: 没有 Apple 开发者账号能装吗？**  
A: 可以。TrollStore 安装无需开发者账号，打包脚本已禁用代码签名要求。

**Q: ldid 是什么？**  
A: 可选的伪签名工具。若已安装（如通过 `brew install ldid`），脚本会自动签名以提高兼容性。

## 许可证

MIT License
