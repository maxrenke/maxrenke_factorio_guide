@echo off
REM Launches the sync server detached/minimized and ignores any extra arguments
REM (a custom-protocol invocation appends the URL as an arg; we swallow it via %*).
setlocal
set HERE=%~dp0

where python >nul 2>nul
if %ERRORLEVEL%==0 (
    start "FactorioGuideServer" /min python "%HERE%serve.py" --no-browser
    goto :eof
)
where py >nul 2>nul
if %ERRORLEVEL%==0 (
    start "FactorioGuideServer" /min py "%HERE%serve.py" --no-browser
    goto :eof
)
REM Python missing: open a visible window so the user sees the error.
start "" cmd /k echo Python not found on PATH. Install Python 3 from https://python.org
