@echo off
rem we set the local env var serverpath to the mac mini's address
rem setlocal ensures we don't polute the list of environment variables permenantly
setlocal

rem assume we are starting from the directory above bat
call bat\set-server-envvar.bat

rem use argument to set php status
bin\wget http://%server_ip%/processing/macMiniStatus.php?status=%1 ^
--http-user %http_user% --http-password %http_pass% -O NUL --quiet
endlocal
exit /b