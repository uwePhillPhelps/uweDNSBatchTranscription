rem it is important that no setlocal is used here in the future,
rem we use a CONTINUE parameter here  that the master script must read
@echo off
cd wgot

set CONTINUE=0
	for %%f in (*.tgz) do call :7ziptgz %%f
if %CONTINUE%==0 goto exitnow

set CONTINUE=0
	for %%f in (*.tar) do call :7ziptar %%f
if %CONTINUE%==0 goto exitnow

rem remove any temporary tar files remaining
del *.tar
goto exitnow
	
rem ----------------------------------------------
:7ziptgz
rem if we're here there must be tgz files - set continue flag to 1
set CONTINUE=1
	..\bin\7za x %1
	if exist backup-source-tgzs (
		move %1 backup-source-tgzs\
	) ELSE (
		mkdir backup-source-tgzs
		move %1 backup-source-tgzs\
	)
exit /b

:7ziptar
rem if we're here there must be tgz files - set continue flag to 1
set CONTINUE=1
	..\bin\7za x %1
	del %1
exit /b

:exitnow
rem cd back out of the wgot directory
cd ..
exit /b