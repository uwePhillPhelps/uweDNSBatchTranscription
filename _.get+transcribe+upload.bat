@echo off

set CONTINUE=0
	echo ====================================================
	echo = preparing to check PHP server for tgz files
	echo ====================================================
	call bat\wget-from-server.bat
	call bat\7zip-extract-tgz.bat
if %CONTINUE%==0 (
	echo ====================================================
	echo = ABORTING, no archives to extract
	echo ====================================================
	call bat\immediate-PHPstatus.bat Still_alive_and_found_no_archives_to_extract
	
	rem wait 1 second
	> NUL ping -n 2 127.0.0.1 
	exit /b
)

echo ====================================================
echo = now preparing AutoIt3 script to transcribe mp3s
echo ====================================================
rem autoit script calls immediate-PHPstatus periodically
copy autoit-scripts\recurse-folder-for-mp3s.au3 wgot\
call "C:\Program Files\AutoIt3\AutoIt3.exe" "wgot\recurse-folder-for-mp3s.au3"

echo =====================================================
echo =             finished transcription
echo =  now preparing ftp script to upload completed files
echo =====================================================
call bat\immediate-PHPstatus.bat preparing_ftp_upload
call bat\prepare-uploading.bat
call bat\ftp-uploading.bat

echo ====================================================
echo = completed getting transcribing and uploading
echo = 
echo = copies kept in /uploading/backup-tgzs-to-upload
echo = will not affect further runs of this script
echo ====================================================

call bat\immediate-PHPstatus.bat Completed
rem wait 1 second
> NUL ping -n 2 127.0.0.1 