#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=res\gcitb.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <EditConstants.au3>
#include <FontConstants.au3>
#include "NoFocusLines.au3"
#cs
    Title:          DiscEx Batch
    Filename:       DiscExBatch.au3
    Description:    Compress multilpe isos at once
    Author:         Francesco Gerratana
	Website:		www.nextechnics.com
    Version:        V1.0
    Last Update:    25.11.2016
    Requirements:   AutoIt3 3.2 or higher, http://www.wiibackupmanager.co.uk/gcit.html
#ce
DirCreate(@ScriptDir&"\res")
Local $bFileInstall = True
If $bFileInstall Then
FileInstall("E:\DEVREPO\gamecube_tool\res\gcitb.ico",@ScriptDir&"\res\gcitb.ico")
EndIf
Global Const $sFilePath = @ScriptDir&"\log.txt"
Global $aArray
Global $7zip = @ScriptDir&"\gcit.exe",$StatusBar
Global $vFlush,$vBackup,$vAlign,$vFormat
#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Gamecube ISO batch converter", 400, 150, 212, 156)
GUISetBkColor(0x404040)
GUICtrlSetDefColor(0xEDEDED)
GUICtrlSetDefBkColor(0xcc0000)
Local $sFont = "Comic Sans MS"
GUISetFont(9,  $FW_NORMAL, $GUI_FONTUNDER, $sFont)
Global $icon = @ScriptDir&"\res\gcitb.ico"
If Not @Compiled Then GUISetIcon($icon)
GUISetIcon($icon, -1)
$lFormat = GUICtrlCreateLabel("Format",235, 26,60, 21)
GUICtrlSetBkColor(-1,0x404040)
$Format = GUICtrlCreateCombo("GCReEx", 136, 72, 89, 25,BitOR($ES_READONLY, $CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData($Format,"DiscEx|FullISO","DiscEx")
GUICtrlSetTip(-1, "Set the destination format. Default is Trimmed ISO.")
$Flush = GUICtrlCreateCheckbox("",16, 24, 17, 17)
GUICtrlSetBkColor(-1,0x404040)
GUICtrlSetTip(-1, "Flush the file buffers so that the SD card can be ejected almost immediately after the operation.")
$lFlush = GUICtrlCreateLabel("Flush",36, 26, 60, 21)
GUICtrlSetBkColor(-1,0x404040)
$Backup = GUICtrlCreateCheckbox("", 16, 72, 17, 17)
GUICtrlSetBkColor(-1,0x404040)
GUICtrlSetTip(-1, "Save a backup of the original fst.bin and boot.bin files inside the trimmed ISO.")
$lBackup = GUICtrlCreateLabel("Backup",36, 76, 60, 21)
GUICtrlSetBkColor(-1,0x404040)
$lAlign = GUICtrlCreateLabel("Align",235, 76, 60, 21)
GUICtrlSetBkColor(-1,0x404040)
$Align = GUICtrlCreateCombo("4", 136, 24, 89, 25,BitOR($ES_READONLY, $CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData($Align, "32|32k", "32k")
GUICtrlSetTip(-1, "Set the alignment used in the ISO. 4 bytes, 32 bytes or 32KB. Default is auto.")
$run = GUICtrlCreateButton("Start", 300, 10, 90, 90, BitOR($BS_FLAT,$WS_CLIPSIBLINGS))
_NoFocusLines_Set($run)
GUICtrlSetTip(-1, "Set the output location.")
$StatusBar = _GUICtrlStatusBar_Create($Form1)
_GUICtrlStatusBar_SetText($StatusBar, "Ready")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $run
			$vFlush = ""
			If GUICtrlRead($Flush) = 1 Then
				$vFlush = " -Flush "
			EndIf
			$vBackup = ""
			If GUICtrlRead($Backup) = 1 Then
				$vBackup = " -b "
			EndIf
			$vAlign = " -a "&GUICtrlRead($Align)
			$vFormat = " -f "&GUICtrlRead($Format)
			Local $spFile
			$mFile = FileOpenDialog("apri", @ScriptDir & "", "Images (*.iso)", 1 + 4 )
			If @error Then
				_GUICtrlStatusBar_SetText($StatusBar,"Please select one ISO")
			Else
				$iso = StringSplit($mFile, "|")
				 If UBound($iso) = 2 Then
					 ConsoleWrite($iso[1]&@CRLF)
					 _ArrayDelete($iso, 0)
					 Dim $aItems[UBound($iso)]
					  _ArrayPush($aItems,$iso[0])
				 Else
					 $path = $iso[1]
					 _ArrayDelete($iso, 0)
					 _ArrayDelete($iso, 0)
					Dim $aItems[UBound($iso)]
					 For $x = 0 to UBound($iso)-1
						 _ArrayPush($aItems,$path&"\"&$iso[$x])
						 ConsoleWrite($path&"\"&$iso[$x]&@CRLF)
					 Next
				EndIf
			EndIf
			$dest = FileSelectFolder("Select destination Folder",@ScriptDir)
			If ($dest = "") Then
				_GUICtrlStatusBar_SetText($StatusBar,"Select a valid folder!!!")
			Else
				start($aItems,$dest,$vBackup,$vFlush,$vAlign,$vFormat)
			EndIf
	EndSwitch
WEnd

Func start($aItems,$dest,$vFlush,$vBackup,$vAlign,$vFormat)
	Local $ok = 0,$err = 0
	$hFileOpen = FileOpen($sFilePath, 2)
	$PID = 1
		For $x = 0 to UBound($aItems)-1
			_GUICtrlStatusBar_SetText($StatusBar,"Wait write "&$aItems[$x])
			ConsoleWrite('"'&$aItems[$x]&'"'&" -aq "&$vBackup&$vFlush&$vFormat&$vAlign&" -d "&'"'&$dest&'"'&@CRLF)
			$PID = ShellExecuteWait($7zip,'"'&$aItems[$x]&'"'&" -aq "&$vBackup&$vFlush&$vFormat&$vAlign&" -d "&'"'&$dest&'"',@ScriptDir,"",@SW_HIDE)
			If $PID = 1 Then
				$err+= 1
				FileWriteLine($hFileOpen, "Error Doesn't work "&$aItems[$x]&@CRLF)
				ConsoleWrite("Err "&$PID&" Doesn't work "&$aItems[$x]&@CRLF)
			Else
				$ok+=1
				FileWriteLine($hFileOpen, "Finish Game "&$aItems[$x]&@CRLF)
				ConsoleWrite("Finish "&$PID&" Game "&$aItems[$x]&@CRLF)
			EndIf
		Next
		_GUICtrlStatusBar_SetText($StatusBar,"Finish tot."&$ok&" || Error tot."&$err)
	FileClose($hFileOpen)
EndFunc
