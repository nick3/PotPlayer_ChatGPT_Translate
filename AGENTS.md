# Repository Guidelines

## Project Structure & Module Organization
`SubtitleTranslate - ChatGPT.as` contains the real-time, context-aware translation pipeline and is the canonical source for shared helpers. `SubtitleTranslate - ChatGPT - Without Context.as` offers a lighter fallback; touch both when changing request formatting. Packaging scripts and resource catalogs live in `releases/build/` beside `installer.py` and the Windows-focused `build_installer.bat`. Fresh installers are staged in `releases/latest/`, with historical binaries preserved under `releases/archive/`. Reference artwork and localized documentation stay inside `docs/`. Use `api.txt` as the authoritative index for PotPlayer’s AngelScript API surface.

## Build, Test, and Development Commands
- `python "releases/build/installer.py"`: launches the PyQt6 wizard; run inside Windows (native or Wine) so COM shell integrations succeed.
- `pyinstaller` packaging mirrors the batch script. Execute `pyinstaller @releases/build/pyinstaller.args` after creating that response file from `build_installer.bat` to avoid copying the lengthy flag list by hand.
- Rapid iteration: copy the `.as` files into PotPlayer’s `Extension/Subtitle/Translate` folder, restart the player, and observe the effect via `HostOpenConsole()`.

## Coding Style & Naming Conventions
AngelScript modules use four-space indentation, early returns for guard clauses, and uppercase snake case for compile-time constants. Keep network and parsing logic in narrow, composable helpers so new providers can plug in without modifying consumers. Python tooling follows PEP 8; run `python -m black releases/build/installer.py` and prefer descriptive function names over comments for clarity.

## Testing Guidelines
Automated tests are absent; validate changes by replaying varied subtitle samples and watching the PotPlayer console for HTTP failures, throttling, or latency spikes. When editing installer code, exercise a clean PotPlayer installation to confirm shortcut discovery and asset deployment, then uninstall to ensure rollback paths succeed. Document which model, rate limits, and language pair you used during verification in the PR body.

## Commit & Pull Request Guidelines
Follow the existing history: short, imperative commit subjects (e.g., `Update SubtitleTranslate - ChatGPT.as`). Squash noisy work-in-progress commits before opening a PR. PR descriptions should outline behavioral changes, enumerate manual test steps, link related issues, and attach screenshots or clips for UI-impacting work.

## Security & Configuration Tips
Never commit API keys, personal endpoints, or end-user configuration files. Update `model_token_limits.json` and `language_strings.json` together, call out the change for translators, and publish SHA256 hashes alongside new installers so downstream users can verify downloads.
