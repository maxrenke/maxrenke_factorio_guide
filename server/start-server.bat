@echo off
REM Start the Factorio Guide local sync server (double-click to run).
setlocal
set HERE=%~dp0

where python >nul 2>nul
if %ERRORLEVEL%==0 (
    python "%HERE%serve.py" %*
    goto :eof
)
where py >nul 2>nul
if %ERRORLEVEL%==0 (
    py "%HERE%serve.py" %*
    goto :eof
)
echo Python not found on PATH. Install Python 3 from https://python.org and retry.
pause
