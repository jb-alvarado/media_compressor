@echo off
 
:: mp4 Quality -------------------------------
set quality=22 
:: ( quality: 20-26 useful, smaler better quality ) 
 
set GOPSize=50
:: ( GOPSize: short clips needs smaler value )  
 
set fps=
:: ( fps: frames per second )  
 
:: Install Path ----------------------------
set "InstallPath=C:\cmdTools"
:: ---------------------------------------------
 
if exist %InstallPath% GOTO checkffmpeg
echo --------------------------------------------------------
echo.
echo - Bitte Ornder anlegen und Tools hinein Kopieren
echo.
echo - (z.B. C:\cmdTools)
echo.
echo - Pfad bei "InstallPath" in Batch File anpassen
echo.
echo - Tools: ffmpeg.exe(von FFmpeg); mp4box.exe
echo.
echo --------------------------------------------------------
pause
exit
  
:checkffmpeg
if exist %InstallPath%\ffmpeg.exe GOTO checkmp4box
 
echo --------------------------------------
echo.
echo - Bitte Installationspfad pruefen
echo.
echo - und FFmpeg installieren (Static Build)
echo.
echo --------------------------------------
pause
%InstallPath%\wget http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.7z
%InstallPath%\7za e ffmpeg-latest-win32-static.7z -o%InstallPath% *.exe -r -y
del ffmpeg-latest-win32-static.7z

 
:checkmp4box
if exist %InstallPath%\mp4box.exe GOTO run
 
echo --------------------------------------
echo.
echo - Bitte mp4box installieren
echo.
echo --------------------------------------
pause
%InstallPath%\wget http://kurtnoise.free.fr/mp4tools/MP4Box-0.4.6-rev2735.zip
%InstallPath%\7za e MP4Box-0.4.6-rev2735.zip -o%InstallPath% *.exe -r -y
del MP4Box-0.4.6-rev2735.zip

 
 
:run
set "input=%~1"
 
cd /d "%~dp1" 2>nul
cd /d %1 2>nul
 
set x1="%input%"
set x2="%cd%"
 
if "%input%"=="%CD%" GOTO folder
echo.
echo................................................................
echo.
echo..........converting Video-File.................................
echo.
echo................................................................
echo.
 
 
:: Video-File Compression -------------------------------
 
echo.
echo..........................Converting Video File:............................
echo.
%InstallPath%\ffmpeg.exe -i %input% -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -acodec libvo_aacenc -ab 160k -absf aac_adtstoasc -y "%~n1_x264.mp4"
 
%InstallPath%\mp4box -hint "%~n1_x264.mp4"
 
GOTO end
:: ---------------------------------------------------
 
:: Folder Compression -------------------------------
 
:folder
 
echo.
echo................................................................
echo.
echo...........converting Frame-Sequence............................
echo.
echo................................................................
echo.
 
if not "%fps%" == "" GOTO comp
set fps=25
 
:comp
 
pushd %input%
setlocal enabledelayedexpansion
set number=0
 
for %%i in (*) do (
	set /a number=number+1
	set "file=%%i"
	)
 
if %number% LSS 251 set GOPSize=50
 
set ext=%file:~-4%
call set name=%%file:%ext%=%%
set newname=%name:~0,-4%
 
if %ext% == .exr GOTO compEXR 
 
set endframe=%name:~-4%
 
set frame=%endframe:~0,-3%
 
if not %frame% == 0 GOTO 4digits
 
set frame0=%endframe:~-3%
set frame1=%endframe:~0,-2%
 
if not %frame1% == 00 GOTO 3digits
set frame2=%endframe:~-2%
set /a startframe=%frame2%-%number%+1
 
GOTO next
 
:3digits
set /a startframe=%frame0%-%number%+1
 
GOTO next
 
:4digits
set /a startframe=%endframe%-%number%+1
 
:next
 
popd
 
 
set "NewFileName=%newname%%%04d%ext%"
 
%InstallPath%\ffmpeg.exe -start_number %startframe% -i "%input%\%NewFileName%" -r %fps% -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -an -y "%input%\..\%newname%_x264.mp4"
 
%InstallPath%\mp4box -hint "%input%\..\%newname%_x264.mp4"
 
GOTO end

 
:compEXR
set /P gamma="Set Gamma Value:"
:: ( gamma: gamma correction ) 
 
set endframe=%name:~-4%
 
set frame=%endframe:~0,-3%
 
if not %frame% == 0 GOTO 4digits
 
set frame0=%endframe:~-3%
set frame1=%endframe:~0,-2%
 
if not %frame1% == 00 GOTO 3digits
set frame2=%endframe:~-2%
set /a startframe=%frame2%-%number%+1
 
GOTO next
 
:3digits
set /a startframe=%frame0%-%number%+1
 
GOTO next
 
:4digits
set /a startframe=%endframe%-%number%+1
 
:next
 
popd
 
set "NewFileName=%newname%%%04d%ext%"
 
%InstallPath%\ffmpeg.exe -start_number %startframe% -i "%input%\%NewFileName%" -r %fps% -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -an -y "%input%\..\%newname%_x264.mp4"
 
%InstallPath%\mp4box -hint "%input%\..\%newname%_x264.mp4"
 
 
 
:end
echo.
echo................................................................
echo.
echo.....................converting done............................
echo.
echo................................................................
echo.
 
ping 127.0.0.0 -n 3 >nul
echo.
echo Window close in 15
echo.
ping 127.0.0.0 -n 5 >nul
echo.
echo Window close in 10
echo.
ping 127.0.0.0 -n 5 >nul
echo.
echo Window close in 5
echo.
ping 127.0.0.0 -n 5 >nul
echo.