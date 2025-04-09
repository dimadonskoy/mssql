@echo off
setlocal enabledelayedexpansion

REM Create required folders if they don't exist
for %%F in (log backup secrets) do (
    if not exist "%%F" (
        echo Creating folder: %%F
        mkdir %%F
        if errorlevel 1 (
            echo [ERROR] Failed to create folder: %%F
            exit /b 1
        )
    )
)

REM Navigate to the 'sqldata' directory
if not exist "sqldata" (
    echo [ERROR] Directory 'sqldata' does not exist.
    exit /b 1
)
cd sqldata

REM Check if the ZIP file exists
if not exist "sqldata.zip" (
    echo [ERROR] File 'sqldata.zip' not found in 'sqldata' directory.
    exit /b 1
)

REM Extract the ZIP file
echo Extracting sqldata.zip...
tar -xf sqldata.zip
if errorlevel 1 (
    echo [ERROR] Failed to extract 'sqldata.zip'.
    exit /b 1
)

cd ..

REM Start Docker containers
echo Starting Docker containers...
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start Docker containers.
    exit /b 1
)

echo [SUCCESS] Setup completed.
endlocal
