@echo off
setlocal

REM Set the Godot binary path
set GODOT_BIN=c:\tools\godot\4.2\godot42.exe

REM Check if any arguments were provided
if "%~1"=="" (
    REM No arguments provided, use default
    addons\gdUnit4\runtest.cmd -a tests
) else (
    REM Arguments provided, pass them to the test runner
    addons\gdUnit4\runtest.cmd %*
)
