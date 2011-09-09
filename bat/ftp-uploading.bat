@echo off

rem we set the local env var serverpath to the mac mini's address
rem setlocal ensures we don't polute the list of environment variables permenantly
setlocal

rem assume we are starting from the directory above bat
call bat\set-server-envvar.bat

rem go to the uploading directory
cd uploading

> ftp-script.txt echo open %server_ip%
>> ftp-script.txt echo %ftp_user%
>> ftp-script.txt echo %ftp_pass%
>> ftp-script.txt echo binary

rem now process each tgz
for %%f in (*.tgz) do call :appendFtpScript %%f %%~nf

rem now append the closing commands to the script 
>> ftp-script.txt echo close
>> ftp-script.txt echo quit

rem start the ftp script going
ftp -s:ftp-script.txt

if exist uploaded-tgzs (
	move *.tgz uploaded-tgzs\
) ELSE (
	mkdir uploaded-tgzs
	move *.tgz uploaded-tgzs\
)

rem cd back out of the uploading directory
cd ..

rem display success message
echo =
echo =
echo =====================================
echo = uploading to %server_ip% completed
echo =====================================
endlocal
exit /b

rem ----------------------------------------------
:appendFtpScript
rem %1 = tgz name
rem
rem 1. delete the outgoing copy on the PHP server
rem 2. upload the new one into  transcribed (maybe incoming )

>> ftp-script.txt echo cd /outgoing
>> ftp-script.txt echo del /outgoing/%1
>> ftp-script.txt echo cd /transcribe
>> ftp-script.txt echo put %1

rem now return control back to the for loop - searching for other tgz files in the wgot directory
exit /b