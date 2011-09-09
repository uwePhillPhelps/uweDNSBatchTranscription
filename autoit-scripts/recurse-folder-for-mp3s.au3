;
; Phill Phelps - 2009
;
; 1. The script must be run from a directory containing files to transcribe (in a subdir is ok)
; 2. it creates a list (FilePaths.txt) of the wav files in that directory
;
; 3. for each file found
;    3a. tell dragon pad to make a new transcription text file with name from FileNAMES.txt
;    3b. tell dragon bar to transcribe from the wav file at path from FilePATHS.txt
; 
;

MsgBox(4096, "auto-it script started", "Ok", 3)
ShellExecute("bat\immediate-PHPstatus.bat", "autoit_script_started", @ScriptDir & "\..")
ShellExecute( "natspeak.exe" , "", "C:\Program Files\Nuance\NaturallySpeaking10\Program" )

; when the DragonBar first loads, the text in the window changes rapidly with status updates
; wait until the status "Microphone is off" appears before continuing
While (WinActive("DragonBar", "Microphone is off") == 0)	
	; if multiple voice profiles are created - a "Open User" window may appear
	If WinActivate("Open User") == 1 Then
		Send("{ENTER}") ; try to dismiss the dialog by picking the default option
		; FIXME - in future read .submissioninfo to select a chosen voice profile
	EndIf
	
	; wait a bit, then check to see if dragon is waiting i.e. status="microphone is off"
	Sleep(500)
	WinActivate("DragonBar", "Microphone is off")
WEnd

MsgBox(4096, "ns10 should now be active", "Ok", 3)
$path = @ScriptDir;
ScanFolder($path)

; scripts are not able to delete transcribe folder by if dragon pad has the directory locked
; change to a dummy transcript in the wgot directory
DragonPadClear();
DragonPadSave(@ScriptDir, "dummy.txt")
DragonExit();

MsgBox(4096, "auto-it script finished", "Ok", 3)
ShellExecute("bat\immediate-PHPstatus.bat", "autoit_script_finished", @ScriptDir & "\..")
Exit

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; functions go here
;
Func ScanFolder($SourceFolder)
	; Based on http://dailycupoftech.com/folder-recursion-in-autoit/  
	; on 2009 April 28th
	Local $Search
	Local $File
	Local $FileAttributes
	Local $FullFilePath

	$Search = FileFindFirstFile($SourceFolder & "\*.*")
 
	While 1
		If $Search = -1 Then
			ExitLoop
		EndIf

		$File = FileFindNextFile($Search)
		If @error Then ExitLoop

		$FullFilePath = $SourceFolder & "\" & $File
		$FileAttributes = FileGetAttrib($FullFilePath)

		; uncomment to log all files found (including directories)
		;LogFile($FullFilePath, $File) ; report each file
	
		; uncomment to recurse subdirectories 
		If StringInStr($FileAttributes,"D") Then
			; if we've found a directory - keep going down
			ScanFolder($FullFilePath)
		Else
			; get the last 3 characters of the file
			$FileExt = StringRight($File,4) 
			
			If ( StringInStr($FileExt,".mp3") and StringInStr($File, "silence") ) Then
				; avoid processing the source mp3 - only process "_silence" split files
				; if we've found an mp3 file - start processing!
					LogFile($FullFilePath, $File)
		
					; construct the same filename with .txt as extention
					$NameLength = StringLen($File)
					$FileWithoutExt = StringLeft($File, $NameLength - 4)
					$FileTXT = $FileWithoutExt & ".txt"
					
					; poke the dragon interface into loading and saving files
					DragonPadClear() ; open the dragon pad and create a new file
					DragonPadSave($SourceFolder, $FileTXT) ; tell dragonpad to save the blank file
					DragonBarTranscribe($FullFilePath) ; Tell Dragonbar to transcribe audio into this newly blank file
					DragonPadSave($SourceFolder, $FileTXT) ; tell dragonpad to save the now fully transcribed file
			EndIf
			
			; if the file is not a wav file - skip over it
		EndIf
	WEnd
 
	FileClose($Search)
EndFunc

