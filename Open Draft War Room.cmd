@echo off
rem Starts a tiny local web server in this folder and opens the war room.
rem Serving over http avoids any browser restriction on pages opened from disk.
cd /d "%~dp0"
start "Draft War Room server" /min cmd /c python -m http.server 8777
timeout /t 2 >nul
start "" http://localhost:8777/index.html
echo.
echo  Draft War Room is opening at http://localhost:8777
echo  Leave the minimised "Draft War Room server" window running during the draft.
echo  Close that window when you are done.
echo.
timeout /t 6 >nul
