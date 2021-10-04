#persistent
#SingleInstance, Force
SetWinDelay -1

Global guiwidth := 40
GLobal guiheight := 40
Global Tickrate := 50
Global Positions := {}
Global Dir := ""
Global Trails := 0
Global ApplePos
Global BadSpaces := {}
Global MaxWidth
Global MaxHeight

gui, Menu:Add, Text,, Snake/Apple Width/Height (Multiples of 10):
gui, Menu:Add, Text,, TickRate:
gui, Menu:Add, Button, gPlay, Play
gui, Menu:Add, Edit, ym vMenuGuiWidth, %guiwidth%
gui, Menu:Add, Edit, vMenuTickRate, %TickRate%
gui, Menu:Show
return

Play:
Gui, Menu:Submit
Gui, Menu:Destroy
guiwidth := MenuGuiWidth
guiheight := MenuGuiWidth
TickRate := MenuTickRate
MaxWidth := Floor((A_ScreenWidth / guiwidth) - 1)
MaxHeight := Floor((A_ScreenHeight / guiheight) - 1)
Positions := {"1x": guiwidth, "1y": guiheight}

Gui, Apple:New, -Border -MinimizeBox -SysMenu -Caption -MaximizeBox -Resize +AlwaysOnTop
Gui, Apple:Color, Red
Gui, Apple:Show, w%guiwidth% h%guiheight%, SGUIApple

GuiMaker(1,0)
AppleMaker()

SetTimer, Movement, % Tickrate
SetTimer, Movement, Off
return

Up::
Down::
Left::
Right::
If (A_ThisHotkey = "Up" && Dir == "Down") || (A_ThisHotkey = "Left" && Dir == "Right") || (A_ThisHotkey = "Right" && Dir == "Left") || (A_ThisHotkey = "Down" && Dir == "Up")
    return
SetTimer, Movement, On
Dir := A_ThisHotkey
return

F1::
Pause, Toggle

NumpadAdd::
GuiMaker(Trails + 1,1)
return

Movement:
GuiMover()
return

GuiMaker(Num, Follow) {
    If !Follow {
        Gui, %Num%:New, +hwndguiId -Border -MinimizeBox -SysMenu -Caption -MaximizeBox -Resize
        Gui, %Num%:Add, Text
        Gui, %Num%:Show, % "W" . guiwidth . "H" . guiheight . "X" . Positions[Num . "x"] . " Y" . Positions[Num . "y"]
    } else {
        Gui, %Num%:New, +hwndguiId -Border -MinimizeBox -SysMenu -Caption -MaximizeBox -Resize
        Gui, %Num%:Add, Text
        Gui, %Num%:Show, % "W" . guiwidth . "H" . guiheight . "X" . Positions[Num - 1 . "x"] . " Y" . Positions[Num - 1 . "y"]
    }
    Trails++
    Tickrate--
    SetTimer, Movement, % Tickrate
    Dwm_SetWindowAttributeTransistionDisable(guiId,1)
    Positions[Num . "N"] := guiId
}

GuiMover() {
    Loop, %Trails% {
        NumX := A_Index . "X"
        NumY := A_Index . "Y"
        If (A_Index = 1) {
            PrevX := Positions[NumX]
            PrevY := Positions[NumY]
            Gui, %A_Index%:Show, % "X" . Positions[A_Index . "x"] + ((Dir = "Right") ? guiwidth : ((Dir = "Left") ? -guiwidth : 0)) . " Y" . Positions[A_Index . "y"] + ((Dir = "Down") ? guiheight : ((Dir = "Up") ? -guiheight : 0)) NA
            If (ApplePos = Positions[NumX] . Positions[NumY]) {
                GuiMaker(Trails + 1,1)
                AppleMaker()
            }
            If ((Positions[NumX] < 0) || (Positions[NumY] < 0) || (Positions[NumX] > A_ScreenWidth) || (Positions[NumY] > A_ScreenHeight) || InStr(BadSpaces, " " . Positions[NumX] . Positions[NumY]) != 0) {
                MsgBox, Game Over
                ExitApp
            }
            for key, value in BadSpaces {
                If (Positions[NumX] . Positions[NumY] == value) {
                    MsgBox, Game Over
                    ExitApp
                }
            }
            BadSpaces[A_Index] := Positions[NumX] . Positions[NumY]
            Positions[NumX] := Positions[A_Index . "x"] + ((Dir = "Right") ? guiwidth : ((Dir = "Left") ? -guiwidth : 0))
            Positions[NumY] := Positions[A_Index . "y"] + ((Dir = "Down") ? guiheight : ((Dir = "Up") ? -guiheight : 0))
        } else {
            TempX := Positions[NumX]
            TempY := Positions[NumY]
            WinMove, % "ahk_id " . Positions[A_Index . "N"] ,, PrevX, PrevY
            BadSpaces[A_Index] := PrevX . PrevY
            Positions[NumX] := PrevX
            Positions[NumY] := PrevY
            PrevX := TempX
            PrevY := TempY
        }            
    }
}

AppleMaker() {
    Random, xRand, 1, %MaxWidth%
    Random, yRand, 1, %MaxHeight%
    x := guiwidth * xRand
    y := guiheight * yRand 
    WinMove, SGUIApple,, %x%, %y%
    ApplePos := x . y
}

Dwm_SetWindowAttributeTransistionDisable(hwnd,onOff)
{
	;
	;	DWMWA_TRANSITIONS_FORCEDISABLED=3
	;	Use with DwmSetWindowAttribute. Enables or forcibly disables DWM transitions.
	;	The pvAttribute parameter points to a value of TRUE to disable transitions or FALSE to enable transitions.
	;
	dwAttribute:=3
	cbAttribute:=4
	VarSetCapacity(pvAttribute,4,0)
	NumPut(onOff,pvAttribute,0,"Int")
	hr:=DllCall("Dwmapi.dll\DwmSetWindowAttribute", "Uint", hwnd, "Uint", dwAttribute, "Uint", &pvAttribute, "Uint", cbAttribute)
	return hr
}