Func LogFile($AllFilePath, $JustFileName)
	; Based on http://dailycupoftech.com/folder-recursion-in-autoit/ 
	; on 2009 April 28th
	
	; write file to log
	$Line = $AllFilePath & chr(9) & $JustFileName 
	FileWriteLine(@ScriptDir & "\FileList.txt",$Line)
	
	; send status to PHP
	ShellExecute("bat\immediate-PHPstatus.bat", StringReplace($JustFileName, " " , ""), @ScriptDir & "\..")
EndFunc

Func DragonPadClear()
	; Tells dragon pad to make a new text file called $File
	
	If WinExists("DragonPad") == 0 Then
		WinActivate ( "DragonBar" )
		WinWaitActive( "DragonBar", "",3)
		Send("!t") ; alt + t (tools menu)
		Sleep(25)
		Send("p") ; p (dragon pad menuitem)
	EndIf
	
	WinActivate("DragonPad -") ; then activate
	WinWaitActive( "DragonPad -", "",3) ; wait
	Send("^a") ; ctrl + a (select all)
	Sleep(25)
	Send("{DELETE}") ; delete all
	Sleep(25)
	
	;MsgBox(0,$SourceFolder,$File)
EndFunc

Func DragonExit()
	; Tells dragon pad to exit
	
	If WinExists("DragonPad") == 0 Then
		WinActivate ( "DragonBar" )
		WinWaitActive( "DragonBar", "",3)
		Send("!t") ; alt + t (tools menu)
		Sleep(25)
		Send("p") ; p (dragon pad menuitem)
	EndIf
	
	WinActivate("DragonPad -") ; then activate
	WinWaitActive( "DragonPad -", "",3) ; wait
	Send("!{F4}") ; alt + function 4
	Sleep(25)
	
	While (WinActive("DragonBar", "Microphone is off") == 0)
		WinActivate("DragonBar", "Microphone is off")
		Sleep(500)
	WEnd
	WinWaitActive( "DragonBar", "Microphone is off",3) ; wait
	Send("!{F4}") ; alt + function 4
	Sleep(25)
	
EndFunc

Func DragonPadSave($SourceFolder, $FileName)
	; tells dragonpad to save the current file as a text file
	
	WinActivate("DragonPad -")
	WinWaitActive("DragonPad -","" ,3)
	WinActivate("DragonPad -")
	Send("!f") ; alt + f (file menu)
	Sleep(25)
	Send("a") ; a (save as)
	WinActivate ( "Save As" )
	WinWaitActive( "Save As", "", 3)
	WinActivate ( "Save As" )
	Send("!n") ; alt + n (file name)
	Sleep(25)
	
	ControlCommand("Save As", "", "[CLASS:ComboBox; INSTANCE:3]", "SelectString",  "Text Document")
	ControlSetText("Save As", "", "[CLASS:Edit; INSTANCE:1]", $SourceFolder & "\" & $FileName) ; filename includes ".txt"
	
	Send("{ENTER}") ; dismiss the save dialog
	
	; wait 3 seconds before dismissing "overwrite?" messages by indeed overwriting
	If WinWaitActive("Save As","already exists",3) == 1 Then
		WinActivate("Save As","already exists")
		Send("y")
		WinWaitClose("Save As")
	EndIf
	
	; wait 3 seconds before dismissing "loose all formatting" dialog
	If WinWaitActive("Dragon NaturallySpeaking","You are about to save the document",3) == 1 Then 
		Send("!t") ; alt + t (text document button)
		WinWaitClose("Dragon NaturallySpeaking","You are about to save the document")
	EndIf
	
	WinActivate("DragonPad -")
EndFunc

Func DragonBarTranscribe($FullFilePath)
	WinActivate ( "DragonBar" )
	Send("!s")
	Sleep(25)
	Send("t")
	WinWait( "Transcribe from...", "" ,3)
	ControlSetText("Transcribe from...", "", "[CLASS:Edit; INSTANCE:1]", $FullFilePath)
	Sleep(25)
	Send("!t") ; alt + t (transcribe button)
	WinWait("Transcribing", "Transcribing... Please Wait")
	WinWaitClose ( "Transcribing", "Transcribing... Please Wait")	
EndFunc