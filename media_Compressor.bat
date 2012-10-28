@echo off
 
::-------------------------------------------------------------------------------------
::
:: This is version 0.95 from 2012-09-16. Last modification was on 2012-10-28
:: 2012-10-28 - add HQ Avisynth Deinterlacer, Auto Level for the Codec, maxrate, bufsize and small changes
::
::-------------------------------------------------------------------------------------

:: Systemsettings -------------------------------

set preset=slow
:: ( preset defined how exactly the x264 codec work, slower better and smaller but slower: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo )

set quality=22
:: ( quality: 20-26 useful, smaller better quality )
 
 
set GOPSize=50
:: ( GOPSize: short clips needs smaller value )
 
 
set fps=
:: ( fps: frames per second )


set aacEnc=libfdk_aac
:: ( use libvo_aacenc when you have the free distributed Version from ffmpeg, or libfaac/libfdk_aac when you compile by your self )
 
set audioBit=160k
:: ( Audo Bitrate )  
 
set audioCodec=libmp3lame
:: ( libmp3lame, pcm_s24le, pcm_s16le, mp2, ac3, flac, etc. ) 
 
 
set audioExt=.mp3
:: ( .wav, .mp3, .ac3, mp2, flac, ogg, etc. ) 

 
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
echo - please install Avisynth and replace the .dll with the new one
echo - after that install also the QTGMC Plugin Pack
echo.
echo - hit key for download the installer and the .dll
echo.
echo --------------------------------------
pause
start "" "http://sourceforge.net/projects/avisynth2/files/latest/download?source=files" & start "" "http://www.mediafire.com/file/4dm34kc7tug7rrk/avisynth.7z" & start "" "http://www.mediafire.com/?mfs7bp2rprbhp22" 
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

set /a count=0
for /f "tokens=* delims= " %%a in ('dir/s/b/a-d %*') do (
set /a count+=1
)

if not %count%==2 GOTO :audiocomp

:: Multiplex and Compression -------------------------------

set muxingInput=%~x1-%~x2

set or_=
if "%muxingInput%"==".m2v-.ac3" set or_=true
if "%muxingInput%"==".ac3-.m2v" set or_=true
if "%muxingInput%"==".m2v-.mp2" set or_=true
if "%muxingInput%"==".mp2-.m2v" set or_=true
if "%muxingInput%"==".m2v-.wav" set or_=true
if "%muxingInput%"==".wav-.m2v" set or_=true
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

if not %or_%==true GOTO audiocomp

if "%~x1"==".avi" set "vidInput=%1"
if "%~x1"==".m2v" set "vidInput=%1"
if "%~x1"==".mov" set "vidInput=%1"
if "%~x1"==".mp4" set "vidInput=%1"
if "%~x1"==".mpg" set "vidInput=%1"
if "%~x1"==".mpeg" set "vidInput=%1"

set "audInput=%2"

FOR /F %%i in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%ScanType/String%%^" %vidInput%' ) do set ScanType=%%i
FOR /F %%j in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%DisplayAspectRatio/String%%^" %vidInput%' ) do set aspect=%%j
FOR /F %%k in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%Width%%^" %vidInput%' ) do set Width=%%k
FOR /F %%l in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%Height%%^" %vidInput%' ) do set Height=%%l
FOR /F %%m in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%Duration/String1%%^" %vidInput%' ) do set Duration=%%m

if %Width% LEQ 1024 (
set level=3.2
set maxrate=4M 
set bufsize=4M
)

if %Width% GEQ 1280 (
set level=4.1
set maxrate=10M 
set bufsize=10M
)

if %Width% GEQ 1920 (
set level=5.1
set maxrate=20M 
set bufsize=20M
)

echo.
echo....................................................................
echo.....multiplex and convert Video and Audio-File.....................
echo....................................................................
echo.
echo.Duration:  %Duration%
echo.Scan Type: %ScanType%
echo.Width:     %Width%
echo.Height:    %Height%
echo.Aspect:    %Aspect%
echo.
echo....................................................................
echo....................................................................
echo.

