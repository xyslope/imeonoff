# imeonoff — Windows IME ON/OFF 制御ツール

Rust 製の Windows IME（日本語入力）ON/OFF 制御ツールです。  
**CrowdStrike Falcon** 環境でも削除されない方式（`SendInput` + `VK_CONVERT`/`VK_NONCONVERT`）を採用しています。

## 使い方

```
imeonoff.exe ON       # IME を ON にする（変換キー送信）
imeonoff.exe OFF      # IME を OFF にする（無変換キー送信）
imeonoff.exe Toggle   # IME をトグル切り替え
imeonoff.exe Status   # IME 状態を終了コードで返す
```

### Status の終了コード

| 終了コード | 意味     |
|-----------|---------|
| 0         | IME ON  |
| 1         | IME OFF |
| 2         | エラー   |

### AHK からの使用例

```ahk
IME_EXE := "C:\Users\yusakata\bin\imeonoff.exe"

#UseHook
#Space::      RunWait IME_EXE " Toggle", , "Hide"
#F1::         RunWait IME_EXE " ON",     , "Hide"
#F2::         RunWait IME_EXE " OFF",    , "Hide"
```

## ビルド

Windows 環境で Rust MSVC ツールチェーンが必要です。

```bash
cargo build --release
```

`target/release/imeonoff.exe` が生成されます。

### Cargo.toml 要件

```toml
[dependencies.windows]
version = "0.58"
features = ["Win32_UI_Input_KeyboardAndMouse"]
```

## アーキテクチャ

- `imeonoff.exe` — Rust 製本体。`SendInput` で仮想キーを送信し、`WM_IME_CONTROL` で状態取得
- `imeonoff.ahk` — AHK v2 ランチャースクリプト
- `AltIME_imeonoff.ahk` — AltIME 置き換え用スクリプト（IMEv2.ahk から移行）

## ライセンス

MIT
