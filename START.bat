@echo off
setlocal EnableDelayedExpansion
cd %~dp0

:: IF script and executable exist, run the macro
if exist "submacros\AutoHotkeyU32.exe" (
	if exist "submacros\natro_macro.ahk" (
		start "" "submacros\AutoHotkeyU32.exe" "submacros\natro_macro.ahk"
		exit
	)
)

:: ELSE try to find .zip in common directories, extract, and run the macro
set cyan=[1;36m>nul
set green=[1;32m>nul
set purple=[1;35m>nul
set red=[1;31m>nul
set yellow=[1;33m>nul
set reset=[0m>nul

for %%a in (".\..") do set "grandparent=%%~nxa"
if defined grandparent (
	for /f "tokens=1,* delims=_" %%a in ("%grandparent%") do set "zip=%%b"
	if defined zip (
		echo %cyan%Looking for !zip!...%reset%
		cd %USERPROFILE%
		for %%a in (Downloads,Desktop,Documents,OneDrive\Downloads,OneDrive\Desktop,OneDrive\Documents) do (
			if exist "%%a\!zip!" (
				echo %cyan%Found in %%a^^!%reset%
				echo:
				
				echo %purple%Extracting %USERPROFILE%\%%a\!zip!...%reset%
				call :UnZipFile "%USERPROFILE%\%%a" "%USERPROFILE%\%%a\!zip!" folder
				echo %purple%Extract complete^^!%reset%
				echo:
				
				echo %yellow%Deleting !zip!...%reset%
				del /f /s /q "%USERPROFILE%\%%a\!zip!" >nul
				echo %yellow%Deleted successfully^^!%reset%
				echo:
				
				<nul set /p "=%green%Press any key to start Natro Macro...%reset%"
				pause >nul
				start "" "%%a\!folder!\submacros\AutoHotkeyU32.exe" "%%a\!folder!\submacros\natro_macro.ahk"
				exit
			)
		)
	) else (echo %red%Error: Could not determine .zip name of unextracted .zip^^!%reset%)
) else (echo %red%Error: Could not find Temp folder of unextracted .zip^^! ^(.bat has no grandparent^)%reset%)

pause

:: modified from https://stackoverflow.com/a/21709923
:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo for each folder in FilesInZip
>>%vbs% echo WScript.Echo folder
>>%vbs% echo next
>>%vbs% echo objShell.NameSpace(%1).CopyHere FilesInZip, 20
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
for /f delims^=^ EOL^= %%g in ('cscript //nologo %vbs%') do set "%3=%%g"
if exist %vbs% del /f /q %vbs%