    ; 左右 Alt キーの空打ちで IME を ON/OFF する AutoHotkey スクリプト
;
; 左 Alt キーの空打ちで IME OFF
; 右 Alt キーの空打ちで IME ON
; Alt キーを押している間に他のキーを打つと通常の Alt キーとして動作
;
; Author:              ryo
; Original author:     karakaram   http://www.karakaram.com/alt-ime-on-off
;                      SorrowBlue  https://github.com/SorrowBlue/alt-ime-ahk-mod-v2

IME_EXE := "C:\Users\" A_UserName "\bin\imeonoff.exe"
#SingleInstance Force

; メニュー項目
Tray:= A_TrayMenu
Tray.Add(A_ScriptName, AppName)
Tray.Disable(A_ScriptName)
Tray.Default := A_ScriptName
Tray.Add()
Tray.Add("Check for Updates...", CheckForUpdates)
Tray.Add("GitHub Repo / Readme", GitHubRepoReadme)
Tray.Add()
Tray.Delete()
Tray.AddStandard()
Return

AppName(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{
    Return
}

CheckForUpdates(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{
    Run("https://github.com/nekocodeX/alt-ime-ahk-mod/releases/latest")
    Return
}

GitHubRepoReadme(A_ThisMenuItem, A_ThisMenuItemPos, MyMenu)
{
    Run("https://github.com/nekocodeX/alt-ime-ahk-mod")
    Return
}

; 主要なキーを HotKey に設定し、何もせずパススルーする
*~a::
*~b::
*~c::
*~d::
*~e::
*~f::
*~g::
*~h::
*~i::
*~j::
*~k::
*~l::
*~m::
*~n::
*~o::
*~p::
*~q::
*~r::
*~s::
*~t::
*~u::
*~v::
*~w::
*~x::
*~y::
*~z::
*~1::
*~2::
*~3::
*~4::
*~5::
*~6::
*~7::
*~8::
*~9::
*~0::
*~F1::
*~F2::
*~F3::
*~F4::
*~F5::
*~F6::
*~F7::
*~F8::
*~F9::
*~F10::
*~F11::
*~F12::
*~`::
*~~::
*~!::
*~@::
*~#::
*~$::
*~%::
*~^::
*~&::
*~*::
*~(::
*~)::
*~-::
*~_::
*~=::
*~+::
*~[::
*~{::
*~]::
*~}::
*~\::
*~|::
*~;::
*~'::
*~"::
*~,::
*~<::
*~.::
*~>::
*~/::
*~?::
*~Esc::
*~Tab::
*~Space::
*~Left::
*~Right::
*~Up::
*~Down::
*~Enter::
*~PrintScreen::
*~Delete::
*~Home::
*~End::
*~PgUp::
*~PgDn::
{
    Return
}

; 上部メニューがアクティブになるのを抑制 / Xbox Game Bar 起動用仮想キーコードとのバッティング回避 (vk07 -> vkFF)
*~LAlt::
{
    Send("{Blind}{vkFF}")
}
*~RAlt::
{
    Send("{Blind}{vkFF}")
}

; 左 Alt 空打ちで IME を OFF
#HotIf !WinActive("ahk_exe mstsc.exe")
LAlt up::
{
    if (A_PriorHotkey == "*~LAlt") {
        RunWait IME_EXE " OFF", , "Hide"
    }
    Return
}
#HotIf

; 右 Alt 空打ちで IME を ON
#HotIf !WinActive("ahk_exe mstsc.exe")
RAlt up::
{
    if (A_PriorHotkey == "*~RAlt") {
        RunWait IME_EXE " ON", , "Hide"
    }
    Return
}
#HotIf

; CapsLock 無効化
;CapsLock::return

#f::
{
A_Clipboard := ""
Send "^c"
ClipWait(1)
Run "https://www.google.co.jp/search?q=" A_Clipboard
}


; 無変換キー（sc07B）を左Altキーとして動作させる
; 変換キー（sc079）を右Altキーとして動作させる

;sc07B:: Send {vkF2sc070}{vkF3sc029}
;sc079:: Send {vkF2sc070}

; 無変換キー（sc07B）をIMEオフに
sc07B:: {
    RunWait IME_EXE " OFF", , "Hide"
}

; 変換キー（sc079）をIMEオンに

sc079::
{
    RunWait IME_EXE " ON", , "Hide"  ; IMEオン
}    

; 右 Ctrl 空打ちで IME を ON
;#HotIf !WinActive("ahk_exe mstsc.exe")
;RCtrl up::
;{
;    if (A_PriorHotkey == "*~RCtrl") {
;        IME_SET(1)
;    }
;}
;#HotIf


; 右 Ctrl 空打ちで IME を ON
;#HotIf !WinActive("ahk_exe mstsc.exe")
;RCtrl:: {
;    RunWait IME_EXE " ON", , "Hide"
;}
;#HotIf

RCtrl::Send "{F24}"
F24:: {  
    RunWait IME_EXE " ON", , "Hide"
}

; Emacs がアクティブな時だけ有効（v2の書き方）
#HotIf WinActive("ahk_exe emacs.exe")

$^v:: {
    ; 物理的に "v" キーが押されているかチェック
    if (A_TimeIdlePhysical > 20) {
    ; if !GetKeyState("v", "P") {
        ; 物理的に押されていない ＝ Aqua Voice 等からの送信とみなす
        Send("{Ctrl Up}") 
        Sleep(10) ; 10ミリ秒だけ待機してEmacsに「離れた」ことを認識させる
        Send("^y")        ;return
    } else {
        Send("^v")
    }
}
#HotIf ; 条件をリセット

; ==============================================================================
; Neovim（GUIやWindows Terminal）がアクティブなときだけ有効
; ==============================================================================
; 「InStr」を使って、ウィンドウタイトルの中に「- Nvim」が含まれているかを強制判定します
#HotIf WinActive("ahk_exe nvim-qt.exe") or (WinActive("A") and InStr(WinGetTitle("A"), "- Nvim")) or WinActive("ahk_exe emacs.exe") or (WinActive("A") and InStr(WinGetTitle("A"), "- Emacs"))

$Esc::
{
    Send("{Esc}")
    RunWait IME_EXE " OFF", , "Hide"
    Sleep(10)
    Send("{Esc}")
}

#HotIf ; 条件をリセット