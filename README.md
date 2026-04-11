# 河南人在广州网站 + FlavorNote iOS App

这个仓库包含两个部分：

1. GitHub Pages 线上首页：河南人在广州老乡活动网站。
2. 原生 iOS 工程：FlavorNote 饮品口味记录 App。

## 河南人在广州网站

线上地址：

`https://pmtaiyi-ai.github.io/-ai-/`

页面内容：

- 河南人在广州社群介绍
- 河南特色
- 历史文案
- 老乡活动
- 在广州的河南人照片
- 联系人王子
- 总部地址：羊城创业园

## FlavorNote iOS App

原生 SwiftUI 工程：

`FlavorNote-iOS/FlavorNote.xcodeproj`

已实现：

- Home taste recording flow
- Camera and album photo input
- Microphone permission flow for voice notes
- Sweet/bitter and light/rich sliders
- Flavor tags
- Preference analysis
- History
- Favorites
- Profile and in-app purchase concept cards

Build check:

```bash
xcodebuild -project FlavorNote-iOS/FlavorNote.xcodeproj -scheme FlavorNote -sdk iphonesimulator -configuration Debug -derivedDataPath FlavorNote-iOS/Build/DerivedData CODE_SIGNING_ALLOWED=NO build
```
