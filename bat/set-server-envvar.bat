rem we use setlocal in the calling script to avoid poluting the environment permenantly
@echo off

set server_ip=
set ftp_user=
set ftp_pass=
set http_user=%ftp_user%
set http_pass=%ftp_pass%

rem we use endlocal in the calling script after we're done with the variable