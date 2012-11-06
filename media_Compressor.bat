@echo off
Setlocal EnableDelayedExpansion 
 
color 87
title media_Compressor
 
::-------------------------------------------------------------------------------------
::
:: This is version 0.95 from 2012-09-16. Last modification was on 2012-10-29
:: 2012-10-28 - add HQ Avisynth Deinterlacer, Auto Level for the Codec, maxrate, bufsize and small changes
:: 2012-10-29 - build a new installer, most things a now automatic
::
::-------------------------------------------------------------------------------------

:: EncoderSettings -------------------------------

set preset=slow
:: ( preset defined how exactly the x264 codec work, slower better and smaller but slower: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo )

set quality=22
:: ( quality: 20-26 useful, smaller better quality )
 
set GOPSize=50
:: ( GOPSize: short clips needs smaller value )
 
set fps=
:: ( fps: frames per second, only need this for other frame rate then 25, by frame sequences )

set aacEnc=aac -strict experimental
:: ( use "aac -strict experimental" when you have the free distributed Version from ffmpeg, or libfaac/libfdk_aac when you compile by your self )
 
set audioBit=160k
:: ( Audo Bitrate )  
 
set audioCodec=libmp3lame
:: ( libmp3lame, pcm_s24le, pcm_s16le, mp2, ac3, flac, etc. ) 
 
set audioExt=.mp3
:: ( .wav, .mp3, .ac3, mp2, flac, ogg, etc. ) 



::------------------------------------------------------------------------------
:: Install Process
::------------------------------------------------------------------------------
if exist "C:\Program Files (x86)" (

set "InstallPath=C:\Program Files (x86)\BatchMediaCompressor"
set "AVSPluginFolder=C:\Program Files (x86)\AviSynth 2.5\plugins"
if exist "!InstallPath!" GOTO checkwget
MD "!InstallPath!"

) else (

set "InstallPath=C:\Program Files\BatchMediaCompressor"
set "AVSPluginFolder=C:\Program Files\AviSynth 2.5\plugins"
if exist "!InstallPath!" GOTO checkwget
MD "!InstallPath!"

)


  
:checkwget
if exist "%InstallPath%\wget.exe" GOTO check7z

echo -------------------------------------------------------------
echo.
echo - please download and copy wget.exe to:
echo - %InstallPath% 
echo.
echo - hit key for download
echo.
echo -------------------------------------------------------------
pause
start "" "http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe"
pause
if not exist "%InstallPath%\wget.exe" GOTO checkwget

:check7z
if exist "%InstallPath%\7z.exe" GOTO checkavisynth

echo -------------------------------------------------------------
echo.
echo - 7z download and install start...
echo.
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" http://downloads.sourceforge.net/project/sevenzip/7-Zip/9.22/7z922.exe
"%InstallPath%\7z922.exe" /S /D=%InstallPath%\tmp
move "%InstallPath%\tmp\7z.exe" "%InstallPath%"
move "%InstallPath%\tmp\7z.dll" "%InstallPath%"
rmdir /s /q "%InstallPath%\tmp"
del "%InstallPath%\7z922.exe"
  
:checkavisynth
if exist "%windir%\SysWOW64\avisynth.dll" GOTO checkdevIL
if exist "%windir%\System32\avisynth.dll" GOTO checkdevIL

echo -------------------------------------------------------------
echo.
echo - Avisynth will be download and install
echo.
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" http://sourceforge.net/projects/avisynth2/files/latest/download?source=files
"%InstallPath%\AviSynth_110525.exe" /S
del "%InstallPath%\AviSynth_110525.exe"
if exist "%windir%\SysWOW64\DevIL.dll" del "%windir%\SysWOW64\devil.dll"
if exist "%windir%\System32\DevIL.dll" del "%windir%\System32\devil.dll"

:checkdevIL
if exist "%windir%\SysWOW64\DevIL.dll" GOTO checkQTGMC
if exist "%windir%\System32\DevIL.dll" GOTO checkQTGMC

echo -------------------------------------------------------------
echo.
echo - Avisynth will be patched and adjusted
echo.
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" "http://downloads.sourceforge.net/project/openil/DevIL Win32/1.7.8/DevIL-EndUser-x86-1.7.8.zip"
if exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\DevIL-EndUser-x86-1.7.8.zip" -o%windir%\SysWOW64 *.dll -r -y
if not exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\DevIL-EndUser-x86-1.7.8.zip" -o%windir%\System32 *.dll -r -y

"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/avisynth.7z"
if exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\avisynth.7z" -o"%windir%\SysWOW64" *.dll -r -y
if not exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\avisynth.7z" -o"%windir%\System32" *.dll -r -y

