@echo off
title OneKey SMB Setup (Windows 11)
echo =====================================================
echo               OneKey SMB 共享配置
echo =====================================================
echo.
:: 检查管理员权限
net session >nul 2>&1
:: 如果不是管理员权限，提示用户以管理员权限运行
if %errorLevel% neq 0 (
    echo 请以管理员权限运行此脚本！
    pause
    exit
)

:: 删除已经存在的共享文件夹
echo 删除已经存在的共享文件夹 SMBShare...
net share SMBShare /delete >nul 2>&1

:: 让用户输入共享文件夹路径
set /p SharePath="请输入共享文件夹完整路径（如 C:\SMBShare）："


:: 去除路径首尾的引号，确保路径可以正确解析
set SharePath=%SharePath:"=%

:: 检查路径是否存在
if not exist "%SharePath%" (
    mkdir "%SharePath%"
    echo 文件夹 %SharePath% 还不存在,让我来帮您创建一个！
    echo 创建成功！
) 

:: 让用户输入 SMB 访问用户名
set /p SMBUser="请输入要创建的 SMB 访问用户名（如 smbuser）："

:: 让用户输入密码
set /p SMBPass="请输入 %SMBUser% 的密码："

:: 启用 SMB 服务器
echo.
echo [1] 启用 SMB 服务器功能...
sc config LanmanServer start= auto
net start LanmanServer

:: 创建 SMB 用户
echo.
echo [2] 创建 SMB 账户...
net user %SMBUser% %SMBPass% /add
net localgroup Users %SMBUser% /add

:: 共享文件夹
echo.
echo [3] 共享文件夹 %SharePath%...
net share SMBShare="%SharePath%" /GRANT:%SMBUser%,FULL
icacls "%SharePath%" /grant %SMBUser%:F

:: 为 SMB 用户添加共享文件夹的权限
echo.
echo [5] 为用户 %SMBUser% 添加文件夹访问权限...
icacls "%SharePath%" /grant %SMBUser%:(OI)(CI)F


:: 配置防火墙规则
echo.
echo [4] 配置防火墙规则...
netsh advfirewall firewall add rule name="SMB File Sharing" dir=in action=allow protocol=TCP localport=445

:: 获取本机 IP
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do set IP=%%i
set IP=%IP:~1%

:: 显示访问方式
echo.
echo =====================================================
echo                    SMB 共享成功！
echo -----------------------------------------------------
echo  Windows：
echo    \\%COMPUTERNAME%\SMBShare 或 \\%IP%\SMBShare
echo.
echo  macOS：
echo    smb://%COMPUTERNAME%/SMBShare 或 smb://%IP%/SMBShare
echo.
echo -----------------------------------------------------
echo  查看当前所有 SMB 共享的命令：
echo    net share
echo.
echo  关闭共享的命令（示例）：
echo    net share SMBShare /delete
echo =====================================================
echo. 当前的共享文件夹：
net share

pause