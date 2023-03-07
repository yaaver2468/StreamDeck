#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
#KeyHistory, 0
SetBatchLines, -1
Menu, Tray, NoStandard
Menu, Tray, Add, Open Deck, openProgram
Menu, Tray, Add, Restart Deck, resetProgram
Menu, Tray, Add, Version, showVersion
Menu, Tray, Add, Exit, GuiClose
Menu, Tray, Default, Open Deck

if (!FileExist("default")) {
	UrlDownloadToFile, https://i.imgur.com/AAvQbOt.jpg, default.jpg
}
IniRead, deckTitle, settings.ini, main, title
if (deckTitle == "ERROR") {
	deckTitle = Yaaver Imran Stream Deck
	IniWrite, %deckTitle%, settings.ini, main, title
}
IniRead, bgColour, settings.ini, main, color
if (bgColour == "ERROR") {
	bgColour = 0x000000
	IniWrite, %bgColour%, settings.ini, main, color
}
IniRead, buttonRows, settings.ini, main, buttonRows, 3
IniRead, buttonColumns, settings.ini, main, buttonColumns, 5
IniWrite, %buttonRows%, settings.ini, main, buttonRows
IniWrite, %buttonColumns%, settings.ini, main, buttonColumns

bTotal := buttonRows * buttonColumns
Loop, %bTotal% {
	IniRead, kb%A_Index%, settings.ini, action, kb%A_Index%
	IniRead, bn%A_Index%, settings.ini, images, bn%A_Index%
}
IniRead, X, settings.ini, main, windowX
IniRead, Y, settings.ini, main, windowY

picX := 37
picY := 37
picNum := 1
buttonLocations := []
bx1 := 37
bx2 := 112
by1 := 37
by2 := 112

Gui -DPIScale
winWidth := (102 * buttonColumns - (37 * (buttonColumns - 5) / 3))
winHeight := (110 * buttonRows - (37 * (buttonRows - 3) / 2))
if (X != "ERROR" and Y != "ERROR") {
	Gui, Show, x%X% y%Y% w%winWidth% h%winHeight% NoActivate, %deckTitle%
}
else {
	Gui, Show, w%winWidth% h%winHeight% NoActivate, %deckTitle%
}
Gui, Color, %bgColour%

Loop, %buttonRows% {
	Loop, %buttonColumns% {
		temp := [bx1, bx2, by1, by2]
		buttonLocations.Push(temp)
		if (bn%picNum% != "ERROR") {
			picLocation := bn%picNum%
			Gui, Add, Picture, x%picX% y%picY% w76 h76 BackgroundTrans, %picLocation%
		}
		else {
			Gui, Add, Picture, x%picX% y%picY% w76 h76 BackgroundTrans, default.jpg
		}
		picX += 90
		picNum += 1
		bx1 += 90
		bx2 += 90
	}
	bx1 := 37
	bx2 := 112
	by1 += 90
	by2 += 90
	picX := 37
	picY += 90
}
;Gui, Add, Picture, x0 y0 w510 h330 BackgroundTrans, background.png
IniRead, fontColor, settings.ini, main, fontColor, cWhite
Gui, Font, %fontColor%
Gui, Add, Checkbox, x37 y12 gToggleTop vOnTop, Always On Top
Gui, Add, Hotkey, x37 w200 vChosenKey, %keyInput%
Gui, Add, Button, x37 w200 h20 vConfirmButton gConfirmHotkey +Default, Confirm

centerTimeX := winWidth / 2 - 59
centerTimeY := winHeight - 25
Gui, Add, Text, x%centerTimeX% y%centerTimeY% w128 vSystemTime

GuiControl, Hide, ConfirmButton
GuiControl, Hide, ChosenKey

Gui, Minimize
Gui, Restore

Gui, 2:New, +Border +LastFound +AlwaysOnTop -Caption +ToolWindow, Media Setter
Gui, 2:Add, DropDownList, vMediaChoice, Play/Pause||Next|Previous|Volume Up|Volume Down|Volume Mute
Gui, 2:Add, Button, +Default vConfirmMButton gConfirmMedia, Confirm
Gui, 2:Hide

Gui, 3:New, +AlwaysOnTop -Caption, Bind Button
Gui, 3:Add, Text,, What action do you want for this button?
Gui, 3:Add, Button, x10 y30 gRB1, Twitch
Gui, 3:Add, Button, x60 y30 gRB2, Hotkey
Gui, 3:Add, Button, x112 y30 gRB3, Open
Gui, 3:Add, Button, x156 y30 gRB4, Media Control
Gui, 3:Add, Button, x239 y30 gRB5, Play
Gui, 3:Add, Button, x277 y30 gRB6, Multi-Action