del "%InstallPath%\DevIL-EndUser-x86-1.7.8.zip"
del "%InstallPath%\avisynth.7z"

:checkQTGMC
if exist "%AVSPluginFolder%\QTGMC-3.32.avsi" GOTO checkffms

echo -------------------------------------------------------------
echo.
echo - The deinterlacer QTGMC will be download and install
echo.
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" "http://www.spirton.com/uploads/QTGMC/QTGMC 32-bit Plugins [Vit-Mod].zip"
"%InstallPath%\wget" -P "%InstallPath%" "http://www.spirton.com/uploads/QTGMC/QTGMC-3.32.zip"
if exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%windir%\SysWOW64" fftw3.dll -r -y
if exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%windir%\SysWOW64" libfftw3f-3.dll -r -y
if not exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%windir%\System32" fftw3.dll -r -y
if not exist "%windir%\SysWOW64" "%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%windir%\System32" libfftw3f-3.dll -r -y

"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" mt_masktools-26.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" AddGrainC.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" dfttest.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" EEDI2.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" eedi3.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" FFT3DFilter.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" mvtools2.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" nnedi.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" nnedi2.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" nnedi3.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" RemoveGrainSSE2.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" RepairSSE2.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" SSE2Tools.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" TDeint.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" VerticalCleanerSSE2.dll -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip" -o"%AVSPluginFolder%" yadif.dll -r -y

"%InstallPath%\7z.exe" e "%InstallPath%\QTGMC-3.32.zip" -o"%AVSPluginFolder%" -r -y

del "%InstallPath%\QTGMC 32-bit Plugins [Vit-Mod].zip"
del "%InstallPath%\QTGMC-3.32.zip"

:checkffms
if exist "%AVSPluginFolder%\ffms2.dll" GOTO checkffmpeg

echo -------------------------------------------------------------
echo.
echo - The AVSLoader will be download and install
echo.
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" "https://ffmpegsource.googlecode.com/files/ffms-2.17.7z"
"%InstallPath%\7z.exe" e "%InstallPath%\ffms2-r722.7z" -o"%AVSPluginFolder%" ffms2-r722\FFMS2.avsi -y
"%InstallPath%\7z.exe" e "%InstallPath%\ffms2-r722.7z" -o"%AVSPluginFolder%" ffms2-r722\ffms2.dll -y
"%InstallPath%\7z.exe" e "%InstallPath%\ffms2-r722.7z" -o"%AVSPluginFolder%" ffms2-r722\ffmsindex.exe -y
del "%InstallPath%\ffms2-r722.7z"

:checkffmpeg
if exist "%InstallPath%\ffmpeg.exe" GOTO checkmp4box
 
echo -------------------------------------------------------------
echo.
echo - ffmpeg the compressor will be install
echo.
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.7z
"%InstallPath%\7z.exe" e "%InstallPath%\ffmpeg-latest-win32-static.7z" -o"%InstallPath%" *.exe -r -y
del "%InstallPath%\ffmpeg-latest-win32-static.7z"
 
:checkmp4box
if exist "%InstallPath%\mp4box.exe" GOTO checkMediaInfo 
echo -------------------------------------------------------------
echo.
echo - mp4box the multiplexer will be install
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" http://kurtnoise.free.fr/mp4tools/MP4Box-0.4.6-rev2735.zip
"%InstallPath%\7z.exe" e "%InstallPath%\mp4box-0.4.6-rev2735.zip" -o"%InstallPath%" *.exe -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\mp4box-0.4.6-rev2735.zip" -o"%InstallPath%" *.dll -r -y
del "%InstallPath%\mp4box"-0.4.6-rev2735.zip"

:checkMediaInfo
if exist "%InstallPath%\MediaInfo.exe" GOTO checklink

echo --------------------------------------
echo.
echo - MediaInfo will be install
echo.
echo --------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" "http://downloads.sourceforge.net/project/mediainfo/binary/mediainfo/0.7.61/MediaInfo_CLI_0.7.61_Windows_i386.zip"
"%InstallPath%\7z.exe" e "%InstallPath%\MediaInfo_CLI_0.7.61_Windows_i386.zip" -o"%InstallPath%" *.exe -r -y
"%InstallPath%\7z.exe" e "%InstallPath%\MediaInfo_CLI_0.7.61_Windows_i386.zip" -o"%InstallPath%" *.dll -r -y
del "%InstallPath%\MediaInfo_CLI_0.7.61_Windows_i386.zip"
 
