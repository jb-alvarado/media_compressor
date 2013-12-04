::-------------------------------------------------------------------------------------
:: LICENSE -------------------------------------------------------------------------
::-------------------------------------------------------------------------------------
::	  This Windows Batchscript is for the SendTo Menu. It compress audio, videos and folders with image sequences to mp4.
::    Copyright (C) 2012  jb_alvarado
::
::    This program is free software: you can redistribute it and/or modify
::    it under the terms of the GNU General Public License as published by
::    the Free Software Foundation, either version 3 of the License, or
::    (at your option) any later version.
::
::    This program is distributed in the hope that it will be useful,
::    but WITHOUT ANY WARRANTY; without even the implied warranty of
::    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
::    GNU General Public License for more details.
::
::    You should have received a copy of the GNU General Public License
::    along with this program.  If not, see <http://www.gnu.org/licenses/>.
::-------------------------------------------------------------------------------------
::-------------------------------------------------------------------------------------

::-------------------------------------------------------------------------------------
:: History ---------------------------------------------------------------------------
::-------------------------------------------------------------------------------------
::
:: This is version 0.95 from 2012-09-16. Last bigger modification was on 2013-04-09
:: 2012-10-28 - add HQ Avisynth Deinterlacer, Auto Level for the Codec, maxrate, bufsize and small changes
:: 2012-10-29 - build a new installer, most things a now automatic
:: 2012-11-21 - fixing avisynth input, change code layout
:: 2013-04-09 - changing video input, now it use avisynth only for deinterlacing, download sources fixed
:: 2013-05-24 - fixing small things, also a error in the input by frame sequences
:: 2013-08-06 - simplify downloads
:: 2013-09-08 - simplify installation, add new static mp4box, add now wget and change first download from browser to jscript download
:: 2013-11-*   - add timer function
:: 2013-11-28 - fixing bug in path how have a german umlaut
:: 2013-12-03 - simplify installation, no avisynth install anymore, also add some warning because of the write access to the install dir
::
::-------------------------------------------------------------------------------------


@echo off
 
color 80
title media_Compressor
 
:: EncoderSettings -------------------------------

set preset=slower
:: ( preset defined how exactly the x264 codec work, slower better and smaller but slower: ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo )

set quality=20
:: ( quality: 20-26 useful, smaller better quality )
 
set GOPSize=25
:: ( GOPSize: short clips needs smaller value )
 
set fps=
:: ( fps: frames per second, only need this for other frame rate then 25 (for  frame sequences) )

set aacEnc=libfdk_aac
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
	set "AVSPluginFolder=C:\Program Files (x86)\BatchMediaCompressor\plugins"
	) else (
		set "InstallPath=C:\Program Files\BatchMediaCompressor"
		set "AVSPluginFolder=C:\Program Files\BatchMediaCompressor\plugins"
		)
if exist "%InstallPath%" GOTO checkwget
MD "%InstallPath%"	
MD "%AVSPluginFolder%"

if not exist "%InstallPath%" (
	echo -------------------------------------------------------------
	echo.
	echo you have no write access to:
	echo "%InstallPath%"
	echo please create the folder "BatchMediaCompressor" manual
	echo.
	echo -------------------------------------------------------------
	pause
	)
	
