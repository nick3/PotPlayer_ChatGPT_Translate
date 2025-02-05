<a id="readme-top"></a>

[![Forks][forks-shield]]([forks-url])
[![Stargazers][stars-shield]]([stars-url])
[![Issues][issues-shield]]([issues-url])
[![License][license-shield]]([license-url])

<div align="right">
  <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/readme_res/readme_zh.md">简体中文</a> | 
  <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/blob/master/readme.md">English</a>
</div>

<div align="center">
  <h3 align="center">PotPlayer_ChatGPT_Translate 🚀</h3>
  <p align="center">
    一个利用 ChatGPT API 提供实时、上下文感知字幕翻译的 PotPlayer 插件。✨
  </p>
  <p align="center">
    <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues/new?labels=bug&template=bug-report---.md">🐞 报告 Bug</a>
    &nbsp;&middot;&nbsp;
    <a href="https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/issues/new?labels=enhancement&template=feature-request---.md">💡 请求新功能</a>
  </p>
</div>

<!-- HTML 目录 (Table of Contents) -->
<div>
  <h2>📑 目录</h2>
  <ol>
    <li><a href="#about-the-project">关于项目</a></li>
    <li><a href="#video-tutorial">视频教程</a></li>
    <li><a href="#built-with">构建工具</a></li>
    <li>
      <a href="#installation">安装</a>
      <ol>
        <li><a href="#fully-automatic-installation">全自动安装（推荐）</a></li>
        <li><a href="#manual-installation">手动安装</a></li>
      </ol>
    </li>
    <li><a href="#configuration">配置</a></li>
    <li><a href="#usage">使用方法</a></li>
    <li><a href="#roadmap">开发计划</a></li>
    <li><a href="#contributing">贡献指南</a></li>
    <li><a href="#license">许可证</a></li>
    <li><a href="#contact">联系方式</a></li>
    <li><a href="#acknowledgments">致谢</a></li>
  </ol>
</div>

---

## 关于项目 💬

**PotPlayer_ChatGPT_Translate** 是一个 PotPlayer 插件，它整合了 ChatGPT API，以实现实时、上下文感知的字幕翻译。与传统翻译工具不同，该插件能够考虑上下文、惯用语和文化差异，从而提供更准确的翻译。项目的核心部分使用 AngleScript 实现，并结合了 ChatGPT API 与 PotPlayer API 实现深度集成。  
### 该插件同样兼容任何使用与 ChatGPT 相同 API 调用方式的 AI 模型。

## 🔍 Google 翻译 vs ChatGPT 翻译（图像对比）

使用 ChatGPT 进行字幕翻译的一大优势在于它能够理解上下文和文化参考。请看下面的对比：

- **原始字幕：**  
  > *"You're gonna old yeller my f**king universe."*

- **Google 翻译结果：**  
  > *"你要老了我他妈的宇宙吗?"*  
  ![](https://github.com/Felix3322/PotPlayer_Chatgpt_Translate/blob/master/readme_res/Google%20translate.png)  
  _(意义不明且不正确)_

- **ChatGPT 翻译结果：**  
  > *"你要像《老黄犬》一样对待我的宇宙?"*  
  ![](https://github.com/Felix3322/PotPlayer_Chatgpt_Translate/blob/master/readme_res/Chatgpt.png)  
  _(准确捕捉了引用及其意图)_

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 视频教程 🎥

点击下面的视频链接，在 Bilibili 上观看教程：

<a href="https://www.bilibili.com/video/BV1w9FzegEbM" title="在 Bilibili 上观看">
  <img src="https://i1.hdslb.com/bfs/archive/88992bd0e80ff751771e78675a558b663a728028.jpg" alt="在 Bilibili 上观看">
</a>

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 技术栈 🛠

- **AngleScript** – 用于开发插件的脚本语言  
- **ChatGPT API** – 提供上下文感知的翻译功能  
- **PotPlayer API** – 实现与 PotPlayer 的无缝集成

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 安装 📦

### 全自动安装（推荐） ⚡

1. **下载安装程序：**  
   [全自动安装程序](https://github.com/Felix3322/PotPlayer_ChatGPT_Translate/releases/download/exe_installer/installer.exe)  
   *(安装程序是开源的，你可以查看其源码)*
2. **运行安装程序：**  
   - 双击 installer.exe 启动安装。  
   - 安装程序会自动检测你的 PotPlayer 安装路径并完成安装设置。

### 手动安装 🔧

1. **下载 ZIP 文件：**  
   从本仓库下载最新的 ZIP 文件。
2. **解压 ZIP 文件：**  
   将内容解压到临时文件夹中。
3. **复制文件：**  
   将 `ChatGPTSubtitleTranslate.as` 和 `ChatGPTSubtitleTranslate.ico` 复制到以下目录：
   
   ```
   C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate
   ```
   
   如果你的 PotPlayer 安装在其他位置，请将 `C:\Program Files\DAUM\PotPlayer` 替换为相应路径。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 配置 ⚙️

1. 打开 PotPlayer 的 **首选项**（按 **F5**）。
2. 导航至 **扩展 > 字幕翻译**。
3. 选择 **ChatGPT Translate** 作为翻译插件。
4. 配置插件：
    - **模型名称：**  
      你可以直接输入模型名称，此时将使用默认 API URL。  
      **例如：** `gpt-4o-mini`
      
      或者，可以按照以下格式指定自定义 API URL：  
      `模型名称|API 接口 URL`  
      **例如：** `gpt-4o-mini|https://api.openai.com/v1/chat/completions`
    - **API 密钥：** 输入你的 API 密钥。
      > 你可以在此页面 **[keytest.obanarchy.org](https://keytest.obanarchy.org/)** 测试你的API Key是否有效.  
5. 根据需要设置源语言和目标语言。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 使用方法 ▶️

在 PotPlayer 播放带有字幕的视频时，该插件会自动调用 ChatGPT API 实现实时字幕翻译。通过对上下文、惯用语和文化差异的处理，插件提供了更为精准的翻译。

例如：  
- **输入：** *"You're gonna old yeller my f**king universe."*  
  - **传统翻译工具** 可能会输出直译或生硬的翻译。  
  - **ChatGPT 翻译** 则能捕捉电影引用和上下文，提供更贴切的翻译结果。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 开发计划 🗺

- [x] 与 PotPlayer API 集成 ChatGPT API，实现实时字幕翻译。  
- [ ] 支持更多 AI 模型（计划中，近期内不实现）。  
- [ ] 优化上下文处理，进一步提高翻译准确性。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 贡献指南 🤝

欢迎所有贡献！在提交 Pull Request 时，请清楚描述你所做的修改内容。  
如果你有改进建议或 Bug 修复，请在修改前先通过 Issue 进行讨论。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 许可证 📄

本项目采用 MIT 许可证进行分发。更多信息请参阅 LICENSE 文件。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 联系方式 📞

未来我会在此添加更多联系方式信息。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

---

## 致谢 🙏

- 感谢 OpenAI 提供强大的 ChatGPT API。  
- 感谢 PotPlayer 团队打造出色的媒体播放器。  
- 感谢所有对本项目提出建议或贡献代码的朋友（贡献者名单会在此更新）。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

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
