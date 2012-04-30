;usage 
;press windows key and desktop # to jump to a desktop
;press windows key and click mouse button for a menu of desktops to move a window to
;==============================================================================================
;Desktop Manager
#SingleInstance, Force
SetWinDelay, 0
SetBatchLines -1
OnExit RestoreAllWindows

DTM_NumberOfDesktops = 9
DTM_LastDesktop = 1
DTM_CurrentDesktop = 1

Loop % DTM_NumberOfDesktops > 9 ? 9 : DTM_NumberOfDesktops
	HotKey, #%A_Index%, HotkeyShowDesktop
	
;== move windows to new desktop
Menu, Desktops, Add,Move To Desktop,null
Menu, Desktops, Add
Loop, %DTM_NumberOfDesktops% 
	Menu, Desktops, Add, %A_Index%, MoveWindow
;== / move windows to new desktop

DTM_GetCurrentWindows()
Return

#MButton::
MouseGetPos,,,Window
Menu, Desktops, Show
Return

null:
return

MoveWindow:
MoveWindowToDesktop(Window,A_ThisMenuItem)
Return

MoveWindowToDesktop(hWnd,DesktopID){
	global 
	WinHideGrp := DllCall("BeginDeferWindowPos", "Uint", a) ; Non-Tiled Windows
	DTM_Desktop%DesktopID% := DllCall("DeferWindowPos", "Uint", DTM_Desktop%DesktopID%, "Uint", hWnd
	, "Uint", 1, "int", _, "int", _, "int", _, "int", _, "Uint", ShowFlags := SWP_SHOWWINDOW := 0x40|SWP_NOSIZE := 0x1|SWP_NOMOVE := 0x2)
	WinHideGrp := DllCall("DeferWindowPos", "Uint", WinHideGrp, "Uint", hWnd
		, "Uint", 1, "int", _, "int", _, "int", _, "int", _
		, "Uint", SWP_HIDEWINDOW := 0x80|SWP_NOACTIVATE := 0x10|SWP_NOSIZE := 0x1|SWP_NOMOVE := 0x2)
	DllCall("EndDeferWindowPos", "Uint", WinHideGrp)
}
;**********************************************************************************

HotkeyShowDesktop:
Critical
StringRight, Desktop, A_ThisHotkey, 1
If (Desktop = DTM_CurrentDesktop)
	Return
ShowDesktop(Desktop)
Return

;change this to the desktop #
;this label will run the first time the desktop is shown
Desktop2:
Run ::{450d8fba-ad25-11d0-98a8-0800361b1103} ; Open My Documents
Run ::{20d04fe0-3aea-1069-a2d8-08002b30309d} ; Open My Computer
return

;change this to the desktop #
;this label will run every time the desktop is shown
OnDesktop2:
ToolTip, Desktop %DTM_CurrentDesktop%
SetTimer, DTM_KillToolTip, -1000
return

DTM_KillToolTip:
ToolTip
return


RestoreAllWindows:
Critical
Gui +LastFound +ToolWindow -Caption +AlwaysOnTop
Gui, Color, White
WinSet, TransColor, White
Gui, Font, s48 bold
Gui, Add, Text, cLime, Restoring All Windows...
Gui, Show
Loop, %DTM_NumberOfDesktops% 
	DllCall("EndDeferWindowPos", "Uint", DTM_Desktop%A_Index%)
Sleep, 500
Gui Destroy
Send {LWin Up}
ExitApp