:checkwget
if exist "%InstallPath%\wget.exe" GOTO check7z
	echo -------------------------------------------------------------
	echo.
	echo - Download and install wget to:
	echo - %InstallPath% 
	echo.
	echo -------------------------------------------------------------
	pushd %InstallPath%
	if exist "%InstallPath%\install-wget.js" del "%InstallPath%\install-wget.js"
	
	echo.var wshell = new ActiveXObject("WScript.Shell"); var htmldoc = new ActiveXObject("htmlfile"); var xmlhttp = new ActiveXObject("MSXML2.ServerXMLHTTP"); var adodb = new ActiveXObject("ADODB.Stream"); var FSO = new ActiveXObject("Scripting.FileSystemObject")>>"%InstallPath%\install-wget.js"
	echo.>>"%InstallPath%\install-wget.js"
	echo.function http_get(url, is_binary) {xmlhttp.open("GET", url); xmlhttp.send(); WScript.echo("retrieving " + url); while (xmlhttp.readyState != 4); WScript.Sleep(100); if (xmlhttp.status != 200) {WScript.Echo("http get failed: " + xmlhttp.status); WScript.Quit(2)}; return is_binary ? xmlhttp.responseBody : xmlhttp.responseText}>>"%InstallPath%\install-wget.js"
	echo.>>"%InstallPath%\install-wget.js"
	echo.function save_binary(path, data) {adodb.type = 1; adodb.open(); adodb.write(data); adodb.saveToFile(path, 2)}>>"%InstallPath%\install-wget.js"
	echo.>>"%InstallPath%\install-wget.js"
	echo.function download_wget() {var base_url = "http://blog.pixelcrusher.de/downloads/media_compressor/wget.zip"; html = http_get(base_url, false); htmldoc.open(); htmldoc.write(html); var div = htmldoc.getElementById("downloading"); var filename = "wget.zip"; var installer_data = http_get(base_url, true); save_binary(filename, installer_data); return FSO.GetAbsolutePathName(filename)}>>"%InstallPath%\install-wget.js"
	echo.>>"%InstallPath%\install-wget.js"
	echo.function extract_zip(zip_file, dstdir) {var shell = new ActiveXObject("shell.application"); var dst = shell.NameSpace(dstdir); var zipdir = shell.NameSpace(zip_file); dst.CopyHere(zipdir.items(), 0)}>>"%InstallPath%\install-wget.js"
	echo.>>"%InstallPath%\install-wget.js"
	echo.function install_wget(zip_file) {var rootdir = wshell.CurrentDirectory; extract_zip(zip_file, rootdir)}>>"%InstallPath%\install-wget.js"
	echo.>>"%InstallPath%\install-wget.js"
	echo.install_wget(download_wget())>>"%InstallPath%\install-wget.js"

	cscript "%InstallPath%\install-wget.js"

	del "%InstallPath%\install-wget.js"
	del "%InstallPath%\wget.zip"
	popd
if not exist "%InstallPath%\wget.exe" (
	echo -------------------------------------------------------------
	echo.
	echo wget not installed...
	echo check internet connection and write access to:
	echo "%InstallPath%"
	echo.
	echo -------------------------------------------------------------
	pause
	GOTO checkwget
	)

:check7z
if exist "%InstallPath%\7za.exe" GOTO checkQTGMC
	echo -------------------------------------------------------------
	echo.
	echo - 7z download and install start...
	echo.
	echo.
	echo -------------------------------------------------------------
	"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/media_compressor/7za920.exe"
	pushd %InstallPath%
	"%InstallPath%\7za920.exe"
	popd
	move "%InstallPath%\7zip-license.txt" "%InstallPath%\license"
	move "%InstallPath%\7-zip.chm" "%InstallPath%\help"
	move "%InstallPath%\7zip-readme.txt" "%InstallPath%\readme"
	del "%InstallPath%\7za920.exe"
 
:checkQTGMC
if exist "%AVSPluginFolder%\QTGMC-3.32.avsi" GOTO checkffms
	echo -------------------------------------------------------------
	echo.
	echo - Avisynth will be install and adjusted
	echo - The deinterlacer QTGMC will be install
	echo.
	echo.
	echo -------------------------------------------------------------
	"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/media_compressor/QTGMC_32-bit_[Vit-Mod]_jb_pack.7z"

	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%" avisynth.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%" DevIL.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%" fftw3.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%" ILU.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%" ILUT.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%" libfftw3f-3.dll

	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" QTGMC-3.32.avsi
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\help" QTGMC-3.32.html
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\readme" Avisynth_2.6_MT.URL 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\readme" Avisynth_rev._2.URL
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\readme" QTGMC_READ_ME.txt 
	
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\license" avisynth_gpl.txt
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\license" avisynth_gpl-de.txt 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\license" avisynth_lgpl_for_used_libs.txt 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\license" DevIL_lgpl.txt
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%InstallPath%\license" QTGMC_gpl.txt

	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" AddGrainC.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" dfttest.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" EEDI2.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" eedi3.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" FFT3DFilter.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" mt_masktools-26.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" mvtools2.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" nnedi.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" nnedi2.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" nnedi3.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" RemoveGrainSSE2.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" RepairSSE2.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" SSE2Tools.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" TDeint.dll 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" VerticalCleanerSSE2.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z" -o"%AVSPluginFolder%" yadif.dll

	del "%InstallPath%\QTGMC_32-bit_[Vit-Mod]_jb_pack.7z"

