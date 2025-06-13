@echo off
for /f "delims=" %%v in ('python -c "import re,sys;print(re.search(r'PLUGIN_VERSION\s*=\s*\"(.+?)\"',open('installer.py').read()).group(1))"') do set VERSION=%%v
pyinstaller -F -w --clean ^
  --add-data "..\..\SubtitleTranslate - ChatGPT.as;." ^
  --add-data "..\..\SubtitleTranslate - ChatGPT.ico;." ^
  --add-data "..\..\SubtitleTranslate - ChatGPT - Without Context.as;." ^
  --add-data "..\..\SubtitleTranslate - ChatGPT - Without Context.ico;." ^
  --add-data "..\..\LICENSE;." ^
  --distpath "..\latest" ^
  --name installer.v%VERSION% installer.py
if exist build rmdir /s /q build
if exist installer.spec del installer.spec
if exist "..\latest\installer.exe" del "..\latest\installer.exe"
rename "..\latest\installer.v%VERSION%.exe" "installer.exe"
copy "installer.exe" "..\archive\installer.v%VERSION%.exe" >nul
