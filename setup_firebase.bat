@echo off
echo ===========================================
echo      Initializing Firebase Setup
echo ===========================================
echo.
echo Step 1: Logging into Firebase...
echo (A browser window should open. If not, click the link provided)
call firebase login
echo.
echo ===========================================
echo Step 2: Configuring Flutter App
echo ===========================================
echo.
echo Please select your project (khdemti-1341) and platforms (Android, iOS) using the arrow keys and Enter.
call flutterfire configure
echo.
echo ===========================================
echo             Setup Complete!
echo ===========================================
pause
