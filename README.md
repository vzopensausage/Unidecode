# Unidecode

Unidecode 是一个 PowerToys Command Palette 扩展，用于把任意文本中的 `\uXXXX` Unicode 转义转换为可读字符。

例如：

```text
Hello \u4F60\u597D, \uD83D\uDE00
```

会转换为：

```text
Hello 你好, 😀
```

无效或不完整的转义会保持原样。按 Enter 可以复制解码后的结果。

## GitHub Actions

仓库包含两个工作流：

- `Build`：在推送到 `main`、Pull Request 或手动触发时运行测试，并为 x64、ARM64 生成未签名 MSIX 构建产物。
- `Release`：推送形如 `v0.1.0` 的标签时，运行测试、生成带测试证书签名的 x64/ARM64 MSIX，并自动创建 GitHub Release。

项目以微软当前 Command Palette 官方模板为基线，使用 .NET 10。构建完全在 `windows-latest` GitHub runner 中完成，不要求本机安装开发工具。

## 发布

将仓库推送到 GitHub 后创建并推送版本标签：

```powershell
git tag v0.1.0
git push origin v0.1.0
```

也可以从 Actions 页面手动运行 `Release` 并输入版本。

Release 会包含：

- x64 MSIX
- ARM64 MSIX
- `Unidecode.cer` 测试证书
- `Install.ps1` 安装脚本

下载同一 Release 的全部文件到一个目录，然后运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\Install.ps1
```

安装后若 Command Palette 没有立即显示扩展，请运行 `Reload Command Palette Extension`。

> [!WARNING]
> Release 工作流每次都会创建新的自签名测试证书，并由安装脚本把它加入当前用户的 `TrustedPeople`。这适合个人测试，不适合公开、长期分发。正式发布时应使用稳定的受信任代码签名证书，并把 `Package.appxmanifest` 中的 `Publisher` 改成证书主题。

## 解码规则

- 转换小写前缀 `\u` 后紧跟的四位十六进制数。
- 支持大小写十六进制数字。
- 相邻的 UTF-16 高、低代理项会组合为一个补充平面字符。
- 孤立代理项、非法十六进制和不完整转义保持原样。
- 不处理 `\xXX`、`\UXXXXXXXX`、`\n` 等其他转义。

## 项目结构

```text
src/Unidecode.Core/         独立解码逻辑
src/Unidecode/              Command Palette 扩展及 MSIX 清单
tests/Unidecode.Core.Tests/ 无第三方测试框架的快速测试程序
scripts/                    CI 资源、版本及安装脚本
.github/workflows/          构建与自动发布工作流
```
