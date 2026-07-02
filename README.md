# imeonoff — Windows IME ON/OFF 制御ツール

Rust 製の Windows IME（日本語入力）ON/OFF 制御ツールです。  
Windows Defenderなどにも削除されない方式（`SendInput` + `VK_CONVERT`/`VK_NONCONVERT`）を採用しています。

英字キーボードなどで、左右のAltでIMEを切り替えるAutoHotkey用のスクリプトも同梱しています。

## 使い方

```
imeonoff.exe ON       # IME を ON にする（変換キー送信）
imeonoff.exe OFF      # IME を OFF にする（無変換キー送信）
imeonoff.exe Toggle   # IME をトグル切り替え
imeonoff.exe Status   # IME 状態を終了コードで返す
```

※　機能はこれだけです。入力モードを記憶する機能等は実装していません。長いこと文章書いたりプログラム書いたりしていますけど、入力モードを切り替えて使ったことはいままで数回しかないからです。

### Status の終了コード

| 終了コード | 意味     |
|-----------|---------|
| 0         | IME ON  |
| 1         | IME OFF |
| 2         | エラー   |

### AHK からの使用例（英字キーボード対応）
同梱のスクリプトを見てください。

英字キーボード対応はAutoHotkey頼りです。もともと、AutoHotkey用に、AltIME.ahkとIMEv2.ahktというツールがあり、長らくそちらを使っていたのですが、ある日「AI時代だから、この機能、Rustで作れるのでは？」と思ってしまったのが始まりです。

IMEv2.ahkの代替として、imeonoff.exeができました。

AltIME.ahkは大幅にリファクタリングしましたが、これで動くようです。

### NeoVimからの使用例
NeoVimでは、im-selectというツールが有名で、正直このツール不要かも？と思っています。まあ、向こうはIMEの状態記憶などもしてくれるという上位互換なので、使ってみたい方はそちらもどうぞ。

NeoVimでは、以下のスクリプトでStatusを記憶させることで、インサートモードに戻ったときに、Statusを復元します。

```lua
-- グローバルスコープの記憶領域
local ime_was_on = false 

local function get_ime_status()
    -- プロセスを実行（出力はどうでもいいので捨てる）
    vim.fn.system("imeonoff.exe Status")
    -- vim.v.shell_error には、直前に実行したプロセスの終了コードが入る
    local exit_code = vim.v.shell_error
    
    -- 終了コードが 0 なら IMEはONだったと判定
    if exit_code == 0 then
        return true
    else
        return false
    end
end
--- 3. インサートモードに入る時
local insert_keys = {'i', 'a', 'o', 'I', 'A', 'O'}
for _, key in ipairs(insert_keys) do
    vim.keymap.set('n', key, function()
        -- 記憶に基づいて必要な時だけONにする
        if ime_was_on then
            ime_on()
        end
        vim.api.nvim_feedkeys(key, 'n', true)
    end)
end

-- 4. インサートモードから抜ける時
vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function()
        ime_was_on = get_ime_status()
        os.execute("imeonoff.exe OFF")
    end,
})

```

### Emacsでの使用例
Emacsでは、このツールを使う必要がありません。
tr-imeを使えば全部やってくれます。

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
