@echo off
ant -buildfile %~dp0\build.xml compile
pause >nul