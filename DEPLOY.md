# FlavorNote 部署说明

这个 App 是纯静态页面，不需要服务器、不需要数据库，适合部署到 GitHub Pages。

## 当前文件

- `index.html`：App 页面结构
- `styles.css`：产品视觉设计
- `script.js`：拍照、滑条、保存、分析、收藏等交互
- `.nojekyll`：GitHub Pages 静态部署配置

## 当前线上地址

`https://pmtaiyi-ai.github.io/-ai-/`

## iOS App

原生 iOS 工程在：

`FlavorNote-iOS/FlavorNote.xcodeproj`

本地预览：

1. 双击打开 `FlavorNote-iOS/FlavorNote.xcodeproj`。
2. 在 Xcode 顶部选择 iPhone 模拟器。
3. 点击 Run。

真机安装或 TestFlight / App Store 上架需要：

- Apple Developer 账号
- Xcode 登录 Apple ID
- 设置 Team 和 Bundle Identifier
- 配置签名证书
- Archive 后上传 App Store Connect

## 后续可扩展

- 接入真实后端数据库
- 接入云端图片存储
- 增加登录和同步
- 接入语音识别
- 增加内购和订阅页面
