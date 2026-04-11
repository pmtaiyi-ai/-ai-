# 项目部署说明

GitHub Pages 当前发布的是河南人在广州老乡活动网站。

## 当前文件

- `index.html`：河南人在广州网站页面结构
- `styles.css`：网站视觉设计
- `script.js`：网页交互
- `.nojekyll`：GitHub Pages 静态部署配置

## 当前线上地址

`https://pmtaiyi-ai.github.io/-ai-/`

## FlavorNote iOS App

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
