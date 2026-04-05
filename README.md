# snapclip

[English](#english) | [한국어](#한국어)

## English

SnapClip is a macOS menu bar utility that saves the current clipboard image into a folder you choose.

### What it does

- Saves an image from the macOS clipboard.
- Lets you choose and update the destination folder from the Settings screen.
- Supports a user-configurable global shortcut.
- Saves images as PNG files with timestamp-based names.

### Default behavior

- Default save folder: none in sandboxed builds — choose one in Settings first
- Default filename format: `snapclip-yyyyMMdd-HHmmss.png`
- Save format: PNG
- Default shortcut: none — you set it in Settings

### Requirements

- macOS 13 or newer
- Swift 6.2 toolchain / Xcode with Swift Package Manager support

### Run the app

#### From Terminal

```bash
swift run
```

#### From Xcode

1. Open `Package.swift` in Xcode.
2. Build and run the `snapclip` executable target.

### How to use

1. Run the app.
2. Open **Settings** from the menu bar item.
3. Choose the folder where copied images should be saved.
4. Record your preferred shortcut in the **Shortcut** section.
5. Copy an image with `⌘C`.
6. Press your configured shortcut.
7. The image will be saved into the configured folder.

You can also use the **Save Clipboard Image** action directly from the menu bar window.

Sandboxed builds require the folder selection step before saving. SnapClip stores secure bookmark access for the folder you approve.

### How to test

#### Basic manual test

1. Start the app with `swift run` or from Xcode.
2. Open **Settings** and set a destination folder.
3. Record a shortcut.
4. Copy any image to the clipboard.
5. Press the shortcut.
6. Confirm that a PNG file appears in the configured folder.

#### Edge cases to verify

- Try saving when the clipboard does not contain an image and confirm that the app shows an error status.
- Change the destination folder and verify that new images are saved there.
- Use the menu bar button instead of the shortcut and confirm it saves the same way.
- Open the destination folder from the app and confirm Finder opens the configured location.

### Project structure

```text
Sources/snapclip/
├── App/
│   └── AppState.swift
├── Models/
│   └── SnapClipError.swift
├── Services/
│   ├── Clipboard/
│   │   └── ClipboardImageService.swift
│   └── Storage/
│       ├── DestinationFolderBookmarkStore.swift
│       └── ImageWriter.swift
├── UI/
│   ├── MenuBarView.swift
│   └── SettingsView.swift
└── snapclip.swift
```

### Notes

- If the clipboard does not currently contain an image, the save request fails with a status message.
- The app creates the destination folder automatically if it does not exist after you approve that folder in Settings.
- Shortcut recording and global shortcut handling are powered by [`KeyboardShortcuts`](https://github.com/sindresorhus/KeyboardShortcuts).

### Sandboxed local DMG build

For local testing with sandbox entitlements applied:

```bash
chmod +x Scripts/sign-app.sh Scripts/package-local-dmg.sh
Scripts/package-local-dmg.sh
```

Artifacts are generated in `dist/`:

- `dist/SnapClip.app`
- `dist/SnapClip-sandbox.dmg`

The included signing flow is for local sandbox testing. Public distribution still needs your real Developer ID signing and notarization process.

---

## 한국어

SnapClip은 현재 클립보드에 복사된 이미지를 사용자가 선택한 폴더에 저장해 주는 macOS 메뉴바 유틸리티입니다.

### 기능

- macOS 클립보드에 있는 이미지를 저장합니다.
- 설정 화면에서 저장 폴더를 선택하고 변경할 수 있습니다.
- 사용자가 직접 지정하는 전역 단축키를 지원합니다.
- 이미지를 타임스탬프 기반 파일명의 PNG 파일로 저장합니다.

### 기본 동작

- 기본 저장 폴더: sandbox 빌드에서는 없음 — 먼저 Settings에서 폴더를 선택해야 합니다
- 기본 파일명 형식: `snapclip-yyyyMMdd-HHmmss.png`
- 저장 포맷: PNG
- 기본 단축키: 없음 — 설정 화면에서 직접 지정해야 합니다

### 요구 사항

- macOS 13 이상
- Swift 6.2 툴체인 / Swift Package Manager를 지원하는 Xcode

### 실행 방법

#### 터미널에서 실행

```bash
swift run
```

#### Xcode에서 실행

1. Xcode에서 `Package.swift`를 엽니다.
2. `snapclip` 실행 타깃을 빌드하고 실행합니다.

### 사용 방법

1. 앱을 실행합니다.
2. 메뉴바 아이템에서 **Settings**를 엽니다.
3. 복사한 이미지를 저장할 폴더를 선택합니다.
4. **Shortcut** 섹션에서 원하는 단축키를 등록합니다.
5. `⌘C`로 이미지를 복사합니다.
6. 등록한 단축키를 누릅니다.
7. 설정한 폴더에 이미지가 저장됩니다.

메뉴바 창의 **Save Clipboard Image** 버튼으로도 동일하게 저장할 수 있습니다.

sandbox 빌드에서는 먼저 폴더 선택을 해야 저장할 수 있고, SnapClip은 승인된 폴더의 보안 북마크 접근 권한을 저장합니다.

### 테스트 방법

#### 기본 수동 테스트

1. `swift run` 또는 Xcode로 앱을 실행합니다.
2. **Settings**를 열고 저장 폴더를 지정합니다.
3. 단축키를 등록합니다.
4. 아무 이미지를 클립보드에 복사합니다.
5. 등록한 단축키를 누릅니다.
6. 지정한 폴더에 PNG 파일이 생성되는지 확인합니다.

#### 함께 확인하면 좋은 케이스

- 클립보드에 이미지가 없을 때 저장을 시도하고 오류 상태 메시지가 보이는지 확인합니다.
- 저장 폴더를 변경한 뒤 새 이미지가 새 위치에 저장되는지 확인합니다.
- 단축키 대신 메뉴바 버튼으로 저장해도 동일하게 동작하는지 확인합니다.
- 앱에서 저장 폴더 열기를 눌렀을 때 Finder가 올바른 위치를 여는지 확인합니다.

### 프로젝트 구조

```text
Sources/snapclip/
├── App/
│   └── AppState.swift
├── Models/
│   └── SnapClipError.swift
├── Services/
│   ├── Clipboard/
│   │   └── ClipboardImageService.swift
│   └── Storage/
│       ├── DestinationFolderBookmarkStore.swift
│       └── ImageWriter.swift
├── UI/
│   ├── MenuBarView.swift
│   └── SettingsView.swift
└── snapclip.swift
```

### 참고 사항

- 클립보드에 이미지가 없으면 저장 요청은 상태 메시지와 함께 실패합니다.
- Settings에서 승인한 폴더 아래에서만 저장 폴더를 자동 생성합니다.
- 단축키 기록과 전역 단축키 처리는 [`KeyboardShortcuts`](https://github.com/sindresorhus/KeyboardShortcuts)를 사용합니다.

### sandbox 로컬 DMG 빌드

샌드박스 entitlements를 적용한 로컬 테스트용 DMG를 만들려면:

```bash
chmod +x Scripts/sign-app.sh Scripts/package-local-dmg.sh
Scripts/package-local-dmg.sh
```

결과물은 `dist/`에 생성됩니다.

- `dist/SnapClip.app`
- `dist/SnapClip-sandbox.dmg`

현재 포함된 서명 흐름은 로컬 sandbox 테스트용입니다. 공개 배포에는 실제 Developer ID 서명과 notarization이 추가로 필요합니다.
