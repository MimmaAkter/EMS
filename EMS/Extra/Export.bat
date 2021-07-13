@echo off
For /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set mydate=%%c_%%a_%%b)
For /f "tokens=1-2 delims=/:" %%a in ("%time%") do (set mytime=%%a%%b)
EXP HRMS/HRMS@TEXTILE file = HRMS_%mydate%_%mytime%