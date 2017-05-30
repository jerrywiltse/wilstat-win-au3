#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_outfile=WilstatD.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Process.au3>
#include <Constants.au3>

;;;;;;;;;;;;;;;;;;;;Wilstat Daemon ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
$sWilstatRegKey = 'HKLM\SYSTEM\CurrentControlSet\Services\Wilstat Daemon'
$sListenIP = "0.0.0.0"
$sListenPort = RegRead($sWilstatRegKey,'ListenPort')

TCPStartUp()
$MainSocket = TCPListen($sListenIP, $sListenPort, 100)
If $MainSocket = -1 Then Exit

While 1
$ConnectedSocket = TCPAccept($MainSocket)
	If $ConnectedSocket >= 0 Then 
	Dim $sUserCountReply
	Dim $sUserNameReply
		_ReceiveData()
		_UserCountQuery()
		_SendData($ConnectedSocket,$sUserNameReply,$sUserCountReply)
		TCPCloseSocket($ConnectedSocket)
		_ReduceMemory()
	EndIf
Wend
TCPShutdown()
Exit

Func _ReceiveData()
	$sReceivedData = TCPRecv($ConnectedSocket,50) 

	;Msgbox(0,'daemon:$sReceivedData',$sReceivedData)
		
		If $sReceivedData = "" Then
			$sUserNameReply = "No Data Received"
			;Msgbox(0,'daemon: $sUserNameReply',$sUserNameReply)
		Else 
			$sSplitReceivedData = StringSplit($sReceivedData,"::",1)
				
			If $sSplitReceivedData[1] = "Username" AND $sSplitReceivedData[2] = ""	Then 
				$sUserNameReply = "No Username Received"
				;Msgbox(0,'daemon: $sUserNameReply',$sUserNameReply)
				EndIf
				
			If $sSplitReceivedData[1] = "Username" AND $sSplitReceivedData[2] <> "" Then 
				_UserNameQuery($sSplitReceivedData[2])
				EndIf
		EndIf
EndFunc

Func _UserCountQuery()
	;Msgbox(0,'daemon','Starting UserCount Query')
	$sUserCountQuery = Run(@ComSpec & " /c " & "QUERY SESSION", "", @SW_HIDE,8)
	Sleep(1000)
	$sUserCountQueryResult = StdoutRead($sUserCountQuery)
	$sUserCountArray = StringSplit($sUserCountQueryResult,"rdpwd",1)
	$sUserCountReply = $sUserCountArray[0] -2
EndFunc

Func _UserNameQuery($sUserName)
	;Msgbox(0,'daemon','Starting Username Query')
	$sUserNameQuery = Run(@ComSpec & " /c " & "QUERY USER " & $sUserName, "", @SW_HIDE,8)
	Sleep(1000)
	$sUserNameQueryResult = StdoutRead($sUserNameQuery)
	;Msgbox(0,'daemon',$sUserNameQueryResult)
	If StringInStr($sUserNameQueryResult,"No User Exists") > 0 Then 
		$sUserNameReply = "No User Exists"
		;Msgbox(0,'daemon: $sUserNameReply',$sUserNameReply)
		EndIf
	If StringInStr($sUserNameQueryResult,"No User Exists") <= 0 Then 
		$sUserNameReply = "User Found"
		;Msgbox(0,'daemon: $sUserNameReply',$sUserNameReply)
		EndIf
EndFunc
			
Func _SendData($var1,$var2,$var3)
	$sendResult = TCPSend($var1,$var2 & "::" & $var3)
	;Msgbox(0,'Daemon Send Result', $sendResult)

EndFunc

Func _ReduceMemory()
   DllCall("psapi.dll", "int", "EmptyWorkingSet", "long", -1)
EndFunc
