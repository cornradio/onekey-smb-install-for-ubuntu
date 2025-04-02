@echo off
title OneKey SMB Setup (Windows 11)
echo =====================================================
echo                 OneKey SMB Share Configuration
echo =====================================================
echo.

:: Check for administrator privileges
net session >nul 2>&1
:: If not administrator, prompt user to run as administrator
if %errorLevel% neq 0 (
    echo Please run this script as an administrator!
    pause
    exit
)

:: Delete existing shared folder
echo Deleting existing shared folder SMBShare...
net share SMBShare /delete

:: Prompt user for the share folder path
set /p SharePath="Enter the full path of the share folder (e.g., C:\SMBShare): "

:: Remove quotes from path, ensure path is correctly parsed
set SharePath=%SharePath:"=%

:: Check if the path exists
if not exist "%SharePath%" (
    mkdir "%SharePath%"
    echo Folder %SharePath% does not exist, creating it for you!
    echo Creation successful!
)

:: Prompt user for SMB access username
set /p SMBUser="Enter the SMB access username to create (e.g., smbuser): "

:: Prompt user for password
set /p SMBPass="Enter the password for %SMBUser%: "

:: Enable SMB server
echo.
echo [1] Enabling SMB server feature...
sc config LanmanServer start= auto
net start LanmanServer

:: Create SMB user
echo.
echo [2] Creating SMB account...
net user %SMBUser% %SMBPass% /add
net localgroup Users %SMBUser% /add

:: Share the folder
echo.
echo [3] Sharing folder %SharePath%...
net share SMBShare="%SharePath%" /GRANT:%SMBUser%,FULL
icacls "%SharePath%" /grant %SMBUser%:F

:: Add folder permissions for SMB user
echo.
echo [5] Adding folder access permissions for user %SMBUser%...
icacls "%SharePath%" /grant %SMBUser%:(OI)(CI)F

:: Configure firewall rules
echo.
echo [4] Configuring firewall rules...
netsh advfirewall firewall add rule name="SMB File Sharing" dir=in action=allow protocol=TCP localport=445

:: Get local IP address
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do set IP=%%i
set IP=%IP:~1%

:: Display access instructions
echo.
echo =====================================================
echo                         SMB Share Successful!
echo -----------------------------------------------------
echo  Windows:
echo   \\%COMPUTERNAME%\SMBShare or \\%IP%\SMBShare
echo.
echo  macOS:
echo   smb://%COMPUTERNAME%/SMBShare or smb://%IP%/SMBShare
echo.
echo -----------------------------------------------------
echo  Command to view all current SMB shares:
echo   net share
echo.
echo  Command to close a share (example):
echo   net share SMBShare /delete
echo =====================================================
echo Current shared folders:
net share

pause