;**************************************************************************
;Author:	NKRUZAN
;Language:	AutoHotkey v1.0.47.04
;Creation Date:	02/14/2008	11:39
;Function Name:	ShowDesktop()
;
;Syntax:
;	ShowDesktop(DesktopID)
;Parameters:
;1)	DesktopID	= 	
;Return:
;	Success = 
;	Failure = 
;**************************************************************************
ShowDesktop(DesktopID) {
	Global 
	Critical
	HideDesktop(DTM_CurrentDesktop)
	DTM_LastDesktop := DTM_CurrentDesktop
	DTM_CurrentDesktop := DesktopID
	Clipboard := DTM_Clipboard%DesktopID% 
	DTM_CurrentDesktop := DesktopID
	DllCall("EndDeferWindowPos", "Uint", DTM_Desktop%DesktopID%)
	Gui +LastFound +ToolWindow -Caption +AlwaysOnTop
	Gui, Color, White
	WinSet, TransColor, White
	;WinSet, Trans, 150
	Gui, Font, s48 
	Gui, Add, Text, cLime w600 Center, Desktop:
	Gui, Font, s96 bold
	Gui, Add, Text, cLime w600 Center, %DesktopID%
	Gui, Show
	Sleep, 500
	Gui Destroy
	; mod to run label on each window switch
	if !(DTM_Desktop%DesktopID%HasBeenShown)
		if IsLabel("Desktop" . DesktopID)
			Gosub Desktop%DesktopID%
	DTM_Desktop%DesktopID%HasBeenShown := true
	if IsLabel("OnDesktop" . DesktopID)
		Gosub OnDesktop%DesktopID%
	}


;**************************************************************************
;Author:	NKRUZAN
;Language:	AutoHotkey v1.0.47.04
;Creation Date:	02/14/2008	11:39
;Function Name:	HideDesktop()
;
;Syntax:
;	HideDesktop(DesktopID)
;Parameters:
;1)	DesktopID	= 	
;Return:
;	Success = 
;	Failure = 
;**************************************************************************
HideDesktop(DesktopID) {
	Global 
	Critical
	DTM_GetCurrentWindows(DTM_Desktop%DesktopID%, HideGroup)
	DTM_Clipboard%DesktopID% := ClipboardAll
	DllCall("EndDeferWindowPos", "Uint", HideGroup)
	}


;**************************************************************************
;Author:	NKRUZAN
;Language:	AutoHotkey v1.0.47.04
;Creation Date:	02/14/2008	11:38
;Function Name:	DTM_GetCurrentWindows()
;
;Syntax:
;	DTM_GetCurrentWindows(ByRef ShowGroup=0, ByRef HideGroup=0)
;Parameters:
;1)	ByRef ShowGroup=0	= 	
;2)	ByRef HideGroup=0	= 	
;Return:
;	Success = 
;	Failure = 
;**************************************************************************
DTM_GetCurrentWindows(ByRef ShowGroup=0, ByRef HideGroup=0) {
 Static SelfPID
 Critical
	
	If !SelfPID {
		Process, Exist
		SelfPID := ErrorLevel
		}
	T := A_DetectHiddenWindows
	DetectHiddenWindows, Off
	WinGet, a, List
	ShowGroup := DllCall("BeginDeferWindowPos", "Uint", a) ; Non-Tiled Windows
	HideGroup := DllCall("BeginDeferWindowPos", "Uint", a) ; Non-Tiled Windows
	WinGet, ActWindow, ID, A
	ExemptWindows := "TPickSessionDlg,TForm,TFormMain,TBaseLoadErrorDlg,Shell_TrayWnd,DV2ControlHost,ZORRO"
	ExemptWindows .= ",Progman,tooltips_class32,AutoHotkeyGUI,TForm4,AutoHotkeyGUI,TfrmDUGraph,TNMGraph,SysShadow"
	Loop % a {
		WinGetClass, WinClass, % "ahk_id " . a%A_Index%
		WinGet, WinPID, PID, % "ahk_id " . a%A_Index%
		If WinClass in %ExemptWindows%
        	Continue
		If WinPID = %SelfPID% 
			Continue
		ShowFlags := SWP_SHOWWINDOW := 0x40|SWP_NOSIZE := 0x1|SWP_NOMOVE := 0x2
		ShowGroup := DllCall("DeferWindowPos", "Uint", ShowGroup, "Uint", a%A_Index%
		, "Uint", 1, "int", _, "int", _, "int", _, "int", _, "Uint", ShowFlags)
		HideGroup := DllCall("DeferWindowPos", "Uint", HideGroup, "Uint", a%A_Index%
		, "Uint", 1, "int", _, "int", _, "int", _, "int", _
		, "Uint", SWP_HIDEWINDOW := 0x80|SWP_NOACTIVATE := 0x10|SWP_NOSIZE := 0x1|SWP_NOMOVE := 0x2)
		}
	DetectHiddenWindows, %T%
   }
