@echo off
REM 관리자 권한 체크 및 요청
cd /d %~dp0
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo 관리자 권한이 필요합니다. 다시 관리자 권한으로 실행 중...
    powershell start-process "%~f0" -verb runas
    exit
)

REM 코드 페이지 설정 (EUC-KR)
chcp 949 >nul

:start
ECHO ========================================
ECHO          네트워크 유지보수 도구
ECHO ========================================
ECHO 1. 인터넷 연결 상태 확인
ECHO 2. IP 주소 변경
ECHO 3. Ping 테스트 수행
ECHO 4. DNS 캐시 초기화
ECHO 5. 네트워크 어댑터 재설정
ECHO 6. 내 장치의 IP 정보 확인
ECHO 7. IP 주소 저장하기
ECHO 8. 저장된 IP 주소 관리하기
ECHO 9. 인터넷 속도 테스트
ECHO 10. 네트워크 연결 기록 확인
ECHO 11. 프로그램 종료
ECHO ========================================
SET /P choice="원하는 기능의 번호를 입력하세요: "

IF "%choice%"=="1" GOTO checkInternet
IF "%choice%"=="2" GOTO modifyIP
IF "%choice%"=="3" GOTO pingTest
IF "%choice%"=="4" GOTO flushDNS
IF "%choice%"=="5" GOTO resetAdapter
IF "%choice%"=="6" GOTO showIPInfo
IF "%choice%"=="7" GOTO saveIP
IF "%choice%"=="8" GOTO listIPManage
IF "%choice%"=="9" GOTO speedTest
IF "%choice%"=="10" GOTO connectionLog
IF "%choice%"=="11" GOTO end

ECHO 잘못된 입력입니다. 다시 입력하세요.
GOTO start

:checkInternet
ECHO 인터넷 연결 상태를 확인하고 있습니다...
PING -n 1 www.google.com >nul
IF %ERRORLEVEL% EQU 0 (
    ECHO 인터넷이 연결되어 있습니다.
) ELSE (
    ECHO 인터넷 연결을 확인할 수 없습니다. 인터넷 설정을 확인해 주세요.
)
PAUSE
GOTO start

:pingTest
ECHO 저장된 IP 목록에서 테스트할지, 새로운 IP를 입력할지 선택하세요.
ECHO 1. 저장된 IP 목록에서 선택하기
ECHO 2. 새로운 IP 입력하기
SET /P pingChoice="선택하세요 (1 또는 2): "

IF "%pingChoice%"=="1" GOTO pingFromList
IF "%pingChoice%"=="2" GOTO pingNewIP

ECHO 잘못된 입력입니다. 다시 시도해 주세요.
PAUSE
GOTO pingTest

:pingFromList
IF NOT EXIST iplist.txt (
    ECHO 저장된 IP 목록이 없습니다. 먼저 IP 주소를 저장해 주세요.
    PAUSE
    GOTO start
)

ECHO 저장된 IP 목록:
SETLOCAL ENABLEDELAYEDEXPANSION
SET /A count=1
FOR /F "tokens=1,2,3,4 delims=," %%a IN (iplist.txt) DO (
    ECHO !count!: 네트워크 어댑터: %%a, IP 주소: %%b
    SET "adapter_!count!=%%a"
    SET "ip_!count!=%%b"
    SET /A count+=1
)

SET /P selection="핑 테스트할 IP 번호를 입력하세요 (돌아가려면 0 입력): "

IF "%selection%"=="0" GOTO start
IF "!adapter_%selection%!"=="" (
    ECHO 잘못된 선택입니다. 올바른 번호를 입력해 주세요.
    PAUSE
    GOTO pingFromList
)

ECHO 선택한 IP 주소 %ip_%selection% 에 핑을 보내는 중...
PING %ip_%selection%
ECHO 테스트가 완료되었습니다. 위의 통계를 확인해 주세요.
PAUSE
GOTO start

:pingNewIP
SET /P testip="Ping 테스트할 IP 주소를 입력하세요 (돌아가려면 0 입력): "
IF "%testip%"=="0" GOTO start
ECHO %testip% 에 핑을 보내는 중...

REM ping 명령어 실행 및 통계 출력
PING %testip%

