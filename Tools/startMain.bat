@echo off
REM ������ ���� üũ �� ��û
cd /d %~dp0
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ������ ������ �ʿ��մϴ�. �ٽ� ������ �������� ���� ��...
    powershell start-process "%~f0" -verb runas
    exit
)

REM �ڵ� ������ ���� (EUC-KR)
chcp 949 >nul

:start
ECHO ========================================
ECHO          ��Ʈ��ũ �������� ����
ECHO ========================================
ECHO 1. ���ͳ� ���� ���� Ȯ��
ECHO 2. IP �ּ� ����
ECHO 3. Ping �׽�Ʈ ����
ECHO 4. DNS ĳ�� �ʱ�ȭ
ECHO 5. ��Ʈ��ũ ����� �缳��
ECHO 6. �� ��ġ�� IP ���� Ȯ��
ECHO 7. IP �ּ� �����ϱ�
ECHO 8. ����� IP �ּ� �����ϱ�
ECHO 9. ���ͳ� �ӵ� �׽�Ʈ
ECHO 10. ��Ʈ��ũ ���� ��� Ȯ��
ECHO 11. ���α׷� ����
ECHO ========================================
SET /P choice="���ϴ� ����� ��ȣ�� �Է��ϼ���: "

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

ECHO �߸��� �Է��Դϴ�. �ٽ� �Է��ϼ���.
GOTO start

:checkInternet
ECHO ���ͳ� ���� ���¸� Ȯ���ϰ� �ֽ��ϴ�...
PING -n 1 www.google.com >nul
IF %ERRORLEVEL% EQU 0 (
    ECHO ���ͳ��� ����Ǿ� �ֽ��ϴ�.
) ELSE (
    ECHO ���ͳ� ������ Ȯ���� �� �����ϴ�. ���ͳ� ������ Ȯ���� �ּ���.
)
PAUSE
GOTO start

:pingTest
ECHO ����� IP ��Ͽ��� �׽�Ʈ����, ���ο� IP�� �Է����� �����ϼ���.
ECHO 1. ����� IP ��Ͽ��� �����ϱ�
ECHO 2. ���ο� IP �Է��ϱ�
SET /P pingChoice="�����ϼ��� (1 �Ǵ� 2): "

IF "%pingChoice%"=="1" GOTO pingFromList
IF "%pingChoice%"=="2" GOTO pingNewIP

ECHO �߸��� �Է��Դϴ�. �ٽ� �õ��� �ּ���.
PAUSE
GOTO pingTest

:pingFromList
IF NOT EXIST iplist.txt (
    ECHO ����� IP ����� �����ϴ�. ���� IP �ּҸ� ������ �ּ���.
    PAUSE
    GOTO start
)

ECHO ����� IP ���:
SETLOCAL ENABLEDELAYEDEXPANSION
SET /A count=1
FOR /F "tokens=1,2,3,4 delims=," %%a IN (iplist.txt) DO (
    ECHO !count!: ��Ʈ��ũ �����: %%a, IP �ּ�: %%b
    SET "adapter_!count!=%%a"
    SET "ip_!count!=%%b"
    SET /A count+=1
)

SET /P selection="�� �׽�Ʈ�� IP ��ȣ�� �Է��ϼ��� (���ư����� 0 �Է�): "

IF "%selection%"=="0" GOTO start
IF "!adapter_%selection%!"=="" (
    ECHO �߸��� �����Դϴ�. �ùٸ� ��ȣ�� �Է��� �ּ���.
    PAUSE
    GOTO pingFromList
)

ECHO ������ IP �ּ� %ip_%selection% �� ���� ������ ��...
PING %ip_%selection%
ECHO �׽�Ʈ�� �Ϸ�Ǿ����ϴ�. ���� ��踦 Ȯ���� �ּ���.
PAUSE
GOTO start

:pingNewIP
SET /P testip="Ping �׽�Ʈ�� IP �ּҸ� �Է��ϼ��� (���ư����� 0 �Է�): "
IF "%testip%"=="0" GOTO start
ECHO %testip% �� ���� ������ ��...

REM ping ��ɾ� ���� �� ��� ���
PING %testip%

ECHO �׽�Ʈ�� �Ϸ�Ǿ����ϴ�. ���� ��踦 Ȯ���� �ּ���.
PAUSE
GOTO start

:saveIP
ECHO ��Ʈ��ũ ����� �̸��� ���ο� IP �ּҸ� �Է��Ͽ� �����մϴ�.
SET /P adapter="��Ʈ��ũ ����� �̸��� �Է��ϼ���: "
SET /P newip="���ο� IP �ּ� (��: xxx.xxx.xxx.xxx): "
SET /P subnet="����� ����ũ�� �Է��ϼ���: "
SET /P gateway="�⺻ ����Ʈ���̸� �Է��ϼ���: "

