call "C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\rsvars.bat"
msbuild.exe "units\DelphiPreviewHandler.dproj" /target:Clean;Build /p:Platform=Win32 /p:config=release /p:DCC_DebugInformation=2 
set BUILD_STATUS=%ERRORLEVEL%
if %BUILD_STATUS%==0 GOTO INNO
pause
EXIT

:INNO
"C:\Program Files (x86)\Inno Setup 5\iscc.exe" "C:\Delphi\github\delphi-preview-handler\DelphiPreviewHandler.iss"
set INNO_STATUS=%ERRORLEVEL%
if %INNO_STATUS%==0 GOTO END
pause
EXIT


:END 
pause
