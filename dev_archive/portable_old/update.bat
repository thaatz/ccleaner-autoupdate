set installdir=ccsetup
@echo off
::if you run this as administrator or with UAC disabled, you will not be prompted to run the installer, it will be automatic

::change working directory to the script location so that wget downloads to the script location (easier for cleanup)
cd /d "%~dp0"

:: first we search for existing ccsetup files to determine the last version this script installed
for %%f in ("%~dp0ccsetup*.zip") do (
	:: assume that this is the current version
	set cver=%%~nf
)
::if there are no ccsetup files, then assume that this script has never installed ccleaner
if not exist "%~dp0%cver%.zip" ( set cver=none )

::download the "slim" installer, which comes with no special promos or anything
::using the --no-clober switch, we ensure that we dont redownload the current version
echo Checking server for updates . . .
echo.
"%~dp0bin\wget" -nc --content-disposition http://www.piriform.com/ccleaner/download/portable/downloadfile

::if we get a 404 not found or unable to resolve host error, then either ccleaner slim is temporarily unavailable, or there is no network connection.
::we stop the script and exit with code 0x1 so that windows task scheduler can attempt to try again later
REM if %errorlevel%==1 exit 1
REM this is used for windows task scheduler, and since this is the portable version, this script would be run on demand and so we tell the user what happend instead.
if %errorlevel%==1 (
	echo.
	echo ccleaner could not update
	pause
	exit
)

::if we download a new setup file, delete all but the latest ccsetup file
::http://stackoverflow.com/questions/13367746/batch-file-that-keeps-the-7-latest-files-in-a-folder
for /f "skip=1 eol=: delims=" %%F in ('dir /b /o-d "%~dp0ccsetup*.zip"') do @del "%%F"

for %%f in ("%~dp0ccsetup*.zip") do (
	:: if the ccsetup file that we find is the same version as the previous one, then we skip the install
	if %%~nf==%cver% (
		echo CCleaner is already up to date [%%~nf]
	) else (
		echo A newer version of CCleaner was found [%cver% --^> %%~nf]
		echo Installing . . .
		::  start extracting using 7zip overwriting all files
		bin\7z x -o"%installdir%" -y "%%~ff"
		echo Finished
	)
)
REM echo.
pause