REM IP �ּ� ���� Ȯ�� (�ܼ� ���� üũ)
ECHO %newip% | FINDSTR /R "^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$" >nul
IF %ERRORLEVEL% NEQ 0 (
    ECHO ��ȿ���� ���� IP �ּ� �����Դϴ�. �ùٸ� �������� �ٽ� �Է��� �ּ���.
    PAUSE
    GOTO saveIP
)

REM �ùٸ� �������� IP ������ ����
ECHO %adapter%,%newip%,%subnet%,%gateway% >> iplist.txt
ECHO IP �ּҰ� ���������� ����Ǿ����ϴ�.
PAUSE
GOTO start

:listIPManage
IF NOT EXIST iplist.txt (
    ECHO ����� IP ����� �����ϴ�. ���� IP �ּҸ� ������ �ּ���.
    PAUSE
    GOTO start
)

ECHO ����� IP ���:
SETLOCAL ENABLEDELAYEDEXPANSION
SET /A count=1
FOR /F "tokens=1,2,3,4 delims=," %%a IN (iplist.txt) DO (
    ECHO !count!: ��Ʈ��ũ �����: %%a, IP �ּ�: %%b
    SET "adapter_!count!=%%a"
    SET "ip_!count!=%%b"
    SET "subnet_!count!=%%c"
    SET "gateway_!count!=%%d"
    SET /A count+=1
)

SET /P selection="������ IP ��ȣ�� �Է��ϼ��� (���ư����� 0 �Է�): "

IF "%selection%"=="0" GOTO start
IF "!adapter_%selection%!"=="" (
    ECHO �߸��� �����Դϴ�. �ùٸ� ��ȣ�� �Է��� �ּ���.
    PAUSE
    GOTO listIPManage
)

ECHO ������ �۾�:
ECHO 1. ���ư���
ECHO 2. IP �ּ� �׽�Ʈ�ϱ� (Ping)
ECHO 3. IP �����ϱ�
SET /P action="�۾��� �����ϼ���: "

IF "%action%"=="1" GOTO listIPManage
IF "%action%"=="2" GOTO pingSelectedIP
IF "%action%"=="3" GOTO modifySelectedIP

ECHO �߸��� �Է��Դϴ�. �ٽ� �õ��� �ּ���.
PAUSE
GOTO listIPManage

:pingSelectedIP
ECHO ������ IP �ּ� %ip_%selection% �� ���� ������ ��...
PING %ip_%selection%
ECHO �׽�Ʈ�� �Ϸ�Ǿ����ϴ�. ���� ��踦 Ȯ���� �ּ���.
PAUSE
GOTO listIPManage

:modifySelectedIP
ECHO ����� IP �ּҸ� �����ϰų� ���� �Է��� �� �ֽ��ϴ�.
ECHO 1. ����� IP ��Ͽ��� �����Ͽ� �����ϱ�
ECHO 2. ���ο� IP �Է��ϱ�
SET /P modifyChoice="�����ϼ��� (1 �Ǵ� 2): "

IF "%modifyChoice%"=="1" GOTO modifyFromList
IF "%modifyChoice%"=="2" GOTO modifyNewIP

ECHO �߸��� �Է��Դϴ�. �ٽ� �õ��� �ּ���.
PAUSE
GOTO modifySelectedIP

:modifyFromList
ECHO IP �ּҸ� ���� IP�� �������� ���� IP�� �������� �����ϼ���.
ECHO 1. ���� IP ����
ECHO 2. ���� IP ����
SET /P ipType="�����ϼ��� (1 �Ǵ� 2): "

IF "%ipType%"=="1" GOTO setStaticIP
IF "%ipType%"=="2" GOTO setDHCP

ECHO �߸��� �Է��Դϴ�. �ٽ� �õ��� �ּ���.
PAUSE
GOTO modifyFromList

:setStaticIP
SET /P newip="���ο� IP �ּҸ� �Է��ϼ���: "
ECHO IP �ּҸ� %newip% �� ���� IP�� ���� ��...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter_%selection%" STATIC %newip% %subnet_%selection% %gateway_%selection%
IF %ERRORLEVEL% EQU 0 (
    ECHO IP �ּҰ� ���������� ����Ǿ����ϴ�.
) ELSE (
    ECHO IP �ּ� ���濡 �����߽��ϴ�. �Է��� ������ Ȯ���� �ּ���.
)
PAUSE
GOTO listIPManage

