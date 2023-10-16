<!-- : Begin batch script
@echo off
setlocal EnableDelayedExpansion
cd %~dp0

:: IF script and executable exist, run the macro
if exist "submacros\AutoHotkeyU32.exe" (
	if exist "submacros\natro_macro.ahk" (
		start "" "%~dp0submacros\AutoHotkeyU32.exe" "%~dp0submacros\natro_macro.ahk"
		exit
	)
)

:: ELSE try to find .zip in common directories, extract, and run the macro
for /f "delims=#" %%E in ('"prompt #$E# & for %%E in (1) do rem"') do set "\e=%%E"
set cyan=%\e%[96m
set green=%\e%[92m
set purple=%\e%[95m
set red=%\e%[91m
set yellow=%\e%[93m
set reset=%\e%[0m

for %%a in (".\..") do set "grandparent=%%~nxa"
if defined grandparent (
	for /f "tokens=1,* delims=_" %%a in ("%grandparent%") do set "zip=%%b"
	call set str=%%zip:*.zip=%%
	call set zip=%%zip:!str!=%%
	if defined zip (
		echo %cyan%Looking for !zip!...%reset%
		cd %USERPROFILE%
		for %%a in ("Downloads","Downloads\Natro Macro","Desktop","Documents","OneDrive\Downloads","OneDrive\Downloads\Natro Macro","OneDrive\Desktop","OneDrive\Documents") do (
			if exist "%%~a\!zip!" (
				echo %cyan%Found in %%~a^^!%reset%
				echo:
				
				echo %purple%Extracting %USERPROFILE%\%%~a\!zip!...%reset%
				for /f delims^=^ EOL^= %%g in ('cscript //nologo "%~f0?.wsf" "%USERPROFILE%\%%~a" "%USERPROFILE%\%%~a\!zip!"') do set "folder=%%g"
				echo %purple%Extract complete^^!%reset%
				echo:
				
				echo %yellow%Deleting !zip!...%reset%
				del /f /s /q "%USERPROFILE%\%%~a\!zip!" >nul
				echo %yellow%Deleted successfully^^!%reset%
				echo:
				
				<nul set /p "=%green%Press any key to start Natro Macro . . . %reset%"
				pause >nul
				start "" "%USERPROFILE%\%%~a\!folder!\submacros\AutoHotkeyU32.exe" "%USERPROFILE%\%%~a\!folder!\submacros\natro_macro.ahk"
				exit
			)
		)
	) else (echo %red%Error: Could not determine .zip name of unextracted .zip^^!%reset%)
) else (echo %red%Error: Could not find Temp folder of unextracted .zip^^! ^(.bat has no grandparent^)%reset%)

echo %red%Unable to automatically extract Natro Macro^^!%reset%
echo %red% - If you have already extracted, make sure you are not missing any files.%reset%
echo %red% - If you have not extracted, you may have to manually extract the zipped folder.%reset%
echo %red%Join our Discord server for support: discord.gg/natromacro%reset%
echo:
<nul set /p "=%red%Press any key to exit . . . %reset%"
pause >nul
exit

----- Begin wsf script --->
<job><script language="VBScript">
set fso = CreateObject("Scripting.FileSystemObject")
set objShell = CreateObject("Shell.Application")
set FilesInZip = objShell.NameSpace(WScript.Arguments(1)).items
for each folder in FilesInZip
	WScript.Echo folder
next
objShell.NameSpace(WScript.Arguments(0)).CopyHere FilesInZip, 20
set fso = Nothing
set objShell = Nothing
</script></job>