@echo off
chcp 65001 >nul
:checkInternet
REM Google 서버를 핑(ping)하여 연결 상태 확인
ping -n 1 www.google.com >nul

IF %ERRORLEVEL% EQU 0 (
    echo 인터넷이 연결되었습니다.
) ELSE (
    echo 인터넷 연결을 확인할 수 없습니다.
)

pause
