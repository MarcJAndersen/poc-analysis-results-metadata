@SETLOCAL ENABLEDELAYEDEXPANSION

REM Get path for the script
@Set ScriptInvocation=%0
@Set ScriptName=%~n0
@Set ScriptFullPath=%~f0
@Set ScriptPath=%~p0

@cd/d %ScriptPath%
REM c:\Python35\python.exe -m http.server
c:\ProgramData\Anaconda3\python.exe -m http.server
echo Open http://localhost:8000/main.html
echo Note: enable CORS
