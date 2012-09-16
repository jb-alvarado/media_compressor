@echo off
 
::-------------------------------------------------------------------------------------
::
:: This is version 0.9 from 2012-09-16. Last modification was on 2012-09-16
::
::-------------------------------------------------------------------------------------

:: mp4 Quality -------------------------------
set quality=22
:: ( quality: 20-26 useful, smaller better quality )
 
 
set GOPSize=50
:: ( GOPSize: short clips needs smaller value )
 
 
set fps=
:: ( fps: frames per second )


set aacEnc=libvo_aacenc
:: ( use libvo_aacenc when you have the free distributed Version from ffmpeg, or libfaac/libfdk_aac when you compile by your self )
 
 
set audioCodec=libmp3lame
:: ( libmp3lame, pcm_s24le, pcm_s16le, mp2, ac3, flac, etc. ) 
 
 
set audioExt=.mp3
:: ( .wav, .mp3, .ac3, mp2, flac, ogg, etc. ) 


set audioBit=192k
:: ( Audo Bitrate ) 

 
:: Install Path ----------------------------
set "InstallPath=C:\cmdTools"
:: ---------------------------------------------
 
if exist %InstallPath% GOTO checkavisynth
echo --------------------------------------------------------
echo.
echo - please make folder and copy files
echo.
echo - (e.g. C:\cmdTools)
echo.
echo - ckeck path "InstallPath" in Batch File
echo.
echo - Tools: ffmpeg.exe (from FFmpeg); mp4box.exe
echo.
echo - for openEXR Sequence use avisynth and devIL.dll Version 1.7.8:
echo.
echo --------------------------------------------------------
pause
exit
  
:checkavisynth
if exist "%windir%\SysWOW64\avisynth.dll" GOTO checkdevIL
if exist "%windir%\System32\avisynth.dll" GOTO checkdevIL

echo --------------------------------------
echo.
echo - please install Avisynth
echo.
echo - hit key for download
echo.
echo --------------------------------------
pause
start "" "http://sourceforge.net/projects/avisynth2/files/latest/download?source=files"
exit

:checkdevIL
if exist "%windir%\SysWOW64\devil.dll" GOTO checkffmpeg
if exist "%windir%\System32\devil.dll" GOTO checkffmpeg

echo --------------------------------------
echo.
echo - please install devIL.dll to SysWOW64 or System32
echo.
echo - hit key for download
echo.
echo --------------------------------------
pause
start "" "https://sourceforge.net/projects/openil/files/DevIL%20Win32/1.7.8/DevIL-EndUser-x86-1.7.8.zip"
exit
  
:checkffmpeg
if exist %InstallPath%\ffmpeg.exe GOTO checkmp4box
 
echo --------------------------------------
echo.
echo - please check path and
echo.
echo - install ffmpeg
echo.
echo --------------------------------------
pause
start "" "http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.7z"
exit
 
:checkmp4box
if exist %InstallPath%\mp4box.exe GOTO run
 
echo --------------------------------------
echo.
echo - please install mp4box
echo.
echo --------------------------------------
pause
start "" "http://kurtnoise.free.fr/mp4tools/MP4Box-0.4.6-rev2735.zip"
exit
 
:run

set "input=%~1"
 
cd /d "%~dp1" 2>nul
cd /d %1 2>nul
 
set x1="%input%"
set x2="%cd%"
 
if "%input%"=="%CD%" GOTO folder

:: File Compression -------------------------------
:: temp Info: maybe extraoptions a useful e.g. -analyzeduration 500000000 etc.

set /a count=0
for /f "tokens=* delims= " %%a in ('dir/s/b/a-d %*') do (
set /a count+=1
)

if not %count%==2 GOTO :audiocomp

set muxingInput=%~x1-%~x2

set or_=
if "%muxingInput%"==".m2v-.ac3" set or_=true
if "%muxingInput%"==".ac3-.m2v" set or_=true
if "%muxingInput%"==".m2v-.mp2" set or_=true
if "%muxingInput%"==".mp2-.m2v" set or_=true

if defined or_ (

echo.
echo................................................................
echo.
echo.....multiplex and convert Video/Audio-File....................
echo.
echo................................................................
echo.

%InstallPath%\ffmpeg.exe -i %1 -i %2 -filter:v yadif -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -acodec %aacEnc% -ab 160k -absf aac_adtstoasc -y "%~n1_x264.mp4"
%InstallPath%\mp4box -hint "%~n1_x264.mp4"
GOTO end
)

