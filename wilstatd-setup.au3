#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=Install-WilstatD.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <Process.au3>
#include <Constants.au3>

;;;;;;;;;;;;;;;;;;;;Wilstat Daemon Installer  ;;;;;;;;;;;;;;;;;;;;
;Author: Gerald Wiltse
;Email: jerrywiltse@gmail.com
;Release Date: 8/20/2008
;Version: 1.0
;
;Instructions: Run this program on all servers you want involved in your pool
;				then use wilstat agent to poll the servers and connect
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

$sWilstatDVersion = 1.0
$sSvcDisplayName = 'Wilstat Daemon'
$sWilstatDRegKey = 'HKLM\System\CurrentControlSet\Services\Wilstat Daemon'

GUICreate("Wilstat Daemon Installer", 250, 100)
$gAutostartCheckbox = GUICtrlCreateCheckbox("Autostart Service On Boot", 10, 5)
$gStartNowCheckbox = GUICtrlCreateCheckbox("Start Service After Install", 10, 25)
$gInstallButton = GUICtrlCreateButton("Install", 10, 60, 60)
$gCancelButton = GUICtrlCreateButton("Cancel", 80, 60, 60)
$gHelpButton = GUICtrlCreateButton("Help", 150, 60, 60)
GuiCtrlSetState($gAutostartCheckbox,$GUI_CHECKED)
GuiCtrlSetState($gStartNowCheckbox,$GUI_CHECKED)
GUISetState(@SW_SHOW)

While 1
  $msg = GUIGetMsg()

  Select
    Case $msg = $GUI_EVENT_CLOSE
      	ExitLoop
	Case $msg = $gCancelButton
		ExitLoop
	Case $msg = $gInstallButton
		_RunDos('Net stop ' & '"' & $sSvcDisplayName & '"')
		Sleep(1000)
		_InstallFiles()
		_InstallService()
		MsgBox(0, "Congratulations", "Wilstat Daemon Was Installed Successfully!")
		Exit	
	Case $msg = $gHelpButton
		Msgbox(0,'Usage instructions', _
			"This will install Wilstat Daemon and the Wilstat Configurator." & @CR & _ 
			"Wilstat Daemon runs as a system service with the help of srvany.exe which is included." & @CR & _
			"Launch the configurator to setup this server, or edit the wilstatd.ini file directly and restart the service." & @CR & _
			"Each server you want included in your pool will need to have the Daemon Installed." & @CR & _
			"All required files will be installed in the registry under:" & @CR & _
			$sWilstatDRegKey)		
  EndSelect
WEnd 



Func _InstallFiles()
	DirCreate(@ProgramFilesDir & '\Wilstat Daemon')
	;FileInstall('\\fs01\UserData\scripts\source\targetfiles\SrvAny\srvany.exe','c:\windows\srvany.exe',1)
	;FileInstall('\\fs01\UserData\Scripts\source\Jerry\Wilstat\wilstatd.exe',@ProgramFilesDir & '\Wilstat Daemon\wilstatd.exe',1)
	;FileInstall('\\fs01\UserData\Scripts\source\Jerry\Wilstat\wilstatd-config.exe',@ProgramFilesDir & '\Wilstat Daemon\Wilstatd-Config.exe',1)
	FileInstall('Z:\Storage\scripts\JerryScripts\Wilstat\srvany.exe','c:\windows\srvany.exe',1)
	FileInstall('Z:\Storage\scripts\JerryScripts\Wilstat\wilstatd.exe',@ProgramFilesDir & '\Wilstat Daemon\wilstatd.exe',1)
	FileInstall('Z:\Storage\scripts\JerryScripts\Wilstat\wilstatd-config.exe',@ProgramFilesDir & '\Wilstat Daemon\Wilstatd-Config.exe',1)
	FileCreateShortcut(@ProgramFilesDir & '\Wilstat Daemon\wilstatd-config.exe',@DesktopCommonDir & '\WilstatD Config.lnk')
EndFunc

Func _InstallService()
	$objWMIService = ObjGet('winmgmts:' & '{impersonationLevel=impersonate}!\\.\root\cimv2')
	$objService = $objWMIService.Get('Win32_BaseService')
	$errReturn = $objService.Create($sSvcDisplayName,$sSvcDisplayName,'c:\windows\srvany.exe',16,1, _
	'Automatic',false,'LocalSystem','')

	RegWrite($sWilstatDRegKey)
	RegWrite($sWilstatDRegKey,'Version','REG_DWORD', $sWilstatDVersion)
	RegWrite($sWilstatDRegKey,'ListenPort','REG_DWORD','34744')
	RegWrite($sWilstatDRegKey & '\Parameters')
	RegWrite($sWilstatDRegKey & '\Parameters', 'AppDirectory', 'REG_SZ', @ProgramFilesDir & '\Wilstat Daemon')
	RegWrite($sWilstatDRegKey & '\Parameters', 'Application', 'REG_SZ', @ProgramFilesDir & '\Wilstat Daemon\wilstatd.exe')
	
	If GuiCtrlRead($gAutostartCheckbox) = 1 Then RegWrite($sWilstatDRegKey,'Start','REG_DWORD','2')	
	If GuiCtrlRead($gStartNowCheckbox) = 1 Then _RunDos('Net start ' & '"' & $sSvcDisplayName & '"')
EndFunc
