; AltIME + imeonoff.exe — Alt空打ちIME制御
IME_EXE := "C:\Users\yusakata\bin\imeonoff.exe"
#SingleInstance Force

; トレイメニュー（標準のみ）
Tray := A_TrayMenu
Tray.Delete()
Tray.AddStandard()

; キーフック（A_PriorKey用）
InstallKeybdHook

; Alt空打ち — メニュー抑制（vkFFでメニュー起動防止）
*~LAlt::Send("{Blind}{vkFF}")
*~RAlt::Send("{Blind}{vkFF}")

; 左Alt空打ち → OFF
#HotIf !WinActive("ahk_exe mstsc.exe")
LAlt up:: {
    if (A_PriorKey = "LAlt")
        RunWait IME_EXE " OFF", , "Hide"
}
; 右Alt空打ち → ON
RAlt up:: {
    if (A_PriorKey = "RAlt")
        RunWait IME_EXE " ON", , "Hide"
}
#HotIf

; 無変換(sc07B)→OFF / 変換(sc079)→ON
sc07B::RunWait IME_EXE " OFF", , "Hide"
sc079::RunWait IME_EXE " ON", , "Hide"

; RCtrl→F24→IME ON
RCtrl::Send("{F24}")
F24::RunWait IME_EXE " ON", , "Hide"

; #f: Google検索
#f::{
    A_Clipboard := ""
    Send "^c"
    ClipWait(1)
    Run "https://www.google.co.jp/search?q=" A_Clipboard
}

; Emacs: Ctrl+v（Aqua Voice対策）
#HotIf WinActive("ahk_exe emacs.exe")
$^v::{
    if (A_TimeIdlePhysical > 20) {
        Send("{Ctrl Up}")
        Sleep(10)
        Send("^y")
    } else {
        Send("^v")
    }
}
#HotIf

; Nvim/Emacs: Esc離脱時IME OFF
#HotIf WinActive("ahk_exe nvim-qt.exe") or (WinActive("A") and InStr(WinGetTitle("A"), "- Nvim")) or WinActive("ahk_exe emacs.exe") or (WinActive("A") and InStr(WinGetTitle("A"), "- Emacs"))
$Esc::{
    Send("{Esc}")
    RunWait IME_EXE " OFF", , "Hide"
    Sleep(10)
    Send("{Esc}")
}
#HotIf
