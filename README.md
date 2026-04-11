# FlavorNote

FlavorNote is a lightweight drink taste journal. Users can record daily drinks, adjust taste preferences, save history, and view simple preference analysis.

## Product Positioning

- Drink records
- Preference analysis
- Lifestyle taste memory

## User Path

Open → Take photo → Mark flavor → Save → View preference

## Pages

- Home
- Preference analysis
- History
- Favorites
- Me

## Deployment

Hosted with GitHub Pages:

`https://pmtaiyi-ai.github.io/-ai-/`

## iOS App

Native SwiftUI project:

`FlavorNote-iOS/FlavorNote.xcodeproj`

Implemented:

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