ECHO 테스트가 완료되었습니다. 위의 통계를 확인해 주세요.
PAUSE
GOTO start

:saveIP
ECHO 네트워크 어댑터 이름과 새로운 IP 주소를 입력하여 저장합니다.
SET /P adapter="네트워크 어댑터 이름을 입력하세요: "
SET /P newip="새로운 IP 주소 (예: xxx.xxx.xxx.xxx): "
SET /P subnet="서브넷 마스크를 입력하세요: "
SET /P gateway="기본 게이트웨이를 입력하세요: "

REM IP 주소 형식 확인 (단순 형식 체크)
ECHO %newip% | FINDSTR /R "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$" >nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO 유효하지 않은 IP 주소 형식입니다. 올바른 형식으로 다시 입력해 주세요.
    PAUSE
    GOTO saveIP
)

REM 올바른 형식으로 IP 정보를 저장
ECHO %adapter%,%newip%,%subnet%,%gateway% >> iplist.txt
ECHO IP 주소가 성공적으로 저장되었습니다.
PAUSE
GOTO start

:listIPManage
IF NOT EXIST iplist.txt (
    ECHO 저장된 IP 목록이 없습니다. 먼저 IP 주소를 저장해 주세요.
    PAUSE
    GOTO start
)

ECHO 저장된 IP 목록:
SETLOCAL ENABLEDELAYEDEXPANSION
SET /A count=1
FOR /F "tokens=1,2,3,4 delims=," %%a IN (iplist.txt) DO (
    ECHO !count!: 네트워크 어댑터: %%a, IP 주소: %%b
    SET "adapter_!count!=%%a"
    SET "ip_!count!=%%b"
    SET "subnet_!count!=%%c"
    SET "gateway_!count!=%%d"
    SET /A count+=1
)

SET /P selection="관리할 IP 번호를 입력하세요 (돌아가려면 0 입력): "

IF "%selection%"=="0" GOTO start
IF "!adapter_%selection%!"=="" (
    ECHO 잘못된 선택입니다. 올바른 번호를 입력해 주세요.
    PAUSE
    GOTO listIPManage
)

ECHO 선택한 작업:
ECHO 1. 돌아가기
ECHO 2. IP 주소 테스트하기 (Ping)
ECHO 3. IP 변경하기
SET /P action="작업을 선택하세요: "

IF "%action%"=="1" GOTO listIPManage
IF "%action%"=="2" GOTO pingSelectedIP
IF "%action%"=="3" GOTO modifySelectedIP

ECHO 잘못된 입력입니다. 다시 시도해 주세요.
PAUSE
GOTO listIPManage

:pingSelectedIP
ECHO 선택한 IP 주소 %ip_%selection% 에 핑을 보내는 중...
PING %ip_%selection%
ECHO 테스트가 완료되었습니다. 위의 통계를 확인해 주세요.
PAUSE
GOTO listIPManage

:modifySelectedIP
ECHO 저장된 IP 주소를 변경하거나 새로 입력할 수 있습니다.
ECHO 1. 저장된 IP 목록에서 선택하여 변경하기
ECHO 2. 새로운 IP 입력하기
SET /P modifyChoice="선택하세요 (1 또는 2): "

IF "%modifyChoice%"=="1" GOTO modifyFromList
IF "%modifyChoice%"=="2" GOTO modifyNewIP

ECHO 잘못된 입력입니다. 다시 시도해 주세요.
PAUSE
GOTO modifySelectedIP

:modifyFromList
ECHO IP 주소를 고정 IP로 설정할지 유동 IP로 설정할지 선택하세요.
ECHO 1. 고정 IP 설정
ECHO 2. 유동 IP 설정
SET /P ipType="선택하세요 (1 또는 2): "

IF "%ipType%"=="1" GOTO setStaticIP
IF "%ipType%"=="2" GOTO setDHCP

ECHO 잘못된 입력입니다. 다시 시도해 주세요.
PAUSE
GOTO modifyFromList

:setStaticIP
SET /P newip="새로운 IP 주소를 입력하세요: "
ECHO IP 주소를 %newip% 로 고정 IP로 설정 중...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter_%selection%" STATIC %newip% %subnet_%selection% %gateway_%selection%
IF %ERRORLEVEL% EQU 0 (
    ECHO IP 주소가 성공적으로 변경되었습니다.
) ELSE (
    ECHO IP 주소 변경에 실패했습니다. 입력한 정보를 확인해 주세요.
)
PAUSE
GOTO listIPManage