:checkffms
if exist "%AVSPluginFolder%\ffms2.dll" GOTO checkffmpeg
	echo -------------------------------------------------------------
	echo.
	echo - The AVSLoader will be download and install
	echo.
	echo.
	echo -------------------------------------------------------------
	"%InstallPath%\wget" --no-check-certificate -P "%InstallPath%" "https://ffmpegsource.googlecode.com/files/ffms-2.17.7z"
	"%InstallPath%\7za.exe" e -y "%InstallPath%\ffms-2.17.7z" -o"%AVSPluginFolder%" ffms-2.17\FFMS2.avsi
	"%InstallPath%\7za.exe" e -y "%InstallPath%\ffms-2.17.7z" -o"%AVSPluginFolder%" ffms-2.17\ffms2.dll
	"%InstallPath%\7za.exe" e -y "%InstallPath%\ffms-2.17.7z" -o"%AVSPluginFolder%" ffms-2.17\ffmsindex.exe
	del "%InstallPath%\ffms-2.17.7z"

:checkffmpeg
if exist "%InstallPath%\ffmpeg.exe" GOTO checkmp4box
	echo -------------------------------------------------------------
	echo.
	echo - ffmpeg the compressor will be install
	echo.
	echo.
	echo -------------------------------------------------------------
	"%InstallPath%\wget" -P "%InstallPath%" http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.7z
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\ffmpeg-latest-win32-static.7z" -o"%InstallPath%" *.exe 
	del "%InstallPath%\ffmpeg-latest-win32-static.7z"
 
:checkmp4box
if exist "%InstallPath%\mp4box.exe" GOTO checkMediaInfo 
	echo -------------------------------------------------------------
	echo.
	echo - mp4box the multiplexer will be install
	echo.
	echo -------------------------------------------------------------
	"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/media_compressor/mp4box.7z"
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\mp4box.7z" -o"%InstallPath%" *.exe 
	"%InstallPath%\7za.exe" e  -r -y"%InstallPath%\mp4box.7z" -o"%InstallPath%\license" MP4Box_License.txt 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\mp4box.7z" -o"%InstallPath%\readme" MP4Box_ReadMe.txt 
	del "%InstallPath%\mp4box.7z"

:checkMediaInfo
if exist "%InstallPath%\MediaInfo.exe" GOTO checklink
	echo --------------------------------------
	echo.
	echo - MediaInfo will be install
	echo.
	echo --------------------------------------
	"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/media_compressor/MediaInfo_CLI_0.7.64_Windows_i386.7z"
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z" -o"%InstallPath%" *.exe
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z" -o"%InstallPath%" *.dll
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z" -o"%InstallPath%\license" MediaInfo_License.html 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z" -o"%InstallPath%\readme" MediaInfo_History.txt 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z" -o"%InstallPath%\readme" MediaInfo_ReadMe.txt 
	"%InstallPath%\7za.exe" e -r -y "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z" -o"%InstallPath%\help" CLI_Help.doc 
	del "%InstallPath%\MediaInfo_CLI_0.7.64_Windows_i386.7z"
 
:checklink
if exist "%APPDATA%\Microsoft\Windows\SendTo\media_Compressor.lnk" GOTO checkself
	echo -------------------------------------------------------------
	echo.
	echo - bulding Link to the SendTo Menu
	echo.
	echo -------------------------------------------------------------
	
	if exist "%InstallPath%\FFmpeg.ico" GOTO buildlink
	"%InstallPath%\wget" -P "%InstallPath%" "http://blog.pixelcrusher.de/downloads/media_compressor/FFmpeg.ico"

