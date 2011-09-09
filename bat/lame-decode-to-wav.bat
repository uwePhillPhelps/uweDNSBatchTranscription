@echo off
cd wgot

rem prepare directory to archive source mp3s
mkdir mp3-source

echo starting to decode all mp3s with silence in their name to wav
for /f "tokens=*" %%a in ('dir /b /s /a-d *silence*.mp3') do call :lamecall "%%a"
echo finished decoding mp3s to wav

rem cd back out of the wgot directory
cd ..
exit /b








rem ----------------------------------------------
:lamecall

rem decode to mono wav
..\bin\lame --decode %1 -m m 

rem archive source mp3
move %1 mp3-source\
exit /b




rem echo moving decoded wavs into subdirectory
rem mkdir wavs
rem move *.wav wavs\
rem echo finished moving files
