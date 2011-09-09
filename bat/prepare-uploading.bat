@echo off

rem we set the local env var serverpath to the PHP server's address
rem setlocal ensures we don't polute the list of environment variables permenantly
setlocal

rem assume we are starting from the directory above bat
call bat\set-server-envvar.bat

rem make a directory for uploading
mkdir uploading

rem ----------------------------------------------
rem step into the wgot then segmented directory
rem ----------------------------------------------
cd wgot
cd segmented

rem -----------------------------------------------
rem for every <sub-directory> - call a subroutine to
rem 1. tar and gzip up the new versions
rem 2. delete all source directories the tarballs were made from

rem /d = directories
rem %%~nf = without preceding path (or extension?)
rem -----------------------------------------------
for /d %%f in (*.*) do call :createTarballs %%f %%~nf

rem ----------------------------------------------
rem now cd back out of segmented and delete it
rem /s = subdirectories, /q = do not ask if ok to delete
rem ----------------------------------------------
cd ..
rmdir /s /q segmented

rem ----------------------------------------------
rem now delete the backup-source-tgzs directory
rem /s = subdirectories, /q = do not ask if ok to delete
rem ----------------------------------------------
rmdir /s /q backup-source-tgzs

rem each directory has now been processed - cd back out of wgot
cd ..
exit /b

rem ----------------------------------------------
:createTarballs
rem make a temporary tar
rem - 7zip cannot make tgzs in one step 
rem - delete this after we've made the tgz

rem "..\..\" means "step out of wgot\segmented"
rem ----------------------------------------------
..\..\bin\7za a %2.tar "%1"
..\..\bin\7za a -tgzip ..\..\uploading\%2.tgz %2.tar
del %2.tar

rem ----------------------------------------------
rem now return control back to the for loop
rem searching for other things to process
rem ----------------------------------------------
exit /b