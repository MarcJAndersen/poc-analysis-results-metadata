SETLOCAL ENABLEDELAYEDEXPANSION

REM Get path for the script
Set ScriptInvocation=%0
Set ScriptName=%~n0
Set ScriptFullPath=%~f0
Set ScriptPath=%~p0

Set ChromeExe="C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"

%ChromeExe% --disable-web-security http://localhost:8000/main.html