:checklink
if exist "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\SendTo\media_Compressor.lnk" GOTO checkself
echo -------------------------------------------------------------
echo.
echo - bulding Link to the SendTo Menu
echo.
echo -------------------------------------------------------------
"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/FFmpeg.ico"

echo.Set Shell = CreateObject^("WScript.Shell"^) >> "%InstallPath%\setlink.vbs"
echo.Set link = Shell.CreateShortcut^("C:\Users\%username%\AppData\Roaming\Microsoft\Windows\SendTo\media_Compressor.lnk"^) >> "%InstallPath%\setlink.vbs"
echo.link.Arguments = "" >> "%InstallPath%\setlink.vbs"
echo.link.Description = "Compress Video or Audio Files, Framesequences or multiplex Video and Audio Files to MP4" >> "%InstallPath%\setlink.vbs"
echo.link.IconLocation = "%InstallPath%\FFmpeg.ico" >> "%InstallPath%\setlink.vbs"
echo.link.TargetPath = "%InstallPath%\media_Compressor.bat" >> "%InstallPath%\setlink.vbs"
echo.link.WindowStyle = 1 >> "%InstallPath%\setlink.vbs"
echo.link.WorkingDirectory = "%InstallPath%" >> "%InstallPath%\setlink.vbs"
echo.link.Save>> "%InstallPath%\setlink.vbs" 

cscript /nologo "%InstallPath%\setlink.vbs" 
del "%InstallPath%\setlink.vbs" 

:checkself
if exist "%InstallPath%\media_Compressor.bat" GOTO runscript
copy /Y "%~f0" "%InstallPath%"


if exist "%InstallPath%\Uninstall.bat" GOTO runscript
echo.@echo off >> "%InstallPath%\Uninstall.bat"
echo.echo ------------------------------------------------------------- >> "%InstallPath%\Uninstall.bat"
echo.echo. >> "%InstallPath%\Uninstall.bat"
echo.echo - Avisynth will not be Uninstall >> "%InstallPath%\Uninstall.bat"
echo.echo - pleas Uninstall it over your Systemsettings >> "%InstallPath%\Uninstall.bat"
echo.echo. >> "%InstallPath%\Uninstall.bat"
echo.echo - hit key to process the Uninstaller >> "%InstallPath%\Uninstall.bat"
echo.echo ------------------------------------------------------------- >> "%InstallPath%\Uninstall.bat"
echo pause >> "%InstallPath%\Uninstall.bat"

echo. >> "%InstallPath%\Uninstall.bat"
echo.del "C:\Users\%username%\AppData\Roaming\Microsoft\Windows\SendTo\media_Compressor.lnk" >> "%InstallPath%\Uninstall.bat"
echo.pushd ..\ >> "%InstallPath%\Uninstall.bat"
echo.rmdir /s /q "%InstallPath%" >> "%InstallPath%\Uninstall.bat"
echo. >> "%InstallPath%\Uninstall.bat"

echo -------------------------------------------------------------
echo.
echo - media_Compressor is now installed
echo - pleas close the Window and use it over
echo - the Explorer Context Menu: SendTo
echo.
echo -------------------------------------------------------------
pause
exit

:runscript

set "input=%~1"
if "%input%"=="" (
echo.
echo....................................................................
echo.
echo.   Pleas drag and drop Files or Folder on the
echo.   Script or use it in the SendTo Folder
echo.
echo....................................................................
echo.
pause
exit
)

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

if "%~x1"==".avi" GOTO audfirst
if "%~x1"==".m2v" GOTO audfirst
if "%~x1"==".mov" GOTO audfirst
if "%~x1"==".mp4" GOTO audfirst
if "%~x1"==".mpg" GOTO audfirst
if "%~x1"==".mpeg" GOTO audfirst

set "vidInput=%~s2"
set "audInput=%~s1"

GOTO multiplex

:audfirst
set "vidInput=%~s1"
set "audInput=%~s2"

:multiplex
pushd "%installpath%"
FOR /F %%i in ( 'mediainfo --Inform^=^"Video^;%%ScanType/String%%^" %vidInput%' ) do set ScanType=%%i
FOR /F %%j in ( 'mediainfo --Inform^=^"Video^;%%DisplayAspectRatio%%^" %vidInput%' ) do set aspect=%%j
FOR /F %%k in ( 'mediainfo --Inform^=^"Video^;%%Width/String%%^" %vidInput%' ) do set Width=%%k
FOR /F %%l in ( 'mediainfo --Inform^=^"Video^;%%Height/String%%^" %vidInput%' ) do set Height=%%l
FOR /F %%m in ( 'mediainfo --Inform^=^"Video^;%%Duration/String1%%^" %vidInput%' ) do set Duration=%%m
popd

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