Gui, 4:New,, Multi-Action
Gui, 4:Add, Checkbox, x11 w350 vMultiTwitch, Twitch
Gui, 4:Add, Edit, w350 vMTInput
Gui, 4:Add, Checkbox, w350 vMultiHotkey, Hotkey
Gui, 4:Add, Hotkey, w350 vMHInput
Gui, 4:Add, Checkbox, vMultiOpenP, Open Program
Gui, 4:Add, Checkbox, x187 y98 vMultiOpenW, Open Site
Gui, 4:Add, Edit, x11 w126 ReadOnly vMOInput1
Gui, 4:Add, Button, x137 y116 w50 gMOLoad, Load
Gui, 4:Add, Edit, x187 y117 w174 vMOInput2, www.google.com
Gui, 4:Add, Checkbox, x11 w350 vMultiMedia, Media Control
Gui, 4:Add, DropDownList, w350 vMMInput, Play/Pause||Next|Previous|Volume Up|Volume Down|Volume Mute
Gui, 4:Add, Checkbox, w350 vMultiPlay, Play
Gui, 4:Add, Edit, w300 ReadOnly vMPInput
Gui, 4:Add, Button, x311 y209 w50 gMPInput, Load
Gui, 4:Add, Button, x11 w351 gConfirmMulti +Default, Confirm

deckVersion := "1.7"
lastButton := 1
reBind := ""

OnMessage(0x201, "LBUTTONDOWN")
OnMessage(0x205, "RBUTTONUP")
OnMessage(0x03, "WMOVE")
UpdateCheck()

SetTimer, UpdateClocks, 400

Return

UpdateClocks:
	FormatTime, sysTime, , hh:mm:ss tt
	sysLoad := "- CPU: " + CPULoad()
	GuiControl,, SystemTime, %sysTime% %sysLoad%`%
Return

2GuiEscape:
	Gui, Hide
Return

3GuiEscape:
	Gui, Hide
Return

4GuiEscape:
	Gui, Hide
Return

GuiClose:
ExitApp

openProgram:
	Gui, Show
Return

resetProgram:
	Reload
Return

showVersion:
	MsgBox, 0, %deckTitle%, Current version: %deckVersion%`nLast Updated: 6/6/2019
Return

ToggleTop:
	GuiControlGet, OnTop
	if (OnTop or winPriority) {
		Gui +AlwaysOnTop
	}
	else {
		Gui -AlwaysOnTop
	}
Return

RB1:
	reBind := "twitch"
	Gui, 3:Hide
Return
RB2:
	reBind := "hotkey"
	Gui, 3:Hide
Return
RB3:
	reBind := "open"
	Gui, 3:Hide
Return
RB4:
	reBind := "media"
	Gui, 3:Hide
Return
RB5:
	reBind := "play"
	Gui, 3:Hide
Return
RB6:
	reBind := "multi"
	Gui, 3:Hide
Return

ConfirmHotkey:
	global winHeight
	GuiControlGet, ChosenKey
	if (ChosenKey != "") {
		AssignKey(ChosenKey, "h")
		IniWrite, h%ChosenKey%, settings.ini, action, kb%lastButton%
	}
	GuiControl, Hide, ConfirmButton
	GuiControl, Hide, ChosenKey
	Gui, Show, h%winHeight%
Return

ConfirmMulti:
	global deckTitle
	Gui, 4:Submit
	superKey := ""
	if (MultiTwitch) {
		GuiControlGet, MTInput
		if (MTInput != "") {
			superKey = %superKey%|t%MTInput%
		}
		else {
			MsgBox, 16, %deckTitle%, Invalid Twitch Input
		}
	}
	if (MultiHotkey) {
		GuiControlGet, MHInput
		if (MHInput != "") {
			superKey = %superKey%|h%MHInput%
		}
		else {
			MsgBox, 16, %deckTitle%, Invalid Hotkey Input
		}
	}
	if (MultiOpenP) {
		GuiControlGet, MOInput1
		if (MOInput1 != "") {
			superKey = %superKey%|o%MOInput1%
		}
		else {
			MsgBox, 16, %deckTitle%, Invalid Program Input
		}
	}
	if (MultiOpenW) {
		GuiControlGet, MOInput2
		if (MOInput2 != "") {
			superKey = %superKey%|o%MOInput2%
		}
		else {
			MsgBox, 16, %deckTitle%, Invalid Website Input
		}
	}
	if (MultiMedia) {
		GuiControlGet, MMInput
		superKey = %superKey%|m%MMInput%
	}
	if (MultiPlay) {
		GuiControlGet, MPInput
		if (MPInput != "") {
			superKey = %superKey%|p%MPInput%
		}
		else {
			MsgBox, 16, %deckTitle%, Invalid Play Input
		}
	}
	if (superKey != "") {
		AssignKey(superKey, "s")
		IniWrite, s%superKey%, settings.ini, action, kb%lastButton%
	}
