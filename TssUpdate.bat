@echo off
:: Close the application
taskkill /IM tss.exe /F >nul 2>&1

:: Get the batch file's directory dynamically
set "BaseDir=%~dp0"

:: Create the folder for downloads
if not exist "%BaseDir%DownloadedFiles" (
    mkdir "%BaseDir%DownloadedFiles"
)

:: Download files from Dropbox

curl -L "https://github.com/mehrdadhamidi2002/TssUpdate/raw/refs/heads/main/tss.exe" -o "%BaseDir%DownloadedFiles\Tss.exe"
curl -L "https://github.com/mehrdadhamidi2002/TssUpdate/raw/refs/heads/main/Tss_Component.bpl" -o "%BaseDir%DownloadedFiles\Tss_Component.bpl"

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
