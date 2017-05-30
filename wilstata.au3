#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=WilstatA.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <GUIConstantsEx.au3>
#Include <GuiListView.au3>
#include <Array.au3>
#Include <File.au3>
#include <WindowsConstants.au3>


;;;;;;;;;;;;;;;;;;;;Wilstat Agent ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Author: Gerald Wiltse
;Email: jerrywiltse@gmail.com
;Release Date: 8/20/2008
;Version: 1.0
;
;Instructions: Run this program to connect to a pool of servers.
;				It first checks to see if the username provided is
;				already logged on, and autoconnects if it is. 
;				It then counts users on each server and chooses
;				the least busy (based on user count. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


$sWilIniFile = FileGetShortName(@ProgramFilesDir & '\Wilstat Agent\wilstata.ini')
$sWilRDPFile = FileGetShortName(@ProgramFilesDir & '\Wilstat Agent\wilstata.rdp')
If Not FileExists($sWilIniFile) Then _FileCreate($sWilIniFile)
If Not FileExists($sWilRDPFile) Then _FileCreate($sWilRDPFile)

;;;;;;;;;;;;;;Assign initial Values to Variables;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Dim $sDomain = IniRead(@ProgramFilesDir & '\Wilstat Agent\wilstata.ini','UserData','Domain','')
Dim $sUsername = IniRead(@ProgramFilesDir & '\Wilstat Agent\wilstata.ini','UserData','Username','')
Dim $useServerAddress = "No Server Chosen"
Dim $useTSPort = ""
Dim $sCompareArray[2]	

;;;;;;;;;;;;;;Create the GUI;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GUICreate("Wilstat Agent", 400,220)
$gConnectButton = GUICtrlCreateButton("Connect", 335, 10, 60,35)
$gAddButton = GUICtrlCreateButton("Add", 265, 50, 60,35)
$gSaveButton = GUICtrlCreateButton("Save", 335, 50, 60,35)
$gEditButton = GUICtrlCreateButton("Edit", 335,90, 60,35)
$gRemoveButton = GUICtrlCreateButton("Remove", 335, 130, 60,35)
$gDomainGroup = GUICtrlCreateGroup("Domain",10,5,110,40)
$gDomain = GUICtrlCreateInput("",20,20,90,20)
$gUsernameGroup = GUICtrlCreateGroup("Username",130,5,100,40)
$gUsername = GUICtrlCreateInput("",140,20,80,20)
$gAddServerGroup = GUICtrlCreateGroup("Add a Server",10,45,110,40)
$gAddServer = GUICtrlCreateInput("",20,60,90,20)
$gTSPortGroup = GUICtrlCreateGroup("TS Port",130,45,60,40)
$gTSPort = GUICtrlCreateInput("",140,60,40,20)
$gWSPortGroup = GUICtrlCreateGroup("WS Port",200,45,60,40)
$gWSPort = GUICtrlCreateInput("",210,60,40,20)
$gServerList = GUICtrlCreateListView("",10,90,320,120)
	_GUICtrlListView_InsertColumn($gServerList, 0, "IP or Hostname", 120)
	_GUICtrlListView_InsertColumn($gServerList, 1, "TS Port", 65)
	_GUICtrlListView_InsertColumn($gServerList, 2, "WS Port", 65)
	_GUICtrlListView_InsertColumn($gServerList, 3, "Usercount", 65)

;;;;;;;;;;;;;;Fill Out the GUI;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GuiCtrlSetData($gDomain,$sDomain)
GuiCtrlSetData($gUsername,$sUsername)
GuiCtrlSetData($gAddServer,"Hostname or IP")
GuiCtrlSetData($gTSPort,"3389")
GuiCtrlSetData($gWSPort,"34744")
_BuildServerList()
GUISetState(@SW_SHOW)

;;;;;;;;;;;;;;Loop and look for activity;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
While 1
  $msg = GUIGetMsg()

  Select
	Case $msg = $GUI_EVENT_CLOSE
		ExitLoop
	Case $msg = $gConnectButton
		_SaveSettings()
		_RunQuery()
		If $useServerAddress = "No Server Chosen" Then _ChooseBestServer()
		_WriteRDP()
		_LaunchRDP()
	Case $msg = $gAddButton
		_AddServer()	
	Case $msg = $gEditButton
		_EditServer()	
	Case $msg = $gRemoveButton
		_RemoveServer()	
	Case $msg = $gSaveButton
		_SaveSettings()
  EndSelect
WEnd 

;;;;;;;;;;;;;;Writes the servers in the INI to the list;;;;;;;;;;;;;;;;;;;;;;;

Func _BuildServerList()
	$sServerPoolArray = IniReadSection($sWilIniFile,"ServerPool")
	If @error <> 1 Then		
		For $i = 1 to $sServerPoolArray[0][0]
				$sSplitServerInfo = StringSplit($sServerPoolArray[$i][1],",")
				$sServerAddress =  $sSplitServerInfo[1]
				$sTSPort = $sSplitServerInfo[2]
				$sWSPort = $sSplitServerInfo[3]
				$sServerItem  = GUICtrlCreateListViewItem($sServerAddress  & "|" & $sTSPort & "|" & $sWSPort & "|" & "Unknown", $gServerList)
		Next
	EndIf	
EndFunc

Func _AddServer()
	GUICtrlCreateListViewItem(GuiCtrlRead($gAddServer) & "|" & GuiCtrlRead($gTSPort)  & "|" & GuiCtrlRead($gWSPort) & "|" & "Unknown", $gServerList)
EndFunc

Func _RemoveServer()
	_GUICtrlListView_DeleteItemsSelected ($gServerList)
EndFunc


Func _EditServer()
	$sEditArray = _GUICtrlListView_GetItemTextArray($gServerList, -1)
	GuiCtrlSetData($gAddServer,$sEditArray[1])
	GuiCtrlSetData($gTSPort,$sEditArray[2])
	GuiCtrlSetData($gWSPort,$sEditArray[3])
	_GUICtrlListView_DeleteItemsSelected ($gServerList)
EndFunc

Func _SaveSettings()
		_FileCreate($sWilIniFile)
		IniWrite($sWilIniFile,"UserData","Domain",GuiCtrlRead($gDomain))
		IniWrite($sWilIniFile,"UserData","UserName",GuiCtrlRead($gUsername))
		$sItemCount = _GUICtrlListView_GetItemCount($gServerList)
		For $i = 0 to $sItemCount -1
				$sSaveArray = _GUICtrlListView_GetItemTextArray($gServerList, $i)
				$sServerAddress =  $sSaveArray[1]
				$sTSPort = $sSaveArray[2]
				$sWSPort = $sSaveArray[3]				
				IniWrite($sWilIniFile,"ServerPool",$i,$sServerAddress & "," & $sTSPort & "," & $sWSPort)
		Next
EndFunc

Func _ChooseBestServer()
	;_ArrayDisplay($sCompareArray)
	$sMinIndex = _ArrayMinIndex ($sCompareArray,0)
	;Msgbox(0,'$sMinIndex',$sMinIndex)
	$useServerArray = _GUICtrlListView_GetItemTextArray($gServerList,$sMinIndex)
	$useServerAddress = $useServerArray[1]
	$useTSPort = $useServerArray[2]
	;Msgbox(0,'$useServer',$useServerAddress & ":" & $useTSPort)
EndFunc
	
Func _WriteRDP()	
	_FileCreate($sWilRDPFile)
	FileWrite($sWilRDPFile,"full address:s:" & $useServerAddress & ":" & $useTSPort & @CRLF)
	FileWrite($sWilRDPFile,"domain:s:" & GuiCtrlRead($gDomain) & @CRLF)
	FileWrite($sWilRDPFile,"username:s:" & GuiCtrlRead($gUsername) & @CRLF)
	FileWrite($sWilRDPFile,"redirectclipboard:i:1" & @CRLF)
	FileWrite($sWilRDPFile,"authentication level:i:0" & @CRLF)
	FileWrite($sWilRDPFile,"prompt for credentials:i:1" & @CRLF)
	;FileWrite($sWilRDPFile,"EnableCredSSPSupport:i:0")
	
	RegWrite('HKCU\Software\Microsoft\Terminal Server Client\UsernameHint',$useServerAddress,'REG_SZ',GuiCtrlRead($gDomain) & '\' & GuiCtrlRead($gUsername))
	RegWrite('HKCU\Software\Microsoft\Terminal Server Client\LocalDevices',$useServerAddress,'REG_DWORD',12)
EndFunc

Func _LaunchRDP()
	Run('mstsc ' & $sWilRDPFile)
EndFunc

;;;;;;;;;;;;;;Connect to the Servers and Get the Data;;;;;;;;;;;;;;;;;;;;;;;
Func _RunQuery()
TCPStartUp()
	Dim $useServerAddress = "No Server Chosen"
	Dim $useTSPort = ""
	Dim $sItemCount = _GUICtrlListView_GetItemCount($gServerList)
	Dim $sCompareArray[$sItemCount]	
	
	For $i = 0 to $sItemCount -1
		$sConnectArray = _GUICtrlListView_GetItemTextArray($gServerList, $i)
		$sConnectedSocket = TCPConnect(TCPNameToIP($sConnectArray[1]), $sConnectArray[3])

		Select
;;;;;;;;;;;;;;Connect Failed;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		Case $sConnectedSocket = -1  
			_GUICtrlListView_SetItemText ($gServerList, $i, "Failed",3)        		
			_ArrayDelete($sCompareArray,$i)
			_ArrayInsert($sCompareArray,$i,"Failed")		
				
;;;;;;;;;;;;;;Connect Succeeded;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		Case $sConnectedSocket >= 0   
				
;;;;;;;;;;;;;;;;;;;Query Username;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			$sQueryResult = TCPSend($sConnectedSocket,"Username::" & GuiCtrlRead($gUsername))
			;Msgbox(0,'agent:$sQueryResult',$sQueryResult)
				
;;;;;;;;;;;;;;;;;;;Get Response From Server;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			Do
				$sQueryResponse = TCPRecv($sConnectedSocket,1000) 
			Until $sQueryResponse <> ""
			$sSplitQueryResponse = StringSplit($sQueryResponse,"::",1)
			;Msgbox(0,'agent:$sQueryResponse',$sQueryResponse)				
			$sUserCount = $sSplitQueryResponse[2] 
			;Msgbox(0,'agent:$sUserCount',$sUserCount)
								
				Select 
					Case StringInStr($sQueryResponse,"No Data Received") 
						$sUserFound = "False:-1"
					Case StringInStr($sQueryResponse,"No Username Received") 
						$sUserFound = "False:-2"
					Case StringInStr($sQueryResponse,"User Found") 
						$sUserFound = "True:0"	
						$useServerAddress = $sConnectArray[1]
						$useTSPort = $sConnectArray[2]
				EndSelect

;;;;;;;;;;;;;;;;;;;Write UserCount back to list;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
				_GUICtrlListView_SetItemText ($gServerList, $i, $sUserCount,3)        

;;;;;;;;;;;;;;;;;;;Add Usercount to New Array for Math Comparison;;;;;;;;;;;;;;
				_ArrayDelete($sCompareArray,$i)
				_ArrayInsert($sCompareArray,$i,$sUserCount)	

			
				Sleep(1000)
				TCPCloseSocket($sConnectedSocket)
				
		EndSelect
	Next
	TCPShutdown()
EndFunc