Return

MOLoad:
	FileSelectFile, selectFile, 1
	if (selectFile) {
		GuiControl,, MOInput1, %selectFile%
	}
Return

MPInput:
	FileSelectFile, selectFile, 1
	if (selectFile) {
		GuiControl,, MPInput, %selectFile%
	}
Return

ConfirmMedia:
	GuiControlGet, MediaChoice
	AssignKey(MediaChoice, "m")
	IniWrite, m%MediaChoice%, settings.ini, action, kb%lastButton%
	Gui, 2:Hide
Return

LBUTTONDOWN(wParam, lParam)
{
	global deckTitle, buttonLocations
    X := lParam & 0xFFFF
    Y := lParam >> 16
	WinGetTitle, currentWin, A
	if (currentWin == deckTitle) {
		for index, element in buttonLocations {
			if (Y >= element[3] and Y <= element[4]) {
				if (X >= element[1] and X <= element[2]) {
					KeyWait, LButton, T0.5
					if (ErrorLevel) {
						BindAction(index)
					}
					else {
						ButtonAction(index)
					}
					break
				}
			}
		}
	}
}

RBUTTONUP(wParam, lParam)
{
	global deckTitle, buttonLocations
    X := lParam & 0xFFFF
    Y := lParam >> 16
	WinGetTitle, currentWin, A
	if (currentWin == deckTitle) {
		for index, element in buttonLocations {
			if (Y >= element[3] and Y <= element[4]) {
				if (X >= element[1] and X <= element[2]) {
					BindImage(index)
					break
				}
			}
		}
	}
}

WMOVE(wParam, lParam)
{
	global deckTitle
    WinGetPos, X, Y, , , %deckTitle%
	WinGetTitle, currentWin, A
	if (currentWin == deckTitle) {
		IniWrite, %X%, settings.ini, main, windowX
		IniWrite, %Y%, settings.ini, main, windowY
	}
}

ToggleMain(undo := 0) {
	GuiControlGet, OnTop
	if (OnTop) {
		GuiControl,, OnTop, 0
		Gui, -AlwaysOnTop +Disabled
		Return 1
	}
	else if (undo) {
		GuiControl,, OnTop, 1
		Gui, +AlwaysOnTop -Disabled
	}
	Return 0
}

BindImage(pressed) {
	temp := ToggleMain()
	FileSelectFile, selectImage, 1
	if (selectImage) {
		IfInString selectImage, %A_WorkingDir%
		{
			selectImage := SubStr(selectImage, StrLen(A_WorkingDir) - StrLen(selectImage) + 2)
			IniWrite, %selectImage%, settings.ini, images, bn%pressed%
		}
		else {
			IniWrite, %selectImage%, settings.ini, images, bn%pressed%
		}
		Reload
	}
	ToggleMain(temp)
}