if not %ScanType%==Progressive (

if exist "%~n1.avs" del "%~n1.avs"  
echo.SetMTMode^(5, 4^) >> "%~n1.avs"
echo.LoadPlugin("C:\Program Files (x86)\AviSynth 2.5\plugins\ffms2.dll"^) >> "%~n1.avs"
echo.Import^("C:\Program Files (x86)\AviSynth 2.5\plugins\QTGMC-3.32.avsi"^) >> "%~n1.avs"
echo.A = FFAudioSource^("%audInput%"^) >> "%~n1.avs"
echo.V = FFVideoSource^("%vidInput%"^) >> "%~n1.avs"
echo.audiodub^(V,A^) >> "%~n1.avs"
echo.SetMTMode^(2^) >> "%~n1.avs"
echo.ConvertToYV12^(interlaced=true^) >> "%~n1.avs"
echo.QTGMC^( Preset="Slow", EdiThreads=2 ^) >> "%~n1.avs"
echo.SelectEven^(^) >> "%~n1.avs"

%InstallPath%\ffmpeg.exe -y -i "%~n1.avs" -aspect %Aspect% -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%~n1.h264" -c:a %aacEnc% -ab %audioBit% "%~n1.aac"
%InstallPath%\mp4box -add "%~n1.h264" -add "%~n1.aac" -hint -brand mp42 "%~n1_x264.mp4"
del "%~n1.h264" 
del "%~n1.aac" 
del "*.ffindex" 
del "%~n1.avs" 

GOTO end
) 

%InstallPath%\ffmpeg.exe -i %vidInput% -i %audInput% -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%~n1.h264" -c:a %aacEnc% -ab %audioBit% "%~n1.aac"
%InstallPath%\mp4box -add "%~n1.h264" -add "%~n1.aac" -hint -brand mp42 "%~n1_x264.mp4"
del "%~n1.h264" 
del "%~n1.aac" 

GOTO end
)

:: Audio Compression -------------------------------

:audiocomp

for %%f in (%*) do (

if "%%~xf"==".avi" GOTO :videocomp
if "%%~xf"==".AVI" GOTO :videocomp
if "%%~xf"==".mp4" GOTO :videocomp
if "%%~xf"==".MP4" GOTO :videocomp
if "%%~xf"==".avs" GOTO :videocomp
if "%%~xf"==".flv" GOTO :videocomp
if "%%~xf"==".mov" GOTO :videocomp
if "%%~xf"==".MOV" GOTO :videocomp
if "%%~xf"==".mkv" GOTO :videocomp
if "%%~xf"==".MKV" GOTO :videocomp
if "%%~xf"==".wmv" GOTO :videocomp
if "%%~xf"==".divx" GOTO :videocomp
if "%%~xf"==".mpg" GOTO :videocomp
if "%%~xf"==".MPG" GOTO :videocomp
if "%%~xf"==".mpeg" GOTO :videocomp
if "%%~xf"==".m2v" GOTO :videocomp
if "%%~xf"==".ogv" GOTO :videocomp
if "%%~xf"==".dv" GOTO :videocomp
if "%%~xf"==".vob" GOTO :videocomp
if "%%~xf"==".3gp" GOTO :videocomp
if "%%~xf"==".m2v" GOTO :videocomp

echo.
echo....................................................................
echo.
echo..........converting Audio-File....................................
echo.
echo....................................................................
echo.

%InstallPath%\ffmpeg.exe -i %%f -vn -acodec %audioCodec% -ab %audioBit% "%%~nf_%audioExt%"
)

GOTO end

:: Video Compression -------------------------------

