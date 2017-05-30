#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=Install-WilstatA.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GuiConstantsEx.au3>
#Include <File.au3>

;;;;;;;;;;;;;;;;;;;;Wilstat Agent Installer;;;;;;;;;;;;;;;;;;;;;;;;;;
;Author: Gerald Wiltse
;Email: jerrywiltse@gmail.com
;Release Date: 8/20/2008
;Version: 1.0
;
;Instructions: Run this program to install WilstatAgent.
; 				Wilstat Agent connect to a pool of servers.
;				It first checks to see if the username provided is
;				already logged on, and autoconnects if it is. 
;				It then counts users on each server and chooses
;				the least busy (based on user count. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$sWilstatVersion = 1.0
$sWilIniFile = @ProgramFilesDir & '\Wilstat Agent\wilstata.ini'
$sWilVerFile = @ProgramFilesDir & '\Wilstat Agent\wilstataversion.ini'
$sWilExeFile = @ProgramFilesDir & '\Wilstat Agent\wilstata.exe'
$sWilShortcut = @DesktopCommonDir & '\Wilstat Agent.lnk'

GUICreate("Wilstat Agent Installer", 210, 100)
$gDesktopShortcut = GUICtrlCreateCheckbox("Desktop Shortcut", 10, 5)
$gLaunchNow = GUICtrlCreateCheckbox("Launch Now", 10, 25)
$gOverwriteIni = GUICtrlCreateCheckbox("Overwrite INI file", 10, 45)
$gInstallButton = GUICtrlCreateButton("Install", 10, 70, 60)
$gCancelButton = GUICtrlCreateButton("Cancel", 80, 70, 60)
GUISetState(@SW_SHOW)

GuiCtrlSetState($gDesktopShortcut,$GUI_CHECKED)
GuiCtrlSetState($gLaunchNow,$GUI_CHECKED)
GuiCtrlSetState($gOverwriteIni,$GUI_CHECKED)

While 1
  $msg = GUIGetMsg()
  Select
    Case $msg = $GUI_EVENT_CLOSE
      	ExitLoop
	Case $msg = $gCancelButton
		ExitLoop
	Case $msg = $gInstallButton
		_InstallFiles()
		MsgBox(0, "Congratulations", "Wilstat Agent Was Installed Successfully!")
		ExitLoop
EndSelect
WEnd 

Func _InstallFiles()
	DirCreate(@ProgramFilesDir & '\Wilstat Agent')
	If Not FileExists($sWilVerFile) Then _FileCreate($sWilVerFile)
	IniWrite($sWilVerFile,"Version","CurrentVersion",$sWilstatVersion)
	FileInstall('Z:\Storage\scripts\JerryScripts\Wilstat\WilstatA.exe',$sWilExeFile,1)
	;	FileInstall('z:\storage\scripts\jerryscripts\targetfiles\Jerryscripts\Wilstat\WilstatA.exe',$sWilExeFile,1)
	
	If GuiCtrlRead($gDesktopShortcut) = 1 Then
	FileCreateShortcut($sWilExeFile,$sWilShortcut)
	EndIF 
	
	If GuiCtrlRead($gOverwriteIni) = 1 Then _FileCreate($sWilIniFile)
	If GuiCtrlRead($gLaunchNow) = 1 Then Run($sWilExeFile)
EndFunc
