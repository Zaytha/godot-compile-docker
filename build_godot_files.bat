@echo off

echo ------------------------------------- [1/4] Inital Setup --------------------------------------

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker is NOT running or not installed.
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo Docker is running.
echo ------------------------------

REM Prompt for Godot and GodotSteam version with defaults
set "GODOT_VERSION_DEFAULT=4.4-stable"
echo What version of Godot would you like to use? (https://github.com/godotengine/godot)
set /p GODOT_VERSION=Enter your version or press enter to use the default (%GODOT_VERSION_DEFAULT%):
if "%GODOT_VERSION%"=="" set "GODOT_VERSION=%GODOT_VERSION_DEFAULT%"
echo ------------------------------

set "GODOT_STEAM_VERSION_DEFAULT=godot4"
echo What version of GodotSteam would you like to use? (https://github.com/GodotSteam/GodotSteam)
set /p GODOT_STEAM_VERSION=Enter your version or press enter to use the default (%GODOT_STEAM_VERSION_DEFAULT%):
if "%GODOT_STEAM_VERSION%"=="" set "GODOT_STEAM_VERSION=%GODOT_STEAM_VERSION_DEFAULT%"
echo -----------------------------------------------------------------------------------------------


REM Get Steam SDK version from Readme.txt
set "SDK_README=steam_sdk\sdk\Readme.txt"
set "SDK_VERSION="

if exist "%SDK_README%" (
    setlocal enabledelayedexpansion
    set "found_delimiter="
    for /f "usebackq delims=" %%A in ("%SDK_README%") do (
        if defined found_delimiter (
            set "SDK_VERSION=%%A"
            goto :show_sdk_version
        )
        echo %%A | findstr /C:"----------------------------------------------------------------" >nul
        if not errorlevel 1 set "found_delimiter=1"
    )
    :show_sdk_version
    endlocal & set "SDK_VERSION=%SDK_VERSION%"
)


REM Check to make sure steam sdk is there
if not exist "steam_sdk\sdk\redistributable_bin" (
    echo ERROR: steam_sdk\sdk\redistributable_bin folder is missing.
    echo Make sure to copy the contents of the steamworks_sdk_XXX.zip into the steam_sdk folder.
    pause
    exit /b 1
)
if not exist "steam_sdk\sdk\public" (
    echo ERROR: steam_sdk\sdk\public folder is missing.
    echo Make sure to copy the contents of the steamworks_sdk_XXX.zip into the steam_sdk folder.
    pause
    exit /b 1
)

REM Final confirmation
echo You will be compiling Godot with the following settings:
echo Godot Version ........................................ %GODOT_VERSION%
echo GodotSteam Version ................................... %GODOT_STEAM_VERSION%
echo Steam SDK Version .................................... %SDK_VERSION%
echo Docker ............................................... RUNNING
pause


REM Begin the build process
echo ------------------------------ [2/4] Setting up Build Enviorment ------------------------------
docker-compose up --build --abort-on-container-exit setup

echo ---------------------------------- [3/4] Starting Linux Build ---------------------------------
REM run the dockerfile for linux build
docker-compose up --build linux_build
echo -------------------------------------- Linux Build Finished -------------------------------------


echo ---------------------------------- [4/4] Starting Windows Build ---------------------------------
REM Read encryption key from file
set /p SCRIPT_AES256_ENCRYPTION_KEY=<godot_data\godot.gdkey

REM Go into folder and build
cd godot_data\godot
scons platform=windows tools=yes target=editor
scons platform=windows tools=no target=template_debug
scons platform=windows tools=no target=template_release production=yes

echo -------------------------------------- All Builds Finished --------------------------------------
echo .
echo "Files are located in the godot_data\godot\bin folder."
start "" "bin"
pause