@echo off
:: Close the application
taskkill /IM tss.exe /F >nul 2>&1

:: Get the batch file's directory dynamically
set "BaseDir=%~dp0"

:: Create the folder for downloads
if not exist "%BaseDir%DownloadedFiles" (
    mkdir "%BaseDir%DownloadedFiles"
)

:: Initialize a variable to track download success
set "DownloadSuccess=1"

:: Download files from GitHub
echo Downloading files...
curl -L "https://github.com/mehrdadhamidi2002/TssUpdate/raw/refs/heads/main/tss.exe" -o "%BaseDir%DownloadedFiles\Tss.exe" || set "DownloadSuccess=0"
curl -L "https://github.com/mehrdadhamidi2002/TssUpdate/raw/refs/heads/main/Tss_Component.bpl" -o "%BaseDir%DownloadedFiles\Tss_Component.bpl" || set "DownloadSuccess=0"

:: Check if downloads were successful
if "%DownloadSuccess%"=="0" (
    echo Download failed! Exiting without copying files...
    goto :end
)

:: Verify downloads
echo Verifying downloads...
dir "%BaseDir%DownloadedFiles"

:: Copy files to the application folder
xcopy /Y /E "%BaseDir%DownloadedFiles\*" "%BaseDir%"

:: Restart the application
start "" "%BaseDir%tss.exe"

:: Clean up
del /F /Q "%BaseDir%DownloadedFiles\*" >nul 2>&1
rd /S /Q "%BaseDir%DownloadedFiles" >nul 2>&1

:end
echo Batch process complete.
