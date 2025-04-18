#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
PotPlayer ChatGPT Translate Installer  (PyQt 6 版)
Author : Felix3322
"""

from __future__ import annotations
import os, sys, shutil, threading, ctypes, json, webbrowser
from functools import partial
from pathlib import Path
from typing import Dict, List

from PyQt6.QtCore import Qt, QThread, pyqtSignal
from PyQt6.QtGui  import QFont, QDesktopServices
from PyQt6.QtWidgets import (QApplication, QWidget, QStackedWidget, QLabel, QRadioButton, QPushButton,
                             QVBoxLayout, QHBoxLayout, QFileDialog, QTextEdit, QLineEdit, QComboBox,
                             QMessageBox, QButtonGroup, QPlainTextEdit, QProgressBar, QInputDialog)

# ---------- external optional ----------
try:
    import requests
except ImportError:
    requests = None
# ---------------------------------------

# ---------------- 预置模型 ↔ APIBase -----------------
MODEL_CATALOG: Dict[str, str] = {
    # OpenAI 4.1 & 4o
    "gpt-4.1":        "https://api.openai.com/v1/chat/completions",
    "gpt-4.1-mini":   "https://api.openai.com/v1/chat/completions",
    "gpt-4.1-nano":   "https://api.openai.com/v1/chat/completions",
    "gpt-4o":         "https://api.openai.com/v1/chat/completions",
    "gpt-4o-mini":    "https://api.openai.com/v1/chat/completions",
    # Google Gemini
    "gemini-1.0":     "https://gemini.googleapis.com/v1/chat/completions",
    "gemini-pro":     "https://gemini.googleapis.com/v1/chat/completions",
    "gemini-ultra":   "https://gemini.googleapis.com/v1/chat/completions",
    # Anthropic Claude‑3
    "claude-3-opus":  "https://api.anthropic.com/v1/complete",
    "claude-3-sonic": "https://api.anthropic.com/v1/complete",
    # Mistral
    "mistral-large":  "https://api.mistral.ai/v1/chat/completions",
    "mistral-medium": "https://api.mistral.ai/v1/chat/completions"
}

# ------------ 双语言字符串 ---------------------------
LANG = {
    "en": {
        "title"          : "PotPlayer ChatGPT Translate Installer",
        "choose_lang"    : "Choose your language:",
        "next"           : "Next",  "back": "Back", "cancel": "Cancel", "finish": "Finish",
        "welcome"        : "Welcome to the PotPlayer ChatGPT Translate Installer (v1.6)\n\nPlease follow the steps to install.",
        "license"        : "License Agreement",
        "agree"          : "I Agree", "disagree": "I Disagree",
        "license_reject" : "You must agree to the license to continue.",
        "select_dir"     : "Select the PotPlayer Translate directory:",
        "browse"         : "Browse",
        "auto_detected"  : "Detected PotPlayer path:\n{}\nIs this correct?",
        "choose_version" : "Choose the version to install:",
        "with_ctx"       : "Installer with Context Handling",
        "without_ctx"    : "Installer without Context Handling",
        "with_desc"      : "Advanced context‑aware processing (more accurate but higher cost).",
        "without_desc"   : "Lightweight version without context (lower cost).",
        "cfg_edit"       : "Edit configuration variables below:",
        "api_key"        : "API Key:",
        "api_url"        : "API URL:",
        "model"          : "Model:",
        "test_api"       : "Test API",
        "fix_base"       : "Fix API Base",
        "test_success"   : "API test succeeded. Available models updated.",
        "test_failed"    : "API test failed:\n{}",
        "auto_fixed"     : "Endpoint auto‑fixed to {}\nTest passed.",
        "config_allow"   : "Allow configuration in PotPlayer script",
        "config_lock"    : "Lock configuration (use installer settings only)",
        "install_progress": "Installation Progress:",
        "copying"        : "Copying {} ...",
        "file_exists"    : "File {} already exists.",
        "overwrite"      : "Overwrite", "create_copy": "Create Copy",
        "enter_new_name" : "Please enter the new file name:",
        "name_empty"     : "File name cannot be empty.",
        "install_cancel" : "Installation cancelled.",
        "install_complete": "Installation completed successfully!",
        "install_failed" : "Installation failed: {}",
        "need_admin"     : "This installer needs to be run with administrator privileges.\nPlease restart as administrator.",
        "link_openai"    : "Open OpenAI Keys",
        "link_gemini"    : "Open Gemini Keys",
        "link_claude"    : "Open Anthropic Keys",
        "link_mistral"   : "Open Mistral Keys",
        "author"         : "Author: Felix3322  |  Project: https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"
    },
    "zh": {
        "title"          : "PotPlayer ChatGPT 翻译安装程序",
        "choose_lang"    : "选择语言：",
        "next"           : "下一步",  "back": "上一步", "cancel": "取消", "finish": "完成",
        "welcome"        : "欢迎使用 PotPlayer ChatGPT 翻译安装程序 (v1.6)\n\n请按步骤完成安装。",
        "license"        : "许可协议",
        "agree"          : "我同意", "disagree": "我不同意",
        "license_reject" : "必须同意许可协议才能继续。",
        "select_dir"     : "请选择 PotPlayer 的 Translate 目录：",
        "browse"         : "浏览",
        "auto_detected"  : "检测到的 PotPlayer 路径：\n{}\n是否正确？",
        "choose_version" : "请选择安装的版本：",
        "with_ctx"       : "带上下文处理安装包",
        "without_ctx"    : "不带上下文处理安装包",
        "with_desc"      : "高级上下文处理（更精准但成本更高）。",
        "without_desc"   : "轻量版（无上下文，成本更低）。",
        "cfg_edit"       : "请编辑下方配置：",
        "api_key"        : "API 密钥：",
        "api_url"        : "API 地址：",
        "model"          : "模型：",
        "test_api"       : "测试 API",
        "fix_base"       : "修正 API Base",
        "test_success"   : "API 测试成功，可用模型已更新。",
        "test_failed"    : "API 测试失败：\n{}",
        "auto_fixed"     : "已自动修正为 {}\n测试通过。",
        "config_allow"   : "允许脚本内配置",
        "config_lock"    : "锁定配置（仅使用安装器设置）",
        "install_progress": "安装进度：",
        "copying"        : "正在复制 {} ...",
        "file_exists"    : "文件 {} 已存在。",
        "overwrite"      : "覆盖", "create_copy": "创建副本",
        "enter_new_name" : "请输入新的文件名：",
        "name_empty"     : "文件名不能为空。",
        "install_cancel" : "安装已取消。",
        "install_complete": "安装成功！",
        "install_failed" : "安装失败：{}",
        "need_admin"     : "此安装器需要以管理员权限运行，请以管理员身份重启。",
        "link_openai"    : "打开 OpenAI 密钥页面",
        "link_gemini"    : "打开 Gemini 密钥页面",
        "link_claude"    : "打开 Anthropic 密钥页面",
        "link_mistral"   : "打开 Mistral 密钥页面",
        "author"         : "作者: Felix3322  |  项目: https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"
    }
}

# --------- 离线脚本/图标文件 ---------
OFFLINE_FILES = {
    "with_context": [
        ("SubtitleTranslate - ChatGPT.as", "SubtitleTranslate - ChatGPT.as"),
        ("SubtitleTranslate - ChatGPT.ico", "SubtitleTranslate - ChatGPT.ico")
    ],
    "without_context": [
        ("SubtitleTranslate - ChatGPT - Without Context.as", "SubtitleTranslate - ChatGPT - Without Context.as"),
        ("SubtitleTranslate - ChatGPT - Without Context.ico", "SubtitleTranslate - ChatGPT - Without Context.as")
    ]
}

SCRIPT_DIR = Path(__file__).resolve().parent
LICENSE_PATH = SCRIPT_DIR / "../../LICENSE"

# --------- 管理员检测 ----------
def is_admin() -> bool:
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()  # type: ignore
    except Exception:
        return False

def restart_as_admin():
    QMessageBox.warning(None, "Admin", LANG["en"]["need_admin"]+"\n\n"+LANG["zh"]["need_admin"])
    params = " ".join(f'"{a}"' for a in sys.argv)
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, params, None, 1)  # type: ignore
    sys.exit()

# --------- API 测试 & 修正 ----------
def fix_base(url: str) -> str:
    url = url.rstrip("/")
    return url+"/chat/completions" if not url.endswith("chat/completions") else url

def test_api_get_models(api_key: str, api_url: str) -> List[str]:
    if not requests:
        raise RuntimeError("`pip install requests` first!")
    endpoint = fix_base(api_url)
    headers = {"Authorization": f"Bearer {api_key}",
               "Content-Type": "application/json"}
    # ping
    test_payload = {"model": "gpt-4o-mini", "messages":[{"role":"user","content":"ping"}], "max_tokens":1}
    r = requests.post(endpoint, headers=headers, json=test_payload, timeout=8)
    r.raise_for_status()
    # list
    base = endpoint.rsplit("/", 2)[0]
    lst = requests.get(f"{base}/models", headers=headers, timeout=8).json()
    data = lst.get("data", [])
    return [d["id"] for d in data if isinstance(d, dict) and "id" in d]

# --------- 复制线程 ----------
class Worker(QThread):
    progress = pyqtSignal(str)
    done     = pyqtSignal()

    def __init__(self, dest: Path, version: str, cfg: Dict[str,str|bool], lang: str):
        super().__init__()
        self.dest = dest
        self.version = version
        self.cfg = cfg
        self.t = LANG[lang]

    def emit(self, msg: str):
        self.progress.emit(msg)

    def run(self):
        try:
            for src, dst in OFFLINE_FILES[self.version]:
                sp = SCRIPT_DIR / src
                dp = self.dest / dst
                self.emit(self.t["copying"].format(src))
                if not sp.exists():
                    raise FileNotFoundError(src)
                if dp.exists():
                    resp = QMessageBox.question(None, "Exists",
                                self.t["file_exists"].format(dst),
                                QMessageBox.StandardButton.Yes | QMessageBox.StandardButton.No)
                    if resp == QMessageBox.StandardButton.No:
                        new_name, ok = QInputDialog.getText(None, "Custom", self.t["enter_new_name"])
                        if not ok or not new_name:
                            self.emit(self.t["install_cancel"])
                            return
                        dp = self.dest / (new_name if "." in new_name else new_name+dp.suffix)
                shutil.copy2(sp, dp)

                if dp.suffix.lower() == ".as":      # 写入配置
                    txt = dp.read_text(encoding="utf-8").splitlines()
                    out = []
                    for line in txt:
                        s = line.strip()
                        if s.startswith("string CONFIG_API_KEY"):
                            out.append(f'string CONFIG_API_KEY         = "{self.cfg["api_key"]}";')
                        elif s.startswith("string CONFIG_SELECTED_MODEL"):
                            out.append(f'string CONFIG_SELECTED_MODEL  = "{self.cfg["model"]}";')
                        elif s.startswith("string CONFIG_API_URL"):
                            out.append(f'string CONFIG_API_URL         = "{self.cfg["api_url"]}";')
                        elif s.startswith("bool   USE_USER_CONFIG"):
                            out.append(f'bool   USE_USER_CONFIG        = {"true" if self.cfg["allow"] else "false"};')
                        else:
                            out.append(line)
                    dp.write_text("\n".join(out), encoding="utf-8")
            self.emit(self.t["install_complete"])
        except Exception as e:
            self.emit(self.t["install_failed"].format(e))
        finally:
            self.done.emit()

# ============ UI Pages =============
class Page(QWidget):
    def __init__(self, gui:"InstallerGUI"): super().__init__(); self.gui = gui

class LangPage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v = QVBoxLayout(self)
        self.en = QRadioButton("English"); self.en.setChecked(True)
        self.cn = QRadioButton("中文")
        v.addWidget(QLabel(LANG["en"]["choose_lang"]+"\n"+LANG["zh"]["choose_lang"]))
        v.addWidget(self.en); v.addWidget(self.cn)
        nxt = QPushButton("Next / 下一步"); v.addWidget(nxt)
        nxt.clicked.connect(self.next)
    def next(self):
        self.gui.lang = "zh" if self.cn.isChecked() else "en"
        self.gui.setTexts()
        self.gui.nextPage()

class WelcomePage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v = QVBoxLayout(self)
        self.label = QLabel(); self.label.setWordWrap(True); self.label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        self.label.setFont(QFont("", 11))
        v.addWidget(self.label,2)
        nxt = QPushButton(); self.nxt=nxt
        v.addWidget(nxt); nxt.clicked.connect(self.gui.nextPage)
        author = QLabel(LANG["en"]["author"]); author.setAlignment(Qt.AlignmentFlag.AlignBottom|Qt.AlignmentFlag.AlignHCenter)
        author.linkActivated.connect(lambda _: webbrowser.open("https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"))
        author.setOpenExternalLinks(True); v.addWidget(author)
    def retranslate(self):
        t = LANG[self.gui.lang]
        self.label.setText(t["welcome"])
        self.nxt.setText(t["next"])

class LicensePage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v = QVBoxLayout(self)
        self.title = QLabel(); self.title.setAlignment(Qt.AlignmentFlag.AlignCenter); v.addWidget(self.title)
        txt = QPlainTextEdit(readonly=True); txt.setReadOnly(True); txt.setPlainText(LICENSE_PATH.read_text(encoding="utf-8")); v.addWidget(txt,4)
        h = QHBoxLayout(); v.addLayout(h)
        self.agree = QPushButton(); self.dis = QPushButton()
        h.addWidget(self.agree); h.addWidget(self.dis)
        self.agree.clicked.connect(self.gui.nextPage)
        self.dis.clicked.connect(lambda: QMessageBox.warning(self,"",LANG[self.gui.lang]["license_reject"]))
    def retranslate(self):
        t = LANG[self.gui.lang]
        self.title.setText(t["license"])
        self.agree.setText(t["agree"]); self.dis.setText(t["disagree"])

class DirPage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v = QVBoxLayout(self)
        self.label = QLabel(); v.addWidget(self.label)
        h = QHBoxLayout(); self.path = QLineEdit(); self.path.setReadOnly(True); h.addWidget(self.path)
        self.browse = QPushButton(); h.addWidget(self.browse); v.addLayout(h)
        btn = QPushButton(); self.next = btn; v.addWidget(btn)
        self.browse.clicked.connect(self.pick)
        self.next.clicked.connect(self.proceed)
    def pick(self):
        d = QFileDialog.getExistingDirectory(self,"Select")
        if d: self.path.setText(d)
    def proceed(self):
        if not self.path.text():
            QMessageBox.warning(self,"",LANG[self.gui.lang]["select_dir"])
            return
        self.gui.install_dir = Path(self.path.text())
        self.gui.nextPage()
    def on_enter(self):
        t = LANG[self.gui.lang]; self.label.setText(t["select_dir"]); self.browse.setText(t["browse"]); self.next.setText(t["next"])
        det = self.auto_detect()
        if det and QMessageBox.question(self,"?",t["auto_detected"].format(det))==QMessageBox.StandardButton.Yes:
            self.path.setText(det)
            self.proceed()
    def auto_detect(self)->str|None:
        # 简版自动识别
        for drive in "CDEFGHIJKLMNOPQRSTUVWXYZ":
            p = Path(f"{drive}:\\Program Files\\DAUM\\PotPlayer\\Extension\\Subtitle\\Translate")
            if p.exists(): return str(p)
        return None

class VerPage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v=QVBoxLayout(self)
        self.lbl=QLabel(); v.addWidget(self.lbl)
        self.btnGrp = QButtonGroup(self)
        self.rb1=QRadioButton(); self.rb2=QRadioButton(); self.btnGrp.addButton(self.rb1); self.btnGrp.addButton(self.rb2)
        desc1=QLabel(); desc2=QLabel(); desc1.setWordWrap(True); desc2.setWordWrap(True)
        self.desc1=desc1; self.desc2=desc2
        v.addWidget(self.rb1); v.addWidget(desc1); v.addWidget(self.rb2); v.addWidget(desc2)
        h=QHBoxLayout(); self.back=QPushButton(); self.next=QPushButton(); h.addWidget(self.back); h.addWidget(self.next); v.addLayout(h)
        self.rb1.setChecked(True)
        self.back.clicked.connect(lambda:self.gui.prevPage())
        self.next.clicked.connect(self.proceed)
    def retranslate(self):
        t=LANG[self.gui.lang]
        self.lbl.setText(t["choose_version"]); self.rb1.setText(t["with_ctx"]); self.rb2.setText(t["without_ctx"])
        self.desc1.setText(t["with_desc"]); self.desc2.setText(t["without_desc"])
        self.back.setText(t["back"]); self.next.setText(t["next"])
    def proceed(self):
        self.gui.version = "with_context" if self.rb1.isChecked() else "without_context"
        self.gui.nextPage()

class CfgPage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v=QVBoxLayout(self)
        self.info=QLabel(); v.addWidget(self.info)
        # form
        formlay=QVBoxLayout(); v.addLayout(formlay)
        self.key=QLineEdit(); self.url=QLineEdit()
        self.model=QComboBox(); self.model.addItems(MODEL_CATALOG.keys())
        form_items=[("api_key",self.key),("api_url",self.url),("model",self.model)]
        for tag,widget in form_items:
            label=QLabel(); label.setObjectName(tag); formlay.addWidget(label); formlay.addWidget(widget)
        # quick links
        linklay=QHBoxLayout(); v.addLayout(linklay)
        self.l_openai=QPushButton(); self.l_gemini=QPushButton(); self.l_claude=QPushButton(); self.l_mistral=QPushButton()
        for b,url in [(self.l_openai,"https://platform.openai.com/account/api-keys"),
                      (self.l_gemini,"https://aistudio.google.com/app/apikey"),
                      (self.l_claude,"https://console.anthropic.com/settings/keys"),
                      (self.l_mistral,"https://console.mistral.ai/api-keys")]:
            b.clicked.connect(partial(QDesktopServices.openUrl, url)); linklay.addWidget(b)
        # test & fix
        h=QHBoxLayout(); v.addLayout(h)
        self.test=QPushButton(); self.fix=QPushButton()
        h.addWidget(self.test); h.addWidget(self.fix)
        # allow/lock
        self.allow_rb=QRadioButton(); self.lock_rb=QRadioButton()
        self.allow_rb.setChecked(True)
        v.addWidget(self.allow_rb); v.addWidget(self.lock_rb)
        # nav
        nav=QHBoxLayout(); self.back=QPushButton(); self.next=QPushButton()
        nav.addWidget(self.back); nav.addWidget(self.next); v.addLayout(nav)
        # signals
        self.model.currentTextChanged.connect(self.sync_base)
        self.test.clicked.connect(self.do_test)
        self.fix.clicked.connect(self.do_fix)
        self.back.clicked.connect(lambda:self.gui.prevPage())
        self.next.clicked.connect(self.auto_next)
    def retranslate(self):
        t=LANG[self.gui.lang]
        self.info.setText(t["cfg_edit"])
        for w in self.findChildren(QLabel):
            if w.objectName(): w.setText(t[w.objectName()])
        self.l_openai.setText(t["link_openai"]); self.l_gemini.setText(t["link_gemini"])
        self.l_claude.setText(t["link_claude"]); self.l_mistral.setText(t["link_mistral"])
        self.test.setText(t["test_api"]); self.fix.setText(t["fix_base"])
        self.allow_rb.setText(t["config_allow"]); self.lock_rb.setText(t["config_lock"])
        self.back.setText(t["back"]); self.next.setText(t["next"])
        # default values
        self.model.setCurrentText("gpt-4.1-nano")
        self.sync_base("gpt-4.1-nano")
    def sync_base(self, m): self.url.setText(MODEL_CATALOG.get(m, self.url.text()))
    def do_test(self):
        t=LANG[self.gui.lang]
        try:
            models = test_api_get_models(self.key.text().strip(), self.url.text().strip())
            self.model.clear(); self.model.addItems(models)
            QMessageBox.information(self,"OK",t["test_success"])
        except Exception as e:
            QMessageBox.warning(self,"ERR",t["test_failed"].format(e))
    def do_fix(self):
        self.url.setText(fix_base(self.url.text()))
        # 立即再测
        try:
            test_api_get_models(self.key.text().strip(), self.url.text().strip())
            QMessageBox.information(self,"",LANG[self.gui.lang]["auto_fixed"].format(self.url.text()))
        except Exception as e:
            QMessageBox.warning(self,"ERR",LANG[self.gui.lang]["test_failed"].format(e))
    def auto_next(self):
        # 自动验证，再进下一页
        try:
            test_api_get_models(self.key.text().strip(), self.url.text().strip())
        except Exception as e:
            if QMessageBox.question(self,"ERR",LANG[self.gui.lang]["test_failed"].format(e)+"\n继续？")==QMessageBox.StandardButton.No:
                return
        self.gui.cfg = {
            "api_key": self.key.text().strip(),
            "api_url": self.url.text().strip(),
            "model": self.model.currentText(),
            "allow": self.allow_rb.isChecked()
        }
        self.gui.nextPage()

class ProgPage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v=QVBoxLayout(self)
        self.lbl=QLabel(); v.addWidget(self.lbl)
        self.out=QPlainTextEdit(readonly=True); self.out.setReadOnly(True); v.addWidget(self.out,3)
        self.cancel=QPushButton(); v.addWidget(self.cancel)
        self.cancel.clicked.connect(self.gui.close)
    def retranslate(self):
        self.lbl.setText(LANG[self.gui.lang]["install_progress"])
        self.cancel.setText(LANG[self.gui.lang]["cancel"])
    def start(self):
        self.out.clear()
        worker = Worker(self.gui.install_dir, self.gui.version, self.gui.cfg, self.gui.lang)
        worker.progress.connect(self.out.appendPlainText)
        worker.done.connect(self.gui.nextPage)
        worker.start()

class DonePage(Page):
    def __init__(self, gui):
        super().__init__(gui)
        v=QVBoxLayout(self)
        self.lbl=QLabel(); self.lbl.setAlignment(Qt.AlignmentFlag.AlignCenter); v.addWidget(self.lbl,2)
        self.btn=QPushButton(); v.addWidget(self.btn)
        self.btn.clicked.connect(gui.close)
    def retranslate(self):
        t=LANG[self.gui.lang]
        self.lbl.setText(t["install_complete"])
        self.btn.setText(t["finish"])

# --------------- Main GUI ---------------
class InstallerGUI(QWidget):
    def __init__(self):
        super().__init__()
        self.lang="en"
        self.version="with_context"
        self.cfg={}
        self.install_dir=Path()
        self.setWindowTitle(LANG["en"]["title"])
        self.stack=QStackedWidget(self)
        v=QVBoxLayout(self); v.addWidget(self.stack)
        # pages
        self.pages=[LangPage(self), WelcomePage(self), LicensePage(self),
                    DirPage(self), VerPage(self), CfgPage(self),
                    ProgPage(self), DonePage(self)]
        for p in self.pages: self.stack.addWidget(p)
        self.setMinimumSize(580,580)
        self.setTexts()
    # helpers
    def setTexts(self):
        self.setWindowTitle(LANG[self.lang]["title"])
        for p in self.pages[1:]:    # LangPage 不用重载
            if hasattr(p,"retranslate"):p.retranslate()
    def nextPage(self):
        idx=self.stack.currentIndex()+1
        if idx<len(self.pages):
            self.stack.setCurrentIndex(idx)
            if isinstance(self.pages[idx], DirPage): self.pages[idx].on_enter()
            if isinstance(self.pages[idx], ProgPage): self.pages[idx].start()
    def prevPage(self): self.stack.setCurrentIndex(max(0,self.stack.currentIndex()-1))

# --------------- main -------------------
def main():
    if not is_admin(): restart_as_admin()
    app=QApplication(sys.argv)
    gui=InstallerGUI(); gui.show()
    sys.exit(app.exec())
if __name__=="__main__":
    main()
