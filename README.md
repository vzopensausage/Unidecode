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

仓库包含三个工作流：

- `Build`：在推送到 `main`、Pull Request 或手动触发时运行测试，并为 x64、ARM64 生成未签名 MSIX 构建产物。
- `Release`：推送形如 `v0.1.0` 的标签时，运行测试、生成带测试证书签名的 x64/ARM64 MSIX，并自动创建 GitHub Release。
- `Microsoft Store Release`：构建 x64/ARM64 Store bundle，并通过官方 Microsoft Store Developer CLI 发布免费应用更新。

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

## Microsoft Store 自动发布

Store 自动化使用微软官方的 `microsoft/microsoft-store-apppublisher@v1.1` Action。当前该接口只支持免费产品的更新，并要求应用已经在 Microsoft Store 中手工成功发布过至少一次。

在 GitHub 仓库的 `Settings → Environments` 中创建名为 `microsoft-store` 的 Environment。建议为该 Environment 配置 Required reviewers，避免标签被误推送时直接发布。

在 `Settings → Secrets and variables → Actions` 中添加以下 Repository secrets：

| Secret | 来源 |
| --- | --- |
| `AZURE_AD_TENANT_ID` | Microsoft Entra 租户 ID |
| `AZURE_AD_APPLICATION_CLIENT_ID` | Entra 应用注册的客户端 ID |
| `AZURE_AD_APPLICATION_SECRET` | Entra 应用注册的客户端密钥 |
| `SELLER_ID` | Partner Center 的 Seller ID |

添加以下 Repository variables：

| Variable | 来源或用途 |
| --- | --- |
| `STORE_PRODUCT_ID` | Partner Center 中 Unidecode 的 Store Product ID |
| `STORE_IDENTITY_NAME` | Partner Center → Product identity → Package/Identity/Name |
| `STORE_PUBLISHER` | Partner Center → Product identity → Package/Identity/Publisher |
| `STORE_PUBLISHER_DISPLAY_NAME` | Partner Center 分配或验证的 Publisher display name |
| `STORE_AUTO_PUBLISH` | 设置为 `true` 后，推送 `v*.*.*` 标签会同时发布 Store 更新 |

工作流不会把这些值写回仓库。Store Identity 会在 runner 的临时工作副本中注入到清单，凭据只通过 Secrets 传给 Store CLI。

首次配置时：

1. 在 Partner Center 中创建并手工发布免费版 Unidecode。
2. 将 Entra 应用注册添加到 Partner Center 用户管理，并授予 Manager 角色。
3. 添加上述 Secrets 和 Variables。
4. 从 Actions 页面手动运行 `Microsoft Store Release`。
5. 手动运行成功后，将 `STORE_AUTO_PUBLISH` 设置为 `true`，后续版本标签即可自动发布 GitHub Release 和 Store 更新。

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