:buildlink
	echo.Set Shell = CreateObject^("WScript.Shell"^) >> "%InstallPath%\setlink.vbs"
	echo.Set link = Shell.CreateShortcut^("%InstallPath%\media_Compressor.lnk"^) >> "%InstallPath%\setlink.vbs"
	echo.link.Arguments = "" >> "%InstallPath%\setlink.vbs"
	echo.link.Description = "Compress Video or Audio Files, Framesequences or multiplex Video and Audio Files to MP4" >> "%InstallPath%\setlink.vbs"
	echo.link.IconLocation = "%InstallPath%\FFmpeg.ico" >> "%InstallPath%\setlink.vbs"
	echo.link.TargetPath = "%InstallPath%\media_Compressor.bat" >> "%InstallPath%\setlink.vbs"
	echo.link.WindowStyle = 1 >> "%InstallPath%\setlink.vbs"
	echo.link.WorkingDirectory = "%InstallPath%" >> "%InstallPath%\setlink.vbs"
	echo.link.Save>> "%InstallPath%\setlink.vbs" 

	cscript /nologo "%InstallPath%\setlink.vbs" 
	copy "%InstallPath%\media_Compressor.lnk" "%APPDATA%\Microsoft\Windows\SendTo\media_Compressor.lnk"
	del "%InstallPath%\setlink.vbs" 
	
	if not exist "%APPDATA%\Microsoft\Windows\SendTo\media_Compressor.lnk" (
		echo -------------------------------------------------------------
		echo.
		echo write link to the sendto menu failed.
		echo copy "%InstallPath%\media_Compressor.lnk" to:
		echo "%APPDATA%\Microsoft\Windows\SendTo"
		echo.
		echo -------------------------------------------------------------
	)
	
:checkself
if exist "%InstallPath%\media_Compressor.bat" GOTO runscript
	copy /Y "%~f0" "%InstallPath%"


if exist "%InstallPath%\Uninstall.bat" GOTO runscript
	echo.@echo off >> "%InstallPath%\Uninstall.bat"
	echo.echo ------------------------------------------------------------- >> "%InstallPath%\Uninstall.bat"
	echo.echo. >> "%InstallPath%\Uninstall.bat"
	echo.echo - hit key to process the Uninstaller >> "%InstallPath%\Uninstall.bat"
	echo.echo. >> "%InstallPath%\Uninstall.bat"
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
Setlocal EnableDelayedExpansion 

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
	FOR /F %%k in ( 'mediainfo --Inform^=^"Video^;%%Width%%^" %vidInput%' ) do set Width=%%k
	FOR /F %%l in ( 'mediainfo --Inform^=^"Video^;%%Height%%^" %vidInput%' ) do set Height=%%l
	FOR /F %%m in ( 'mediainfo --Inform^=^"Video^;%%Duration/String3%%^" %vidInput%' ) do set Duration=%%m
popd

if %Width% LEQ 1024 (
	set level=3.2 -refs 4
	set maxrate=4M 
	set bufsize=4M
	)

if %Width% GEQ 1280 (
	set level=4.1 -refs 4
	set maxrate=10M 
	set bufsize=10M
	)