BindAction(pressed) {
	global lastButton := pressed
	global reBind
	global deckTitle
	WinGetTitle, deckName
	WinGetPos, X, Y, , , A
	X += 2
	Y += 23
	Gui, 3:Show, x%X% y%Y%
	WinWaitActive, Bind Button
	WinWaitNotActive, Bind Button
	Gui, 3:Hide
	X -= 2
	Y -= 23
	if (!ErrorLevel) {
		if (reBind == "twitch") {
			temp := ToggleMain()
			InputBox, reBind, %deckName%, What do you wish to send to chat?`ncommands`nmessage`n`nREQUIRES HexChat
			ToggleMain(temp)
			if (reBind != "") {
				AssignKey(reBind, "t")
				IniWrite, t%reBind%, settings.ini, action, kb%pressed%
			}
		}
		else if (reBind == "hotkey") {
			global winHeight
			X := winHeight + 20
			Gui, Show, h%X%
			GuiControl,, ChosenKey
			GuiControl, Show, ConfirmButton
			GuiControl, Show, ChosenKey
			GuiControl, Focus, ChosenKey
		}
		else if (reBind == "open") {
			temp := ToggleMain()
			InputBox, reBind, %deckName%, What do you wish run? Enter one of the following:`nprogram`nwebsite
			if (reBind == "website") {
				InputBox, reBind, %deckName%, Copy paste the website URL here:
				AssignKey(reBind, "o")
				IniWrite, o%reBind%, settings.ini, action, kb%pressed%
			}
			else if (reBind == "program") {
				FileSelectFile, selectFile, 1
				if (selectFile) {
					AssignKey(selectFile, "o")
					IfInString selectFile, %A_WorkingDir%
					{
						selectFile := SubStr(selectFile, StrLen(A_WorkingDir) - StrLen(selectFile) + 2)
						IniWrite, o%selectFile%, settings.ini, action, kb%pressed%
					}
					else {
						IniWrite, o%selectFile%, settings.ini, action, kb%pressed%
					}
				}
			}
			ToggleMain(temp)
		}
		else if (reBind == "media") {
			X += 2
			Y += 23
			Gui, 2:Show, x%X% y%Y%
			WinWaitActive, Media Setter
			WinWaitNotActive, Media Setter
			Gui, 2:Hide
		}
		else if (reBind == "play") {
			FileSelectFile, selectFile, 1
			if (selectFile) {
				AssignKey(selectFile, "p")
				IfInString selectFile, %A_WorkingDir%
				{
					selectFile := SubStr(selectFile, StrLen(A_WorkingDir) - StrLen(selectFile) + 2)
					IniWrite, p%selectFile%, settings.ini, action, kb%pressed%
				}
				else {
					IniWrite, p%selectFile%, settings.ini, action, kb%pressed%
				}
			}
		}
		else if (reBind == "multi") {
			temp := ToggleMain()
			Gui, 4:Show, x%X% y%Y%
			WinWaitActive, Multi-Action
			WinWaitNotActive, Multi-Action
			Gui, 4:Hide
			ToggleMain(temp)
		}
		reBind := ""
	}
}

AssignKey(buttonBinder, bindType) {
	global
	kb%lastButton% := bindType . buttonBinder
}

ButtonAction(pressed) {
	global lastButton
	lastButton := pressed
	ExtractAction(kb%pressed%)
}

ExtractAction(key) {
	global deckTitle
	global buttonTimer
	global lastButton
	keyModifier := SubStr(key, 1,1)
	key := SubStr(key, 2)
	if (keyModifier == "h") {
		HotKeySend(key)
	}
	else if (keyModifier == "t") {
		TwitchChat(key)
	}
	else if (keyModifier == "o") {
		Execute(key)
	}
	else if (keyModifier == "m") {
		Media(key)
	}
	else if (keyModifier == "p") {
		Play(key)
	}
	else if (keyModifier == "s") {
		ExtractSuper(key)
	}
	else {
		temp := ToggleMain()
		MsgBox, 16, %deckTitle%, Invalid Button
		ToggleMain(temp)
	}
}

ExtractSuper(key) {
	key := StrSplit(key, "|")
	Loop % key.MaxIndex()
	{
		if (key[A_Index] != "") {
			ExtractAction(key[A_Index])
		}
	}
}

