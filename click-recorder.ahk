/**
  * click-recorder.ahk
  * Mouse click recorder and turbo click script for AutoHotkey
  */

toggleRecord := false
togglePlayback := false
CoordMode Mouse, Screen

Gui recToolTip: New, +AlwaysOnTop +ToolWindow -Caption, recToolTip
Gui recToolTip: Margin, 10, 5
Gui recToolTip: Color, 0F0F0F
Gui recToolTip: Font, q5 s20 cCC0000 Bold
Gui recToolTip: Add, Text,, Recording

return

;#region subroutines

recToolTip_Pulse:
  tick := Mod(tick + 21, 40) - 20
  alpha := Sin(tick * 0.15708) * 100 + 128
  WinSet Transparent, %alpha%, recToolTip
  return

recordClick:
  if(toggleRecord) {
    MouseGetPos x, y
    idx := clicks.MaxIndex()
    last := clicks[idx]
    if(last.x == x && last.y == y) {
      last.n++
    } else {
      clicks.Push({x: x, y: y, n: 1})
    }
  }
  return

;#endregion

;#region hotkeys

#MaxThreadsPerHotkey 2

/**
  * Record macro
  * use Mouse Forward button or Ctrl+1 to toggle
  */
XButton2::
^1::
  togglePlayback := false
  toggleRecord := !toggleRecord
  if(toggleRecord) {
    tick := 0
    clicks := []
    SetTimer recToolTip_Pulse, 25
    Gui recToolTip: Show, NA xCenter y100
  } else {
    Gui recToolTip: Hide
    SetTimer recToolTip_Pulse, Off
  }
  return

/**
  * Playback macro
  * use Mouse Back button or Ctrl+2 to toggle
  */
XButton1::
^2::
  toggleRecord := false
  togglePlayback := !togglePlayback
  Gui recToolTip: Hide
  SetTimer recToolTip_Pulse, Off
  if(clicks.Count()) {
    while(togglePlayback) {
      for _, coords in clicks {
        if(!togglePlayback)
          break
        x := coords.x
        y := coords.y
        n := coords.n
        Click %x%, %y%, %n%
      }
    }
  }
  return

#MaxThreadsPerHotkey 1

/**
  * Click continuously while left mouse is held, 20/s
  */
~$LButton::
  Gosub recordClick
  ; delay first repeated click slightly longer to avoid unintentional double click
  KeyWait LButton, T0.15
  while(ErrorLevel && GetKeyState("LButton", "P")) {
    Click
    Gosub recordClick
    KeyWait LButton, T0.05
  }
  return

/**
  * Pause button suspends hotkeys
  */
Pause::
  Suspend
  toggleRecord := false
  togglePlayback := false
  Gui recToolTip: Hide
  SetTimer recToolTip_Pulse, Off
  return

;#endregion