:videocomp
Setlocal EnableDelayedExpansion 
for %%f in (%*) do (

FOR /F %%i in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%ScanType/String%%^" %%f' ) do set ScanType=%%i
FOR /F %%j in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%DisplayAspectRatio/String%%^" %%f' ) do set aspect=%%j
FOR /F %%k in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%Width%%^" %%f' ) do set Width=%%k
FOR /F %%l in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%Height%%^" %%f' ) do set Height=%%l
FOR /F %%m in ( '%InstallPath%\mediainfo --Inform^=^"Video^;%%Duration/String1%%^" %%f' ) do set Duration=%%m
FOR /F %%n in ( '%InstallPath%\mediainfo --Inform^=^"Audio^;%%StreamCount%%^" %%f' ) do set AudioStream=%%n

if !Width! LEQ 1024 (
set level=3.2
set maxrate=4M 
set bufsize=4M
)

if !Width! GEQ 1280 (
set level=4.1
set maxrate=10M 
set bufsize=10M
)

if !Width! GEQ 1920 (
set level=5.1
set maxrate=20M 
set bufsize=20M
)

echo.
echo....................................................................
echo..........converting Video-File....................................
echo....................................................................
echo.
echo.Duration:  !Duration!
echo.Scan Type: !ScanType!
echo.Width:     !Width!
echo.Height:    !Height!
echo.Aspect:    !Aspect!
echo.
echo....................................................................
echo....................................................................
echo.

if exist "%%~nf.h264" del "%%~nf.h264" 
if exist "%%~nf.aac" del "%%~nf.aac" 
if exist "%%~nf.avs" del "%%~nf.avs"  

if "!AudioStream!"=="" (

if not !ScanType!==Progressive (

echo.SetMTMode^(5, 4^) >> "%%~nf.avs"
echo.LoadPlugin("C:\Program Files (x86)\AviSynth 2.5\plugins\ffms2.dll"^) >> "%%~nf.avs"
echo.Import^("C:\Program Files (x86)\AviSynth 2.5\plugins\QTGMC-3.32.avsi"^) >> "%%~nf.avs"
echo.FFVideoSource^("%%f"^) >> "%%~nf.avs"
echo.SetMTMode^(2^) >> "%%~nf.avs"
echo.ConvertToYV12^(interlaced=true^) >> "%%~nf.avs"
echo.QTGMC^( Preset="Slow", EdiThreads=2 ^) >> "%%~nf.avs"
echo.SelectEven^(^) >> "%%~nf.avs"

%InstallPath%\ffmpeg.exe -y -i "%%~nf.avs" -aspect !Aspect! -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264"
%InstallPath%\mp4box -add "%%~nf.h264" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
del "%%f.ffindex" 
del "%%~nf.avs" 

) else (

%InstallPath%\ffmpeg.exe -i %%f -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264"
%InstallPath%\mp4box -add "%%~nf.h264" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
)

) else (

if not !ScanType!==Progressive (

echo.SetMTMode^(5, 4^) >> "%%~nf.avs"
echo.LoadPlugin("C:\Program Files (x86)\AviSynth 2.5\plugins\ffms2.dll"^) >> "%%~nf.avs"
echo.Import^("C:\Program Files (x86)\AviSynth 2.5\plugins\QTGMC-3.32.avsi"^) >> "%%~nf.avs"
echo.A = FFAudioSource^("%%f"^) >> "%%~nf.avs"
echo.V = FFVideoSource^("%%f"^) >> "%%~nf.avs"
echo.audiodub^(V,A^) >> "%%~nf.avs"
echo.SetMTMode^(2^) >> "%%~nf.avs"
echo.ConvertToYV12^(interlaced=true^) >> "%%~nf.avs"
echo.QTGMC^( Preset="Slow", EdiThreads=2 ^) >> "%%~nf.avs"
echo.SelectEven^(^) >> "%%~nf.avs"

%InstallPath%\ffmpeg.exe -y -i "%%~nf.avs" -aspect !Aspect! -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264" -c:a %aacEnc% -ab %audioBit% "%%~nf.aac"
%InstallPath%\mp4box -add "%%~nf.h264" -add "%%~nf.aac" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
del "%%~nf.aac" 
del "%%f.ffindex" 
del "%%~nf.avs" 

) else (

%InstallPath%\ffmpeg.exe -i %%f -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264" -c:a %aacEnc% -ab %audioBit% "%%~nf.aac"
%InstallPath%\mp4box -add "%%~nf.h264" -add "%%~nf.aac" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
del "%%~nf.aac" 
)
)

)

