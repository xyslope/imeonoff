; imeonoff.ahk — AutoHotkey v2 用 IME 制御スクリプト (Status テスト版)
; Win+Space で IME 状態を表示

IME_EXE := A_ScriptDir "\imeonoff.exe"

#Space::
{
    cmd := Format('{} Status', IME_EXE)
    output := ""
    try {
        RunWait(cmd, &output, "Hide")
    }
    if output = "" {
        output := "IME status unknown"
    }
    ToolTip Trim(output)
    SetTimer () => ToolTip(), -1500
}
