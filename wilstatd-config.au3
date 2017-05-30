#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=WilstatD-Config.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#include <Process.au3>
#include <Constants.au3>

;;;;;;;;;;;;;;;;;;;;Wilstat Daemon Configurator;;;;;;;;;;;;;;;;;;;;
;Author: Gerald Wiltse
;Email: jerrywiltse@gmail.com
;Release Date: 8/20/2008
;Version: 1.0
;
;Instructions: Just launch it and choose your options, then restart the service
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
$sWilstatDVersion = 1.0
$sSvcDisplayName = 'Wilstat Daemon'
$sWilstatDRegKey = 'HKLM\System\CurrentControlSet\Services\Wilstat Daemon'
$sTSRegKey = 'HKLM\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'

If RegRead($sWilstatDRegKey,$sWilstatDVersion) = "" Then 
	RegWrite($sWilstatDRegKey)
	RegWrite($sWilstatDRegKey,'Version','REG_DWORD', $sWilstatDVersion)
	RegWrite($sWilstatDRegKey,'ListenPort','REG_DWORD','34744')
EndIf

$rAutostart = RegRead($sWilstatDRegKey,"Start")
$rListenPort = RegRead($sWilstatDRegKey,"ListenPort")
$rTSListenPort = RegRead($sTSRegKey,"PortNumber")

GUICreate("Wilstat Daemon Configurator", 250, 130)
$gAutostartCheckbox = GUICtrlCreateCheckbox("Autostart Service", 10, 5)
$gStartButton = GUICtrlCreateButton("Start Service", 150, 10,70)
$gStopButton = GUICtrlCreateButton("Stop Service", 150, 35,70)
$gSaveButton = GUICtrlCreateButton("Save", 150, 60,70)
$gHelpButton = GUICtrlCreateButton("Help", 150, 85,70)
$gListenPortGroup = GUICtrlCreateGroup("Daemon Listen Port",10,30,130,40)
$gListenPort = GUICtrlCreateInput("",20,45,110,20)
$gTSListenPortGroup = GUICtrlCreateGroup("TS Listen Port",10,75,130,40)
$gTSListenPort = GUICtrlCreateInput("",20,90,110,20)

If $rAutostart = 2 Then GuiCtrlSetState($gAutostartCheckbox,$GUI_CHECKED)
GuiCtrlSetData($gListenPort,$rListenPort)
GuiCtrlSetData($gTSListenPort,$rTSListenPort)
GUISetState(@SW_SHOW)

While 1
  $msg = GUIGetMsg()

  Select
	Case $msg = $GUI_EVENT_CLOSE
      	ExitLoop
	Case $msg = $gStartButton
		_RunDos('Net start ' & '"' & $sSvcDisplayName & '"')
	Case $msg = $gStopButton
		_RunDos('Net stop ' & '"' & $sSvcDisplayName & '"')
	Case $msg = $gSaveButton
		_SaveSettings()
	Case $msg = $gHelpButton
		Msgbox(0,'Usage instructions', _
			'This program configures the registry settings for Wilstat Daemon. ' & _
			'The options are so simple, I do not feel it needs instructions.')		
  EndSelect
WEnd 

Func _SaveSettings()
	If GuiCtrlRead($gAutostartCheckbox) = 1 Then RegWrite($sWilstatDRegKey,'Start','REG_DWORD','2')	
	If GuiCtrlRead($gAutostartCheckbox) <> 1 Then RegWrite($sWilstatDRegKey,'Start','REG_DWORD','3')	
	RegWrite($sWilstatDRegKey,"ListenPort","REG_DWORD",GuiCtrlRead($gListenPort))
	RegWrite($sTSRegKey,"PortNumber","REG_DWORD",GuiCtrlRead($gTSListenPort))
EndFunc
