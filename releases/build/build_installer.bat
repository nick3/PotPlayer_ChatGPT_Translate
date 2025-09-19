cd C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\.venv\Scripts
python -m PyInstaller -F -w --clean --uac-admin ^
  --collect-all openai ^
  --collect-submodules httpx ^
  --collect-submodules anyio ^
  --distpath "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\releases\latest" ^
  --name installer ^
  --icon "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\icon.ico" ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\SubtitleTranslate - ChatGPT.as;." ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\SubtitleTranslate - ChatGPT.ico;." ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\SubtitleTranslate - ChatGPT - Without Context.as;." ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\SubtitleTranslate - ChatGPT - Without Context.ico;." ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\releases\build\language_strings.json;." ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\releases\build\model_token_limits.json;." ^
  --add-data "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\LICENSE;." ^
  "C:\Users\Felix\PycharmProjects\PotPlayer_Chatgpt_Translate\releases\build\installer.py"
rmdir /s /q build
del /f /q installer.spec