if "%muxingInput%"==".avi-.wav" set or_=true
if "%muxingInput%"==".wav-.avi" set or_=true
if "%muxingInput%"==".mov-.wav" set or_=true
if "%muxingInput%"==".wav-.mov" set or_=true
if "%muxingInput%"==".avi-.mp3" set or_=true
if "%muxingInput%"==".mp3-.avi" set or_=true
if "%muxingInput%"==".mov-.mp3" set or_=true
if "%muxingInput%"==".mp3-.mov" set or_=true
if "%muxingInput%"==".mp4-.aac" set or_=true
if "%muxingInput%"==".aac-.mp4" set or_=true
if "%muxingInput%"==".mpeg-.ac3" set or_=true
if "%muxingInput%"==".ac3-.mpeg" set or_=true
if "%muxingInput%"==".mpg-.ac3" set or_=true
if "%muxingInput%"==".ac3-.mpg" set or_=true
if "%muxingInput%"==".mpeg-.mp2" set or_=true
if "%muxingInput%"==".mp2-.mpeg" set or_=true
if "%muxingInput%"==".mpg-.mp2" set or_=true
if "%muxingInput%"==".mp2-.mpg" set or_=true

if defined or_ (

echo.
echo................................................................
echo.
echo.....multiplex and convert Video/Audio-File....................
echo.
echo................................................................
echo.

%InstallPath%\ffmpeg.exe -i %1 -i %2 -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -acodec %aacEnc% -ab 160k -absf aac_adtstoasc -y "%~n1_x264.mp4"
%InstallPath%\mp4box -hint "%~n1_x264.mp4"
GOTO end
)


:audiocomp

for %%f in (%*) do (

if "%%~xf"==".avi" GOTO :videocomp
if "%%~xf"==".mp4" GOTO :videocomp
if "%%~xf"==".flv" GOTO :videocomp
if "%%~xf"==".mov" GOTO :videocomp
if "%%~xf"==".mkv" GOTO :videocomp
if "%%~xf"==".wmv" GOTO :videocomp
if "%%~xf"==".divx" GOTO :videocomp
if "%%~xf"==".mpg" GOTO :videocomp
if "%%~xf"==".mpeg" GOTO :videocomp
if "%%~xf"==".ogv" GOTO :videocomp
if "%%~xf"==".dv" GOTO :videocomp
if "%%~xf"==".vob" GOTO :videocomp
if "%%~xf"==".3gp" GOTO :videocomp
if "%%~xf"==".m2v" GOTO :videocomp

echo.
echo................................................................
echo.
echo..........converting Audio-File.................................
echo.
echo................................................................
echo.

%InstallPath%\ffmpeg.exe -i %%f -vn -acodec %audioCodec% -ab %audioBit% "%%~nf_%audioExt%"
)

GOTO end


:videocomp

echo.
echo................................................................
echo.
echo..........converting Video-File.................................
echo.
echo................................................................
echo.

for %%f in (%*) do (

%InstallPath%\ffmpeg.exe -i %%f -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -acodec %aacEnc% -ab 160k -absf aac_adtstoasc -y "%%~nf_x264.mp4"
%InstallPath%\mp4box -hint "%%~nf_x264.mp4"
)

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

set "var=%newname%%%04d%ext%"

if exist "%input%\..\%~n1_tmp.avs" del "%input%\..\%~n1_tmp.avs"

echo ImageReader^( "%input%\%var%", start=%startframe%, end=%endframe%, fps=%fps% ^, use_DevIL = true) >> "%input%\..\%~n1_tmp.avs"
echo FlipVertical^(^) >> "%input%\..\%~n1_tmp.avs"
echo Levels^(0,%gamma%,255,0,255^) >> "%input%\..\%~n1_tmp.avs"

%InstallPath%\ffmpeg.exe -i "%input%\..\%~n1_tmp.avs" -vcodec libx264 -crf %quality% -preset slow -pix_fmt yuv420p -g %GOPSize% -an -y "%input%\..\%newname%_x264.mp4"
%InstallPath%\mp4box -hint "%input%\..\%newname%_x264.mp4"

if exist "%input%\..\%~n1_tmp.avs" del "%input%\..\%~n1_tmp.avs"
 
 
 
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