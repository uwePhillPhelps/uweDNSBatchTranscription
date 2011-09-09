@echo off
rem we set the local env var serverpath to the mac mini's address
rem setlocal ensures we don't polute the list of environment variables permenantly
setlocal

rem assume we are starting from the directory above
call bat\set-server-envvar.bat

rem make and cd into a wgot directory
IF exist wgot (
	cd wgot
) ELSE (
	mkdir wgot
	cd wgot
)

rem wget files recursive, no parent, accept tgz, reject htm and html, zero directory level
rem no directories, no clober, quiet
..\bin\wget -r -np -A tgz -R htm,html -l 0 ^
--no-directories -nc --quiet ^
--http-user %http_user% ^
--http-password %http_pass% ^
http://%server_ip%/processing/outgoing/
rem del *.htm*

rem cd back out of the wgot directory
cd ..

rem endlocal ensures we don't polute the list of environment variables permenantly
endlocal
exit /b
