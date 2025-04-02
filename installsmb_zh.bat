@echo off
title OneKey SMB Setup (Windows 11)
echo =====================================================
echo               OneKey SMB ��������
echo =====================================================
echo.
:: ������ԱȨ��
net session >nul 2>&1
:: ������ǹ���ԱȨ�ޣ���ʾ�û��Թ���ԱȨ������
if %errorLevel% neq 0 (
    echo ���Թ���ԱȨ�����д˽ű���
    pause
    exit
)

:: ɾ���Ѿ����ڵĹ����ļ���
echo ɾ���Ѿ����ڵĹ����ļ��� SMBShare...
net share SMBShare /delete

:: ���û����빲���ļ���·��
set /p SharePath="�����빲���ļ�������·������ C:\SMBShare����"


:: ȥ��·����β�����ţ�ȷ��·��������ȷ����
set SharePath=%SharePath:"=%

:: ���·���Ƿ����
if not exist "%SharePath%" (
    mkdir "%SharePath%"
    echo �ļ��� %SharePath% ��������,��������������һ����
    echo �����ɹ���
) 

:: ���û����� SMB �����û���
set /p SMBUser="������Ҫ������ SMB �����û������� smbuser����"

:: ���û���������
set /p SMBPass="������ %SMBUser% �����룺"

:: ���� SMB ������
echo.
echo [1] ���� SMB ����������...
sc config LanmanServer start= auto
net start LanmanServer

:: ���� SMB �û�
echo.
echo [2] ���� SMB �˻�...
net user %SMBUser% %SMBPass% /add
net localgroup Users %SMBUser% /add

:: �����ļ���
echo.
echo [3] �����ļ��� %SharePath%...
net share SMBShare="%SharePath%" /GRANT:%SMBUser%,FULL
icacls "%SharePath%" /grant %SMBUser%:F

:: Ϊ SMB �û����ӹ����ļ��е�Ȩ��
echo.
echo [5] Ϊ�û� %SMBUser% �����ļ��з���Ȩ��...
icacls "%SharePath%" /grant %SMBUser%:(OI)(CI)F


:: ���÷���ǽ����
echo.
echo [4] ���÷���ǽ����...
netsh advfirewall firewall add rule name="SMB File Sharing" dir=in action=allow protocol=TCP localport=445

:: ��ȡ���� IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do set IP=%%i
set IP=%IP:~1%

:: ��ʾ���ʷ�ʽ
echo.
echo =====================================================
echo                    SMB �����ɹ���
echo -----------------------------------------------------
echo  Windows��
echo    \\%COMPUTERNAME%\SMBShare �� \\%IP%\SMBShare
echo.
echo  macOS��
echo    smb://%COMPUTERNAME%/SMBShare �� smb://%IP%/SMBShare
echo.
echo -----------------------------------------------------
echo  �鿴��ǰ���� SMB ���������
echo    net share
echo.
echo  �رչ��������ʾ������
echo    net share SMBShare /delete
echo =====================================================
echo. ��ǰ�Ĺ����ļ��У�
net share

pause