Play(songFile) {
	global lastButton
	mciSendString("close deckSong")
    mciSendString("open " """" songFile """" " type mpegvideo Alias deckSong")
    mciSendString("play deckSong")
}

Media(mediaAction) {
	if (mediaAction == "Play/Pause") {
		Send {Media_Play_Pause}
	}
	else if (mediaAction == "Next") {
		Send {Media_Next}
	}
	else if (mediaAction == "Previous") {
		Send {Media_Prev}
	}
	else if (mediaAction == "Volume Up") {
		Send {Volume_Up}
	}
	else if (mediaAction == "Volume Down") {
		Send {Volume_Down}
	}
	else {
		Send {Volume_Mute}
	}
}

Execute(runAction) {
	global deckTitle
	try {
		Run, %runAction%
	} catch e {
		temp := ToggleMain()
		MsgBox, 16, %deckTitle%, Execution Failed
		ToggleMain(temp)
	}
}

HotKeySend(keySend) {
	strip := 0
	IfInString, keySend, #
	{
		Send {LWin Down}
		strip += 1
	}
	IfInString, keySend, ^
	{
		Send {Ctrl Down}
		strip += 1
	}
	IfInString, keySend, +
	{
		Send {Shift Down}
		strip += 1
	}
	IfInString, keySend, !
	{
		Send {Alt Down}
		strip += 1
	}
	StringTrimLeft, keySend, keySend, %strip%
	Sleep 25
	Send {%keySend% Down}
	Sleep 25
	Send {%keySend% Up}
	Sleep 25
	Send {Ctrl Up}
	Send {Shift Up}
	Send {Alt Up}
	Send {LWin Up}
}

TwitchChat(message) {
	global deckTitle
	if (IRCOpen()) {
		WinActivate, ahk_exe hexchat.exe
		WinWaitActive, ahk_exe hexchat.exe
		Send %message%
		Send {Enter}
	}
	else {
		temp := ToggleMain()
		MsgBox, 16, %deckTitle%, Missing HexChat
		ToggleMain(temp)
	}
	Gui, Show
}

UpdateCheck() {
	global deckVersion
	RegRead, ahkpath, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\AutoHotkey.exe
	if (ahkpath != "") {
		FileDelete, tempUp.bat
		FileDelete, temp.ahk
		ahkpath := SubStr(ahkpath, 1, -15)
		url := "https://pastebin.com/raw/NJCT6YxP"
		HttpRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		HttpRequest.Open("GET", url)
		HttpRequest.Send()
		newVersion := HttpRequest.ResponseText
		newCode := SubStr(newVersion, 6)
		newVersion := SubStr(newVersion, 1, 3)
		batCode := """" ahkpath "\Compiler\Ahk2Exe.exe"	"""" " /in " """" "temp.ahk" """"
		if (deckVersion != newVersion) {
			FileAppend, %newCode%, temp.ahk
			if (!FileExist("icon.ico")) {
				MsgBox % "Please use an icon if possible, name it to icon.ico."
			}
			else {
				batCode := batCode " /icon " """" "icon.ico" """"
			}
			batCode := batCode "`ntimeout 1`ndel " """" A_ScriptName """" "`nren temp.exe " """" A_ScriptName """" "`n" """" A_ScriptName """"
			FileAppend, %batCode%, tempUp.bat
			Run, tempUp.bat, , Hide
			ExitApp
		}
	}
	else {
		MsgBox, 16, %deckTitle%, Please install AHK to update the program
	}
}

mciSendString(Command) {
   Return, DllCall("winmm.dll\mciSendString", Str,Command, Str,"", Int,0, Int,0)
}

GetAudioDuration( mFile ) { ; SKAN [url] www.autohotkey.com/forum/viewtopic.php?p=361791#361791[url]
	global lastButton
	global buttonTimer
	VarSetCapacity( DN,16 ), DLLFunc := "winmm.dll\mciSendString" ( A_IsUnicode ? "W" : "A" )
	DllCall( DLLFunc, Str,"open " """" mFile """" " Alias MP3", UInt,0, UInt,0, UInt,0 )
	DllCall( DLLFunc, Str,"status MP3 length", Str,DN, UInt,16, UInt,0 )
	DllCall( DLLFunc, Str,"close MP3", UInt,0, UInt,0, UInt,0 )
	Return DN
}

CPULoad() { ; By SKAN, CD:22-Apr-2014 / MD:05-May-2014. Thanks to ejor, Codeproject: http://goo.gl/epYnkO
Static PIT, PKT, PUT                           ; http://ahkscript.org/boards/viewtopic.php?p=17166#p17166
  IfEqual, PIT,, Return 0, DllCall( "GetSystemTimes", "Int64P",PIT, "Int64P",PKT, "Int64P",PUT )

  DllCall( "GetSystemTimes", "Int64P",CIT, "Int64P",CKT, "Int64P",CUT )
, IdleTime := PIT - CIT,    KernelTime := PKT - CKT,    UserTime := PUT - CUT
, SystemTime := KernelTime + UserTime 

Return ( ( SystemTime - IdleTime ) * 100 ) // SystemTime,    PIT := CIT,    PKT := CKT,    PUT := CUT 
}

IRCOpen() {
	programStatus := false
	if (ProcessExist("hexchat.exe")) {
		programStatus := true
	}
	Return programStatus
}

ProcessExist(Name) {
	Process, Exist, %Name%
	Return Errorlevel
}