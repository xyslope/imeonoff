// Windows IME ON/OFF 制御ツール
// - ON: 変換キー (VK_CONVERT) を SendInput
// - OFF: 無変換キー (VK_NONCONVERT) を SendInput
// - Status: SendMessageTimeoutW + WM_IME_CONTROL で状態取得
// - Toggle: Status に基づいて ON/OFF 切り替え

#![windows_subsystem = "windows"]

use std::ffi::c_void;
use std::process;
use windows::Win32::UI::Input::KeyboardAndMouse::{
    SendInput, INPUT, INPUT_0, INPUT_KEYBOARD, KEYBDINPUT, KEYBD_EVENT_FLAGS,
    KEYEVENTF_KEYUP, VK_CONVERT, VK_NONCONVERT, VIRTUAL_KEY,
};

const WM_IME_CONTROL: u32 = 0x0283;
const IME_GETOPENSTATUS: usize = 0x0005;
const SMTO_ABORTIFHUNG: u32 = 0x0002;

#[link(name = "user32")]
extern "system" {
    fn GetForegroundWindow() -> *mut c_void;
    fn SendMessageTimeoutW(
        hwnd: *mut c_void,
        msg: u32,
        wparam: usize,
        lparam: isize,
        flags: u32,
        timeout: u32,
        result: *mut usize,
    ) -> *mut c_void;
}

#[link(name = "imm32")]
extern "system" {
    fn ImmGetDefaultIMEWnd(hwnd: *mut c_void) -> *mut c_void;
}

fn send_vk(vk: VIRTUAL_KEY) {
    unsafe {
        let mut input = INPUT {
            r#type: INPUT_KEYBOARD,
            Anonymous: INPUT_0 {
                ki: KEYBDINPUT {
                    wVk: vk,
                    dwFlags: KEYBD_EVENT_FLAGS(0),
                    ..Default::default()
                },
            },
        };
        SendInput(&[input], std::mem::size_of::<INPUT>() as i32);

        input.Anonymous.ki.dwFlags = KEYEVENTF_KEYUP;
        SendInput(&[input], std::mem::size_of::<INPUT>() as i32);
    }
}

fn get_ime_status() -> Result<bool, String> {
    unsafe {
        let hwnd = GetForegroundWindow();
        if hwnd.is_null() {
            return Err("no foreground window".to_string());
        }
        // IMEv2.ahk 方式: ImmGetDefaultIMEWnd で IME デフォルトウィンドウを取得
        let ime_hwnd = ImmGetDefaultIMEWnd(hwnd);
        if ime_hwnd.is_null() {
            return Err("no default IME window".to_string());
        }
        let mut result: usize = 0;
        let ret = SendMessageTimeoutW(
            ime_hwnd,
            WM_IME_CONTROL,
            IME_GETOPENSTATUS,
            0,
            SMTO_ABORTIFHUNG,
            100,
            &mut result,
        );
        if ret.is_null() {
            return Err("SendMessageTimeout failed".to_string());
        }
        Ok(result != 0)
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: imeonoff.exe <ON | OFF | Toggle | Status>");
        process::exit(1);
    }

    match args[1].to_lowercase().as_str() {
        "on" => send_vk(VK_CONVERT),
        "off" => send_vk(VK_NONCONVERT),
        "toggle" => match get_ime_status() {
            Ok(true) => send_vk(VK_NONCONVERT),
            _ => send_vk(VK_CONVERT),
        },
        "status" => match get_ime_status() {
            Ok(true) => process::exit(0),
            Ok(false) => process::exit(1),
            Err(_) => process::exit(2),
        },
        _ => {
            eprintln!(
                "Unknown command: {}. Use ON, OFF, Toggle, or Status.",
                args[1]
            );
            process::exit(1);
        }
    }
}
