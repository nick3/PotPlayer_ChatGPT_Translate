<a id="readme-top"></a>

[![Forks][forks-shield]]([forks-url])
[![Stargazers][stars-shield]]([stars-url])
[![Issues][issues-shield]]([issues-url])
[![License][license-shield]]([license-url])

<div style="text-align: right;">
  <strong>Readme in other languages:</strong>
  <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/readme_res/readme_zh.md">简体中文</a> | 
  <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/readme.md">English</a>
</div>
<div align="center">
  <h3 align="center">PotPlayer_ChatGPT_Translate 🚀</h3>
  <p align="center">
    A PotPlayer plugin that leverages the ChatGPT API to provide real-time, context-aware subtitle translation. ✨
  </p>
  <p align="center">
    <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues/new?labels=bug&template=bug-report---.md">🐞 Report Bug</a>
    &nbsp;&middot;&nbsp;
    <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues/new?labels=enhancement&template=feature-request---.md">💡 Request Feature</a>
  </p>
</div>

<!-- HTML Directory (Table of Contents) -->
<div>
  <h2>📑 Table of Contents</h2>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#video-tutorial">Video Tutorial</a></li>
    <li><a href="#built-with">Built With</a></li>
    <li>
      <a href="#installation">Installation</a>
      <ol>
        <li><a href="#fully-automatic-installation">Fully Automatic Installation</a></li>
        <li><a href="#manual-installation">Manual Installation</a></li>
      </ol>
    </li>
    <li><a href="#configuration">Configuration</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</div>

---

## About The Project 💬

**PotPlayer_ChatGPT_Translate** is a PotPlayer plugin that integrates the ChatGPT API to deliver real-time, context-aware subtitle translation. Unlike traditional translation tools, this plugin considers context, idioms, and cultural nuances to produce more accurate translations. The core of the project is implemented using AngleScript, leveraging both the ChatGPT API and PotPlayer API for deep integration.  
It is also compatible with any AI model that uses the same API calling method as ChatGPT.

### 🔍 Google Translate vs ChatGPT Translate (Image Comparison)

One key advantage of using ChatGPT for subtitle translation is its ability to understand context and cultural references. Compare the following results:

- **Original subtitle:**  
  > *"You're gonna old yeller my f**king universe."*

- **Google Translate Result:**  
  > *"你要老了我他妈的宇宙吗?"*  
  ![](https://github.com/Felix3322/PotPlayer_Chatgpt_Translate/blob/master/readme_res/Google%20translate.png)  
  _(Nonsensical and incorrect)_

- **ChatGPT Translation Result:**  
  > *"你要像《老黄犬》一样对待我的宇宙?"*  
  ![](https://github.com/Felix3322/PotPlayer_Chatgpt_Translate/blob/master/readme_res/Chatgpt.png)  
  _(Correctly captures the reference and intended meaning)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Video Tutorial 🎥

Click below to watch the tutorial on Bilibili:

<a href="https://www.bilibili.com/video/BV1w9FzegEbM" title="Watch on Bilibili">
  <img src="https://i1.hdslb.com/bfs/archive/88992bd0e80ff751771e78675a558b663a728028.jpg" alt="Watch on Bilibili">
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Built With 🛠

- **AngleScript** – The scripting language used to develop the plugin  
- **ChatGPT API** – Provides context-aware translation capabilities  
- **PotPlayer API** – Enables seamless integration with PotPlayer

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Installation 📦

### Fully Automatic Installation (Recommended) ⚡

1. **Download the Installer:**  
   [Fully Automatic Installer](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/releases/download/exe_installer/installer.exe)  
   *(The installer is open source, so you can review the source code)*
2. **Run the Installer:**  
   - Double-click `installer.exe` to start the installation.  
   - The installer automatically detects your PotPlayer installation path and completes the setup.

### Manual Installation 🔧

1. **Download the ZIP File:**  
   Download the latest ZIP file from this repository.
2. **Extract the ZIP File:**  
   Extract the contents to a temporary folder.
3. **Copy Files:**  
   Copy `ChatGPTSubtitleTranslate.as` and `ChatGPTSubtitleTranslate.ico` to the following directory:
   ```
   C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate
   ```
   Replace `C:\Program Files\DAUM\PotPlayer` with your custom PotPlayer installation path if necessary.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Configuration ⚙️

1. Open PotPlayer's **Preferences** (press **F5**).
2. Navigate to **Extensions > Subtitle translation**.
3. Select **ChatGPT Translate** as the translation plugin.
4. Configure the plugin:
    - **Model Name:**  
      You can simply enter the model name, which will use the default API URL.  
      **Example:** `gpt-4o-mini`  
      
      Alternatively, specify a custom API URL in the format:  
      `Model Name|API Interface URL`  
      **Example:** `gpt-4o-mini|https://api.openai.com/v1/chat/completions`
    - **API Key:** Enter your API key.
5. Set the source and target languages as required.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Usage ▶️

When playing a video with subtitles in PotPlayer, the plugin automatically calls the ChatGPT API to translate the subtitles in real time. By handling context, idioms, and cultural nuances, the plugin provides more accurate translations.

For example:  
- **Input:** *"You're gonna old yeller my f**king universe."*  
  - **Traditional Translation Tools** might output a literal or awkward translation.  
  - **ChatGPT Translation** captures the movie reference and context to deliver a more appropriate translation.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Roadmap 🗺

- [x] Integrate ChatGPT API with PotPlayer API for real-time subtitle translation.  
- [ ] Support additional AI models (planned for the future, not imminent).  
- [ ] Optimize context handling to further improve translation accuracy.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contributing 🤝

Contributions are welcome! When submitting a pull request, please clearly describe the purpose of your changes.  
If you have suggestions for improvements or bug fixes, feel free to open an issue before making modifications.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## License 📄

Distributed under the MIT License. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contact 📞

I will add something here in the future.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Acknowledgments 🙏

- Thanks to OpenAI for providing the powerful ChatGPT API.  
- Thanks to the PotPlayer team for creating an excellent media player.  
- Thanks to everyone who has contributed suggestions or code to improve this project (contributor details will be updated here).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

<!-- MARKDOWN LINKS & IMAGES -->
[stars-shield]: https://img.shields.io/github/stars/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[stars-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/stargazers
[forks-shield]: https://img.shields.io/github/forks/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[forks-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/network/members
[issues-shield]: https://img.shields.io/github/issues/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[issues-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues
[license-shield]: https://img.shields.io/github/license/Felix3322/PotPlayer_ChatGPT_Translate.svg?style=for-the-badge
[license-url]: https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/LICENSE
