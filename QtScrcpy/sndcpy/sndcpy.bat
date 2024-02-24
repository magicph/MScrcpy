@echo off

echo Begin Runing...
set SNDCPY_PORT=28200
set SNDCPY_APK=sndcpy.apk
set ADB=adb.exe

if not "%1"=="" (
    set serial=-s %1
)
if not "%2"=="" (
    set SNDCPY_PORT=%2
)

echo Waiting for device %1...
%ADB% %serial% wait-for-device || goto :error
echo Find device %1


echo Request PROJECT_MEDIA permission...
%ADB% %serial% shell appops set com.tkstudio.mscrcpy PROJECT_MEDIA allow

echo Forward port %SNDCPY_PORT%...
%ADB% %serial% forward tcp:%SNDCPY_PORT% localabstract:sndcpy || goto :error

echo Start %SNDCPY_APK%...
%ADB% %serial% shell am start com.tkstudio.mscrcpy/.MainActivity || goto :error

:check_start
echo Waiting %SNDCPY_APK% start...
::timeout /T 1 /NOBREAK > nul
%ADB% %serial% shell sleep 0.1
for /f "delims=" %%i in ("%ADB% shell 'ps | grep com.tkstudio.mscrcpy'") do set sndcpy_started=%%i
if "%sndcpy_started%"=="" (
    goto :check_start
)
echo %SNDCPY_APK% started...

echo Ready playing...
::vlc.exe -Idummy --demux rawaud --network-caching=0 --play-and-exit tcp://localhost:%SNDCPY_PORT%
::ffplay.exe -nodisp -autoexit -probesize 32 -sync ext -f s16le -ar 48k -ac 2 tcp://localhost:%SNDCPY_PORT%
goto :EOF

:error
echo Failed with error #%errorlevel%.
exit /b %errorlevel%
