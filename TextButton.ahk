#Requires AutoHotkey v2.0

/************************************************************************
 * @description Text-based button library for AutoHotkey v2 with hover
 *              and click effects, customizable colors, and safe timers.
 * @file TextButton.ahk
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

; ==============================================================
; EXAMPLE USAGE START
; ==============================================================

; This is just an example usage.

; Example GUI
exampleGui := Gui("", "TextButton.ahk Example")
exampleGui.BackColor := "2b2b2b"

guiWidth := 300
guiHeight := 200
btnWidth := 120
left := (guiWidth - btnWidth)//2

CreateTextButton(exampleGui, "Default", left, 20, btnWidth, 35, (*) => MsgBox("Default clicked!"))
CreateTextButton(exampleGui, "Blue", left, 65, btnWidth, 35, (*) => MsgBox("Blue clicked!"),
    "2b3d5f", "355a8a", "3c6cb2", "1c2940")
CreateTextButton(exampleGui, "Green", left, 110, btnWidth, 35, (*) => MsgBox("Green clicked!"),
    "2f5f3c", "3c8a55", "46b26a", "1e3524")
CreateTextButton(exampleGui, "Exit", left, 155, btnWidth, 35, (*) => exampleGui.Destroy(),
    "5f2b2b", "8a3535", "b23c3c", "401c1c")

exampleGui.Show("w" guiWidth " h" guiHeight " Center")