:setDHCP
ECHO IP 주소를 유동 IP로 설정 중...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter_%selection%" SOURCE=DHCP
IF %ERRORLEVEL% EQU 0 (
    ECHO 유동 IP 설정이 성공적으로 완료되었습니다.
) ELSE (
    ECHO 유동 IP 설정에 실패했습니다. 입력한 정보를 확인해 주세요.
)
PAUSE
GOTO listIPManage

:modifyNewIP
SET /P adapter="네트워크 어댑터 이름을 입력하세요: "
ECHO IP 주소를 고정 IP로 설정할지 유동 IP로 설정할지 선택하세요.
ECHO 1. 고정 IP 설정
ECHO 2. 유동 IP 설정
SET /P ipType="선택하세요 (1 또는 2): "

IF "%ipType%"=="1" GOTO setStaticIPNew
IF "%ipType%"=="2" GOTO setDHCPNew

ECHO 잘못된 입력입니다. 다시 시도해 주세요.
PAUSE
GOTO modifyNewIP

:setStaticIPNew
SET /P newip="새로운 IP 주소를 입력하세요: "
SET /P subnet="서브넷 마스크를 입력하세요: "
SET /P gateway="기본 게이트웨이를 입력하세요: "
ECHO IP 주소를 %newip% 로 고정 IP로 설정 중...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter%" STATIC %newip% %subnet% %gateway%
IF %ERRORLEVEL% EQU 0 (
    ECHO IP 주소가 성공적으로 변경되었습니다.
) ELSE (
    ECHO IP 주소 변경에 실패했습니다. 입력한 정보를 확인해 주세요.
)
PAUSE
GOTO start

:setDHCPNew
ECHO IP 주소를 유동 IP로 설정 중...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter%" SOURCE=DHCP
IF %ERRORLEVEL% EQU 0 (
    ECHO 유동 IP 설정이 성공적으로 완료되었습니다.
) ELSE (
    ECHO 유동 IP 설정에 실패했습니다. 입력한 정보를 확인해 주세요.
)
PAUSE
GOTO start

:showIPInfo
ECHO 내 장치의 IP 정보를 확인하고 있습니다...
IPCONFIG /ALL | FINDSTR /R /C:"IPv4" /C:"서브넷 마스크" /C:"기본 게이트웨이" /C:"DNS"
PAUSE
GOTO start

:flushDNS
ECHO DNS 캐시를 초기화하고 있습니다...
IPCONFIG /FLUSHDNS
ECHO DNS 캐시가 성공적으로 초기화되었습니다.
PAUSE
GOTO start

:resetAdapter
ECHO 네트워크 어댑터를 재설정하고 있습니다...
SET /P adapter="재설정할 네트워크 어댑터 이름을 입력하세요: "
NETSH INTERFACE SET INTERFACE "%adapter%" ADMIN=disable
TIMEOUT /T 5 >nul
NETSH INTERFACE SET INTERFACE "%adapter%" ADMIN=enable
ECHO 네트워크 어댑터가 재설정되었습니다.
PAUSE
GOTO start

:modifyIP
ECHO 저장된 IP 목록에서 선택하여 전체 정보를 변경하거나 IP 주소만 변경할 수 있습니다.
GOTO listIPManage

:changeOnlyIP
ECHO 저장된 IP 목록에서 IP 주소만 변경할지, 전체 정보를 변경할지 선택하세요.
GOTO listIPManage

:speedTest
ECHO 인터넷 속도를 테스트하고 있습니다...
REM 인터넷 속도 테스트 (추가 기능 필요 시 구현)
ECHO 인터넷 속도 테스트는 관리자 도구를 사용하거나 별도의 소프트웨어가 필요합니다.
PAUSE
GOTO start

:connectionLog
ECHO 네트워크 연결 기록을 확인하고 있습니다...
NETSH WLAN SHOW INTERFACE
PAUSE
GOTO start

:end
ECHO 프로그램을 종료합니다. 이용해 주셔서 감사합니다.
PAUSE
