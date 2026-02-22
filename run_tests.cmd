@echo off
setlocal

REM Set the Godot binary path
set GODOT_BIN=c:\tools\godot\4.2\godot42.exe

REM Check if any arguments were provided
if "%~1"=="" (
    set TEST_ARGS=-a tests
) else (
    set TEST_ARGS=%*
)

REM Run tests without debug mode to avoid hanging on compilation errors
%GODOT_BIN% -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd %TEST_ARGS%
SET exit_code=%errorlevel%
%GODOT_BIN% --headless --quiet -s res://addons/gdUnit4/bin/GdUnitCopyLog.gd %TEST_ARGS%

ECHO %exit_code%
EXIT /B %exit_code%