if %Width% GEQ 1920 (
	set level=4.1 -refs 4
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

if %ScanType%==Interlaced (
	echo.SetMTMode^(5, 4^) >> "%~n1.avs"
	echo.LoadPlugin("%AVSPluginFolder%\ffms2.dll"^) >> "%%~nf.avs"
	echo.LoadPlugin("%AVSPluginFolder%\mt_masktools-26.dll"^) >> "%%~nf.avs"
	echo.LoadPlugin("%AVSPluginFolder%\RemoveGrainSSE2.dll"^) >> "%%~nf.avs"
	echo.LoadPlugin("%AVSPluginFolder%\RepairSSE2.dll"^) >> "%%~nf.avs"
	echo.LoadPlugin("%AVSPluginFolder%\mvtools2.dll"^) >> "%%~nf.avs"
	echo.LoadPlugin("%AVSPluginFolder%\nnedi3.dll"^) >> "%%~nf.avs"
	echo.YadifPath ="%AVSPluginFolder%\yadif.dll" >> "%%~nf.avs"
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


:: Audio Compression -------------------------------

:audiocomp

for %%f in (%*) do (
	if "%%~xf"==".avi" GOTO :videocomp
	if "%%~xf"==".AVI" GOTO :videocomp
	if "%%~xf"==".mp4" GOTO :videocomp
	if "%%~xf"==".MP4" GOTO :videocomp
	if "%%~xf"==".m4v" GOTO :videocomp
	if "%%~xf"==".avs" GOTO :avscomp
	if "%%~xf"==".flv" GOTO :videocomp
	if "%%~xf"==".f4v" GOTO :videocomp
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

:avscomp
if not "%~x1"==".avs" GOTO :videocomp
for %%f in (%*) do (
	"%InstallPath%\ffmpeg.exe" -i %%f -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -maxrate 6M -bufsize 6M -c:a %aacEnc% -ab %audioBit% "%%~nf.m4v"

	if exist "%%~nf_x264.mp4" del "%%~nf_x264.mp4" 
	"%InstallPath%\mp4box" -add "%%~nf.m4v" -hint -brand mp42 "%%~nf_x264.mp4"
	del "%%~nf.m4v" 
	)
	
GOTO end

:videocomp

for %%f in (%*) do (
	pushd "%installpath%"
		FOR /F %%i in ( 'mediainfo --Inform^=^"Video^;%%ScanType/String%%^" %%f' ) do set ScanType=%%i
		FOR /F %%j in ( 'mediainfo --Inform^=^"Video^;%%DisplayAspectRatio%%^" %%f' ) do set aspect=%%j
		FOR /F %%k in ( 'mediainfo --Inform^=^"Video^;%%Width%%^" %%f' ) do set Width=%%k
		FOR /F %%l in ( 'mediainfo --Inform^=^"Video^;%%Height%%^" %%f' ) do set Height=%%l
		FOR /F %%m in ( 'mediainfo --Inform^=^"Video^;%%Duration/String3%%^" %%f' ) do set Duration=%%m
		FOR /F %%n in ( 'mediainfo --Inform^=^"Audio^;%%StreamCount%%^" %%f' ) do set AudioStream=%%n
		popd

	set "infile=%%~sf"

	if !Width! LEQ 1024 (
		set level=3.2 -refs 4
		set maxrate=4M 
		set bufsize=4M
		)

	if !Width! GEQ 1280 (
		set level=4.1 -refs 4
		set maxrate=10M 
		set bufsize=10M
		)

	if !Width! GEQ 1920 (
		set level=4.1 -refs 4
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
	
	set timeStart=%time%
	set startHour=!timeStart:~0,2!
	set startMinutes=!timeStart:~3,2!
	set startSeconds=!timeStart:~6,2!
	 
	set /a startTotalSec=!startHour!*60*60+!startMinutes!*60+!startSeconds!

	if "!AudioStream!"=="" (
		if !ScanType!==Interlaced (
			echo.SetMTMode^(5, 4^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\ffms2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\mt_masktools-26.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\RemoveGrainSSE2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\RepairSSE2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\mvtools2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\nnedi3.dll"^) >> "%%~nf.avs"
			echo.YadifPath ="%AVSPluginFolder%\yadif.dll" >> "%%~nf.avs"
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
		if !ScanType!==Interlaced (
			echo.SetMTMode^(5, 4^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\ffms2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\mt_masktools-26.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\RemoveGrainSSE2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\RepairSSE2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\mvtools2.dll"^) >> "%%~nf.avs"
			echo.LoadPlugin("%AVSPluginFolder%\nnedi3.dll"^) >> "%%~nf.avs"
			echo.YadifPath ="%AVSPluginFolder%\yadif.dll" >> "%%~nf.avs"
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
			"%InstallPath%\mp4box" -inter 0.5 -add "%%~nf.h264" -add "%%~nf.aac" -hint -brand mp42 "%%~nf_x264.mp4"
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

	set timeEnd=%time%
	set endHour=!timeEnd:~0,2!
	set endMinutes=!timeEnd:~3,2!
	set endSeconds=!timeEnd:~6,2!
	 
	set /a endTotalSec=!endHour!*60*60+!endMinutes!*60+!endSeconds!
	set /a diffTimeSec=!endTotalSec!-!startTotalSec!

	echo.
	echo.
	echo....................................................................
	echo. time for converting: !diffTimeSec! seconds..................................
	echo....................................................................
	echo.
	echo.

GOTO end

:: ---------------------------------------------------
 
:: Folder Compression -------------------------------
 
:folder

set "shortpath=%~s1"
 
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
	FOR /F %%k in ( 'mediainfo --Inform^=^"Image^;%%Width%%^" "%shortpath%\%file%"' ) do set Width=%%k
	FOR /F %%l in ( 'mediainfo --Inform^=^"Image^;%%Height%%^" "%shortpath%\%file%"' ) do set Height=%%l
	popd

if %Width% LEQ 1024 (
	set level=3.2 -refs 4
	set maxrate=4M 
	set bufsize=4M
	)

if %Width% GEQ 1280 (
	set level=4.1 -refs 4
	set maxrate=10M 
	set bufsize=10M
	)

if %Width% GEQ 1920 (
	set level=4.1 -refs 4
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

set timeStart=%time%
set startHour=%timeStart:~0,2%
set startMinutes=%timeStart:~3,2%
set startSeconds=%timeStart:~6,2%
 
set /a startTotalSec=%startHour%*60*60+%startMinutes%*60+%startSeconds%

pushd %input%
	"%InstallPath%\ffmpeg.exe" -start_number %startframe% -i "%NewFileName%" -r %fps% -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "..\%newname%.h264"

	if exist "..\%newname%_x264.mp4" del "..\%newname%_x264.mp4"
	"%InstallPath%\mp4box" -add "..\%newname%.h264" -hint -brand mp42 "..\%newname%_x264.mp4"
	del "..\%newname%.h264"
	popd

set timeEnd=%time%
set endHour=%timeEnd:~0,2%
set endMinutes=%timeEnd:~3,2%
set endSeconds=%timeEnd:~6,2%
 
set /a endTotalSec=%endHour%*60*60+%endMinutes%*60+%endSeconds%
set /a diffTimeSec=%endTotalSec%-%startTotalSec%

echo.
echo.
echo....................................................................
echo. time for converting: %diffTimeSec% seconds..................................
echo....................................................................
echo.
echo.
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
	FOR /F %%k in ( 'mediainfo --Inform^=^"Image^;%%Width%%^" "%shortpath%\%file%"' ) do set Width=%%k
	FOR /F %%l in ( 'mediainfo --Inform^=^"Image^;%%Height%%^" "%shortpath%\%file%"' ) do set Height=%%l
	popd

if %Width% LEQ 1024 (
	set level=3.2 -refs 4
	set maxrate=4M 
	set bufsize=4M
	)

if %Width% GEQ 1280 (
	set level=4.1 -refs 4
	set maxrate=10M 
	set bufsize=10M
	)

if %Width% GEQ 1920 (
	set level=4.1 -refs 4
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

pushd %input%
	if exist "..\%~n1_tmp.avs" del "..\%~n1_tmp.avs"

	echo ImageReader^( "%var%", start=%startframe%, end=%endframe%, fps=%fps% ^, use_DevIL = true) >>"%~n1_tmp.avs"
	echo Levels^(0,%gamma%,255,0,255^) >> "%~n1_tmp.avs"

	"%InstallPath%\ffmpeg.exe" -i "%~n1_tmp.avs" -pix_fmt yuv420p -c:v libx264 -preset %preset% -crf %quality% -g %GOPSize% -profile:v Main -level %level% -maxrate %maxrate% -bufsize %bufsize% "..\%newname%.h264"

	if exist "..\%newname%_x264.mp4" del "..\%newname%_x264.mp4"
	"%InstallPath%\mp4box" -add "..\%newname%.h264" -hint -brand mp42 "..\%newname%_x264.mp4"
	del "..\%newname%.h264"
	del "%~n1_tmp.avs"
	popd 

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
