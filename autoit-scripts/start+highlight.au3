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

ShellExecute("bat\immediate-PHPstatus.bat", "autoit_script_started", @ScriptDir & "\..")
ShellExecute( "natspeak.exe" , "", "C:\Program Files\Nuance\NaturallySpeaking10\Program" )
MsgBox(4096, "When dragon has loaded - please make the dragon bar window active", "Ok", 3)

; when the DragonBar first loads, the text in the window changes rapidly with status updates
; wait until the status "Microphone is off" appears before continuing
While (WinActive("DragonBar", "Microphone is off") == 0)
	WinActivate("DragonBar", "Microphone is off")
	Sleep(500)
WEnd

MsgBox(4096, "ns10 should now be active", "Ok", 3)