if exist "%~n1.avs" del "%~n1.avs" 
if exist "%~n1.h264" del "%~n1.h264" 
if exist "%~n1.aac" del "%~n1.aac" 
if exist "%~s1.ffindex" del "%~s1.ffindex" 
if exist "%~s2.ffindex" del "%~s2.ffindex" 

if not %ScanType%==Progressive (

echo.SetMTMode^(5, 4^) >> "%~n1.avs"
echo.LoadPlugin("%AVSPluginFolder%\ffms2.dll"^) >> "%~n1.avs"
echo.Import^("%AVSPluginFolder%\QTGMC-3.32.avsi"^) >> "%~n1.avs"
echo.A = FFAudioSource^("%audInput%"^) >> "%~n1.avs"
echo.V = FFVideoSource^("%vidInput%"^) >> "%~n1.avs"
echo.audiodub^(V,A^) >> "%~n1.avs"
echo.SetMTMode^(2^) >> "%~n1.avs"
echo.ConvertToYV12^(interlaced=true^) >> "%~n1.avs"
echo.QTGMC^( Preset="Slow", EdiThreads=2 ^) >> "%~n1.avs"
echo.SelectEven^(^) >> "%~n1.avs"

"%InstallPath%\ffmpeg.exe" -y -i "%~n1.avs" -aspect %Aspect% -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%~n1.h264" -c:a %aacEnc% -ab %audioBit% "%~n1.aac"

if exist "%~n1_x264.mp4" del "%~n1_x264.mp4" 
"%InstallPath%\mp4box" -add "%~n1.h264" -add "%~n1.aac" -hint -brand mp42 "%~n1_x264.mp4"
if exist "%~n1.avs" del "%~n1.avs" 
if exist "%~n1.h264" del "%~n1.h264" 
if exist "%~n1.aac" del "%~n1.aac" 
if exist "%~s1.ffindex" del "%~s1.ffindex" 
if exist "%~s2.ffindex" del "%~s2.ffindex" 

GOTO end
) 

"%InstallPath%\ffmpeg.exe" -i %vidInput% -i %audInput% -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%~n1.h264" -c:a %aacEnc% -ab %audioBit% "%~n1.aac"

if exist "%~n1_x264.mp4" del "%~n1_x264.mp4"
"%InstallPath%\mp4box" -add "%~n1.h264" -add "%~n1.aac" -hint -brand mp42 "%~n1_x264.mp4"
if exist "%~n1.h264" del "%~n1.h264" 
if exist "%~n1.aac" del "%~n1.aac" 

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
echo..........converting Audio-File.....................................
echo.
echo....................................................................
echo.

"%InstallPath%\ffmpeg.exe" -i %%f -vn -acodec %audioCodec% -ab %audioBit% "%%~nf_%audioExt%"
)

GOTO end

:: Video Compression -------------------------------

:videocomp