:setDHCP
ECHO IP �ּҸ� ���� IP�� ���� ��...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter_%selection%" SOURCE=DHCP
IF %ERRORLEVEL% EQU 0 (
    ECHO ���� IP ������ ���������� �Ϸ�Ǿ����ϴ�.
) ELSE (
    ECHO ���� IP ������ �����߽��ϴ�. �Է��� ������ Ȯ���� �ּ���.
)
PAUSE
GOTO listIPManage

:modifyNewIP
SET /P adapter="��Ʈ��ũ ����� �̸��� �Է��ϼ���: "
ECHO IP �ּҸ� ���� IP�� �������� ���� IP�� �������� �����ϼ���.
ECHO 1. ���� IP ����
ECHO 2. ���� IP ����
SET /P ipType="�����ϼ��� (1 �Ǵ� 2): "

IF "%ipType%"=="1" GOTO setStaticIPNew
IF "%ipType%"=="2" GOTO setDHCPNew

ECHO �߸��� �Է��Դϴ�. �ٽ� �õ��� �ּ���.
PAUSE
GOTO modifyNewIP

:setStaticIPNew
SET /P newip="���ο� IP �ּҸ� �Է��ϼ���: "
SET /P subnet="����� ����ũ�� �Է��ϼ���: "
SET /P gateway="�⺻ ����Ʈ���̸� �Է��ϼ���: "
ECHO IP �ּҸ� %newip% �� ���� IP�� ���� ��...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter%" STATIC %newip% %subnet% %gateway%
IF %ERRORLEVEL% EQU 0 (
    ECHO IP �ּҰ� ���������� ����Ǿ����ϴ�.
) ELSE (
    ECHO IP �ּ� ���濡 �����߽��ϴ�. �Է��� ������ Ȯ���� �ּ���.
)
PAUSE
GOTO start

:setDHCPNew
ECHO IP �ּҸ� ���� IP�� ���� ��...
NETSH INTERFACE IP SET ADDRESS NAME="%adapter%" SOURCE=DHCP
IF %ERRORLEVEL% EQU 0 (
    ECHO ���� IP ������ ���������� �Ϸ�Ǿ����ϴ�.
) ELSE (
    ECHO ���� IP ������ �����߽��ϴ�. �Է��� ������ Ȯ���� �ּ���.
)
PAUSE
GOTO start

:showIPInfo
ECHO �� ��ġ�� IP ������ Ȯ���ϰ� �ֽ��ϴ�...
IPCONFIG /ALL | FINDSTR /R /C:"IPv4" /C:"����� ����ũ" /C:"�⺻ ����Ʈ����" /C:"DNS"
PAUSE
GOTO start

:flushDNS
ECHO DNS ĳ�ø� �ʱ�ȭ�ϰ� �ֽ��ϴ�...
IPCONFIG /FLUSHDNS
ECHO DNS ĳ�ð� ���������� �ʱ�ȭ�Ǿ����ϴ�.
PAUSE
GOTO start

:resetAdapter
ECHO ��Ʈ��ũ ����͸� �缳���ϰ� �ֽ��ϴ�...
SET /P adapter="�缳���� ��Ʈ��ũ ����� �̸��� �Է��ϼ���: "
NETSH INTERFACE SET INTERFACE "%adapter%" ADMIN=disable
TIMEOUT /T 5 >nul
NETSH INTERFACE SET INTERFACE "%adapter%" ADMIN=enable
ECHO ��Ʈ��ũ ����Ͱ� �缳���Ǿ����ϴ�.
PAUSE
GOTO start

:modifyIP
ECHO ����� IP ��Ͽ��� �����Ͽ� ��ü ������ �����ϰų� IP �ּҸ� ������ �� �ֽ��ϴ�.
GOTO listIPManage

:changeOnlyIP
ECHO ����� IP ��Ͽ��� IP �ּҸ� ��������, ��ü ������ �������� �����ϼ���.
GOTO listIPManage

:speedTest
ECHO ���ͳ� �ӵ��� �׽�Ʈ�ϰ� �ֽ��ϴ�...
REM ���ͳ� �ӵ� �׽�Ʈ (�߰� ��� �ʿ� �� ����)
ECHO ���ͳ� �ӵ� �׽�Ʈ�� ������ ������ ����ϰų� ������ ����Ʈ��� �ʿ��մϴ�.
PAUSE
GOTO start

:connectionLog
ECHO ��Ʈ��ũ ���� ����� Ȯ���ϰ� �ֽ��ϴ�...
NETSH WLAN SHOW INTERFACE
PAUSE
GOTO start

:end
ECHO ���α׷��� �����մϴ�. �̿��� �ּż� �����մϴ�.
PAUSE