GOTO end

:: ---------------------------------------------------
 
:: Folder Compression -------------------------------
 
:folder
 
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

set /a Duration=%number%/25

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
 
FOR /F %%k in ( '%InstallPath%\mediainfo --Inform^=^"Image^;%%Width%%^" %file%' ) do set Width=%%k
FOR /F %%l in ( '%InstallPath%\mediainfo --Inform^=^"Image^;%%Height%%^" %file%' ) do set Height=%%l

if %Width% LEQ 1024 (
set level=3.2
set maxrate=4M 
set bufsize=4M
)

if %Width% GEQ 1280 (
set level=4.1
set maxrate=10M 
set bufsize=10M
)

if %Width% GEQ 1920 (
set level=5.1
set maxrate=20M 
set bufsize=20M
)

echo.
echo....................................................................
echo.....converting Frame Sequence...........................
echo....................................................................
echo.
echo.Duration:  %Duration% Seconds
echo.Width:     %Width%
echo.Height:    %Height%
echo.
echo....................................................................
echo....................................................................
echo.

%InstallPath%\ffmpeg.exe -start_number %startframe% -i "%input%\%NewFileName%" -r %fps% -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%input%\..\%newname%.h264"
%InstallPath%\mp4box -add "%input%\..\%newname%.h264" -hint -brand mp42 "%input%\..\%newname%_x264.mp4"
del "%input%\..\%newname%.h264"

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

FOR /F %%k in ( '%InstallPath%\mediainfo --Inform^=^"Image^;%%Width%%^" %file%' ) do set Width=%%k
FOR /F %%l in ( '%InstallPath%\mediainfo --Inform^=^"Image^;%%Height%%^" %file%' ) do set Height=%%l

if %Width% LEQ 1024 (
set level=3.2
set maxrate=4M 
set bufsize=4M
)

if %Width% GEQ 1280 (
set level=4.1
set maxrate=10M 
set bufsize=10M
)

if %Width% GEQ 1920 (
set level=5.1
set maxrate=20M 
set bufsize=20M
)

echo.
echo....................................................................
echo.....converting Frame Sequence...........................
echo....................................................................
echo.
echo.Duration:  %Duration% Seconds
echo.Width:     %Width%
echo.Height:    %Height%
echo.
echo....................................................................
echo....................................................................
echo.

if exist "%input%\..\%~n1_tmp.avs" del "%input%\..\%~n1_tmp.avs"

echo ImageReader^( "%input%\%var%", start=%startframe%, end=%endframe%, fps=%fps% ^, use_DevIL = true) >> "%input%\..\%~n1_tmp.avs"
echo Levels^(0,%gamma%,255,0,255^) >> "%input%\..\%~n1_tmp.avs"

%InstallPath%\ffmpeg.exe -i "%input%\..\%~n1_tmp.avs" -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%input%\..\%newname%.h264"
%InstallPath%\mp4box -add "%input%\..\%newname%.h264" -hint -brand mp42 "%input%\..\%newname%_x264.mp4"
del "%input%\..\%newname%.h264"

if exist "%input%\..\%~n1_tmp.avs" del "%input%\..\%~n1_tmp.avs"
  
:end
echo.
echo....................................................................
echo.
echo.....................converting done...............................
echo.
echo....................................................................
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