for %%f in (%*) do (
pushd "%installpath%"
FOR /F %%i in ( 'mediainfo --Inform^=^"Video^;%%ScanType/String%%^" %%f' ) do set ScanType=%%i
FOR /F %%j in ( 'mediainfo --Inform^=^"Video^;%%DisplayAspectRatio%%^" %%f' ) do set aspect=%%j
FOR /F %%k in ( 'mediainfo --Inform^=^"Video^;%%Width/String%%^" %%f' ) do set Width=%%k
FOR /F %%l in ( 'mediainfo --Inform^=^"Video^;%%Height/String%%^" %%f' ) do set Height=%%l
FOR /F %%m in ( 'mediainfo --Inform^=^"Video^;%%Duration/String1%%^" %%f' ) do set Duration=%%m
FOR /F %%n in ( 'mediainfo --Inform^=^"Audio^;%%StreamCount%%^" %%f' ) do set AudioStream=%%n
popd

set "infile=%%~sf"

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
echo..........converting Video-File.....................................
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
if exist "%%f.ffindex"  del "%%f.ffindex"  

if "!AudioStream!"=="" (

if not !ScanType!==Progressive (

echo.SetMTMode^(5, 4^) >> "%%~nf.avs"
echo.LoadPlugin("%AVSPluginFolder%\ffms2.dll"^) >> "%%~nf.avs"
echo.Import^("%AVSPluginFolder%\QTGMC-3.32.avsi"^) >> "%%~nf.avs"
echo.FFVideoSource^("!infile!"^) >> "%%~nf.avs"
echo.SetMTMode^(2^) >> "%%~nf.avs"
echo.ConvertToYV12^(interlaced=true^) >> "%%~nf.avs"
echo.QTGMC^( Preset="Slow", EdiThreads=2 ^) >> "%%~nf.avs"
echo.SelectEven^(^) >> "%%~nf.avs"

"%InstallPath%\ffmpeg.exe" -y -i "%%~nf.avs" -aspect !Aspect! -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264"

if exist "%%~nf_x264.mp4" del "%%~nf_x264.mp4" 
"%InstallPath%\mp4box" -add "%%~nf.h264" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
del "%%~sf.ffindex" 
del "%%~nf.avs" 

) else (

"%InstallPath%\ffmpeg.exe" -i %%f -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264"

if exist "%%~nf_x264.mp4" del "%%~nf_x264.mp4" 
"%InstallPath%\mp4box" -add "%%~nf.h264" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
)

) else (

if not !ScanType!==Progressive (

echo.SetMTMode^(5, 4^) >> "%%~nf.avs"
echo.LoadPlugin("%AVSPluginFolder%\ffms2.dll"^) >> "%%~nf.avs"
echo.Import^("%AVSPluginFolder%\QTGMC-3.32.avsi"^) >> "%%~nf.avs"
echo.A = FFAudioSource^("!infile!"^) >> "%%~nf.avs"
echo.V = FFVideoSource^("!infile!"^) >> "%%~nf.avs"
echo.audiodub^(V,A^) >> "%%~nf.avs"
echo.SetMTMode^(2^) >> "%%~nf.avs"
echo.ConvertToYV12^(interlaced=true^) >> "%%~nf.avs"
echo.QTGMC^( Preset="Slow", EdiThreads=2 ^) >> "%%~nf.avs"
echo.SelectEven^(^) >> "%%~nf.avs"

"%InstallPath%\ffmpeg.exe" -y -i "%%~nf.avs" -aspect !Aspect! -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264" -c:a %aacEnc% -ab %audioBit% "%%~nf.aac"

if exist "%%~nf_x264.mp4" del "%%~nf_x264.mp4" 
"%InstallPath%\mp4box" -add "%%~nf.h264" -add "%%~nf.aac" -hint -brand mp42 "%%~nf_x264.mp4"
del "%%~nf.h264" 
del "%%~nf.aac" 
del "%%~sf.ffindex" 
del "%%~nf.avs" 

) else (

"%InstallPath%\ffmpeg.exe" -i %%f -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level !level! -maxrate !maxrate! -bufsize !bufsize! "%%~nf.h264" -c:a %aacEnc% -ab %audioBit% "%%~nf.aac"

if exist "%%~nf_x264.mp4" del "%%~nf_x264.mp4" 
"%InstallPath%\mp4box" -add "%%~nf.h264" -add "%%~nf.aac" -hint -brand mp42 "%%~nf_x264.mp4"
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

pushd "%installpath%" 
FOR /F %%k in ( 'mediainfo --Inform^=^"Image^;%%Width%%^" %file%' ) do set Width=%%k
FOR /F %%l in ( 'mediainfo --Inform^=^"Image^;%%Height%%^" %file%' ) do set Height=%%l
popd

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
echo.....converting Frame Sequence......................................
echo....................................................................
echo.
echo.Duration:  %Duration% Seconds
echo.Width:     %Width%
echo.Height:    %Height%
echo.
echo....................................................................
echo....................................................................
echo.

"%InstallPath%\ffmpeg.exe" -start_number %startframe% -i "%input%\%NewFileName%" -r %fps% -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%input%\..\%newname%.h264"

if exist "%input%\..\%newname%_x264.mp4" del "%input%\..\%newname%_x264.mp4"
"%InstallPath%\mp4box" -add "%input%\..\%newname%.h264" -hint -brand mp42 "%input%\..\%newname%_x264.mp4"
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

pushd "%installpath%"
FOR /F %%k in ( 'mediainfo --Inform^=^"Image^;%%Width%%^" %file%' ) do set Width=%%k
FOR /F %%l in ( 'mediainfo --Inform^=^"Image^;%%Height%%^" %file%' ) do set Height=%%l
popd

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
echo.....converting OpenEXR Sequence....................................
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

"%InstallPath%\ffmpeg.exe" -i "%input%\..\%~n1_tmp.avs" -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "%input%\..\%newname%.h264"

if exist "%input%\..\%newname%_x264.mp4" del "%input%\..\%newname%_x264.mp4"
"%InstallPath%\mp4box" -add "%input%\..\%newname%.h264" -hint -brand mp42 "%input%\..\%newname%_x264.mp4"
del "%input%\..\%newname%.h264"

if exist "%input%\..\%~n1_tmp.avs" del "%input%\..\%~n1_tmp.avs"
  
:end
echo.
echo....................................................................
echo.
echo.....................converting done................................
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