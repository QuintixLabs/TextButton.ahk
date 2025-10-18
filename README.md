# 🔘 \\\\ TextButton.ahk
A simple text button library for **AutoHotkey v2**


## Showcase

<img src="https://github.com/user-attachments/assets/94a6a43c-6154-4056-9106-ecac8a8b274a" width="800">

## Usage

1. Download `TextButton.ahk`, place it in your project folder, include it in your script with `#Include TextButton.ahk`, and remove the example GUI from the library.  
2. Or just copy this code into your script:

<details>
<summary>Click to expand the full library code</summary>

```ahk
/************************************************************************
 * @description Text-based button library for AutoHotkey v2 with hover
 *              and click effects, customizable colors, and safe timers.
 * @file TextButtonLibrary.ahk
 * @link https://github.com/QuintixLabs/TextButton.ahk
 * @author QuintixLabs / fr0st
 * @date 10/18/2025
 * @version 1.0
 ***********************************************************************/

; ==============================================================
; BUTTON LIBRARY START
; Copy everything down to ButtonWndProc to use the library.
; ==============================================================

; Default Button
CreateTextButton(parentGui, text, x, y, w, h, callback, colorBase := "363636", colorHover := "4a4a4a", colorClick := "666666", borderColor := "555555") {
    border := parentGui.Add("Text", "x" x " y" y " w" w " h" h " Background" borderColor)
    btn := parentGui.Add("Text", "x" (x+1) " y" (y+1) " w" (w-2) " h" (h-2) " Background" colorBase " Center 0x200", text)
    btn.SetFont("s10 cFFFFFF", "Segoe UI")
    
    btn._callback := callback
    btn._border := border
    btn._origText := text
    btn._isHovered := false
    btn._clicking := false
    btn._colors := Map("base", colorBase, "hover", colorHover, "click", colorClick, "border", borderColor)
    
    btn.OnEvent("Click", (*) => HandleButtonClick(btn))
    DllCall("SetWindowSubclass", "Ptr", btn.Hwnd, "Ptr", CallbackCreate(ButtonWndProc), "Ptr", btn.Hwnd, "Ptr", ObjPtr(btn))
    
    return btn
}

HandleButtonClick(btn) {
    if (btn._clicking)
        return
    btn._clicking := true
    
    try btn.Opt("Background" btn._colors["click"]), btn.Redraw()
    try btn._callback.Call()
    
    SetTimer(() => SafeRestore(btn), -100)
}

SafeRestore(btn) {
    try {
        if (btn && btn.HasMethod("Opt")) {
            btn._clicking := false
            btn.Opt("Background" (btn._isHovered ? btn._colors["hover"] : btn._colors["base"]))
            btn.Redraw()
        }
    } catch {
        ; ignore if destroyed
    }
}

ButtonWndProc(hWnd, uMsg, wParam, lParam, uIdSubclass, dwRefData) {
    static WM_MOUSEMOVE := 0x200
    static WM_MOUSELEAVE := 0x2A3
    static TME_LEAVE := 0x00000002
    
    btn := ObjFromPtrAddRef(dwRefData)
    if !IsObject(btn)
        return DllCall("DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
    
    switch uMsg {
        case WM_MOUSEMOVE:
            if (!btn._isHovered) {
                btn._isHovered := true
                btn.Opt("Background" btn._colors["hover"])
                btn.Redraw()
                
                tme := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
                NumPut("UInt", tme.Size, tme, 0)
                NumPut("UInt", TME_LEAVE, tme, 4)
                NumPut("Ptr", hWnd, tme, 8)
                NumPut("UInt", 0, tme, 8 + A_PtrSize)
                DllCall("TrackMouseEvent", "Ptr", tme)
            }
        
        case WM_MOUSELEAVE:
            if (btn._isHovered) {
                btn._isHovered := false
                btn.Opt("Background" btn._colors["base"])
                btn._border.Opt("Background" btn._colors["border"])
                btn.Redraw(), btn._border.Redraw()
            }
    }
    
    return DllCall("DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam, "Ptr")
}
```

</details>


3. If you want to create your own buttons, check how its done in the example GUI section of the library:
- [TextButton.ahk Example (lines 96–119)](https://github.com/QuintixLabs/TextButton.ahk/blob/master/TextButton.ahk#L96C1-L119C55)



