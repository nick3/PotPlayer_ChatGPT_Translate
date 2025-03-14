import os
import sys
import ctypes
import threading
import shutil
import win32com.client
import tkinter as tk
from tkinter import filedialog, messagebox
import webbrowser

LANGUAGE_STRINGS = {
    "en": {
        "admin_required": "This installer needs to be run with administrator privileges.\nPlease restart as administrator.",
        "select_directory": "Please select the PotPlayer Translate directory.",
        "installation_complete": "Installation completed successfully!",
        "choose_version": "Choose the version to install:",
        "without_context": "Installer without Context Handling",
        "with_context": "Installer with Context Handling",
        "installation_failed": "Installation failed: {}",
        "welcome_message": "Welcome to the PotPlayer ChatGPT Translate Installer (v1.5)\n\nPlease follow the steps to install.",
        "new_installer_notice": "This new installer is ready. Press Next to continue.",
        "select_install_dir": "Select the PotPlayer Translate directory:",
        "browse": "Browse",
        "next": "Next",
        "back": "Back",
        "choose_language": "Choose your language:",
        "language_english": "English",
        "language_chinese": "中文",
        "with_context_description": "Advanced context-aware processing (more accurate but higher cost).",
        "without_context_description": "Lightweight version without context (lower cost).",
        "confirm_path": "Detected PotPlayer path:\n{}\nIs this correct?",
        "license_title": "License Agreement",
        "license_agree": "I Agree",
        "license_disagree": "I Disagree",
        "license_reject": "You must agree to the license to continue.",
        "install_progress": "Installation Progress:",
        "cancel": "Cancel",
        "finish": "Finish",
        "author_info": "Author: Felix3322  |  Project: https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"
    },
    "zh": {
        "admin_required": "此安装器需要以管理员权限运行，请以管理员身份重启。",
        "select_directory": "请选择PotPlayer的Translate目录。",
        "installation_complete": "安装成功！",
        "choose_version": "请选择安装的版本：",
        "without_context": "不带上下文处理的安装包",
        "with_context": "带上下文处理的安装包",
        "installation_failed": "安装失败：{}",
        "welcome_message": "欢迎使用PotPlayer ChatGPT 翻译安装程序 (v1.5)\n\n请按照步骤完成安装。",
        "new_installer_notice": "新的安装器已就绪，按“下一步”继续。",
        "select_install_dir": "请选择PotPlayer的Translate目录：",
        "browse": "浏览",
        "next": "下一步",
        "back": "上一步",
        "choose_language": "选择语言：",
        "language_english": "English",
        "language_chinese": "中文",
        "with_context_description": "高级上下文处理（翻译更精准，但成本较高）。",
        "without_context_description": "轻量版（不带上下文处理，成本较低）。",
        "confirm_path": "检测到的PotPlayer路径：\n{}\n是否正确？",
        "license_title": "许可协议",
        "license_agree": "我同意",
        "license_disagree": "我不同意",
        "license_reject": "必须同意许可协议才能继续。",
        "install_progress": "安装进度：",
        "cancel": "取消",
        "finish": "完成",
        "author_info": "作者: Felix3322  |  项目: https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"
    }
}

OFFLINE_FILES = {
    "with_context": [
        ("SubtitleTranslate - ChatGPT.as", "SubtitleTranslate - ChatGPT.as"),
        ("SubtitleTranslate - ChatGPT.ico", "SubtitleTranslate - ChatGPT.ico")
    ],
    "without_context": [
        ("SubtitleTranslate - ChatGPT - Without Context.as", "SubtitleTranslate - ChatGPT - Without Context.as"),
        ("SubtitleTranslate - ChatGPT - Without Context.ico", "SubtitleTranslate - ChatGPT - Without Context.ico")
    ]
}

MIT_LICENSE_TEXT = """MIT License

Copyright (c) 2024 Felix

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

# 当语言未确定时使用双语提示（例如管理员检查前）
def merge_bilingual(key):
    return LANGUAGE_STRINGS["en"][key] + "\n\n" + LANGUAGE_STRINGS["zh"][key]

def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False

def restart_as_admin():
    # 语言未确定，显示双语提示
    messagebox.showwarning("Admin Required", merge_bilingual("admin_required"))
    params = " ".join([f'"{arg}"' for arg in sys.argv])
    ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, params, None, 1)
    sys.exit()

def get_path_from_shortcut(shortcut_path):
    try:
        shell = win32com.client.Dispatch("WScript.Shell")
        shortcut = shell.CreateShortcut(shortcut_path)
        return shortcut.TargetPath
    except Exception:
        return None

def get_path_from_installation_dir():
    base_dirs = [r"C:\Program Files\DAUM\PotPlayer"]
    for drive in [f"{chr(x)}:\\" for x in range(65, 91) if os.path.exists(f"{chr(x)}:\\")]:
        base_dirs.append(os.path.join(drive, "DAUM", "PotPlayer"))
    for d in base_dirs:
        if os.path.exists(d):
            translate_dir = os.path.join(d, "Extension", "Subtitle", "Translate")
            if os.path.exists(translate_dir):
                return translate_dir
    return None

def scan_drives():
    for drive in [f"{chr(x)}:\\" for x in range(65, 91) if os.path.exists(f"{chr(x)}:\\")]:
        path = os.path.join(drive, "Program Files", "DAUM", "PotPlayer", "Extension", "Subtitle", "Translate")
        if os.path.exists(path):
            return path
    return None

def scan_shortcuts():
    search_dirs = [
        os.path.join(os.environ.get("USERPROFILE", ""), "Desktop"),
        os.path.join(os.environ.get("APPDATA", ""), "Microsoft", "Windows", "Start Menu", "Programs")
    ]
    for base in search_dirs:
        if os.path.exists(base):
            for root, dirs, files in os.walk(base):
                for file in files:
                    if file.lower().endswith(".lnk") and "potplayer" in file.lower():
                        shortcut_path = os.path.join(root, file)
                        target = get_path_from_shortcut(shortcut_path)
                        if target and os.path.exists(target):
                            translate_dir = os.path.join(os.path.dirname(target), "Extension", "Subtitle", "Translate")
                            if os.path.exists(translate_dir):
                                return translate_dir
    return None

def auto_detect_directory():
    detected = scan_shortcuts()
    if detected:
        return detected
    detected = get_path_from_installation_dir()
    if detected:
        return detected
    return scan_drives()

class InstallThread(threading.Thread):
    def __init__(self, install_dir, version, script_dir, callback):
        super().__init__()
        self.install_dir = install_dir
        self.version = version
        self.script_dir = script_dir
        self.callback = callback
    def run(self):
        for src_file, dest_name in OFFLINE_FILES.get(self.version, []):
            src_path = os.path.join(self.script_dir, src_file)
            dest_path = os.path.join(self.install_dir, dest_name)
            self.callback(f"Copying {src_file} ...\n正在复制 {src_file} ...")
            if not os.path.exists(src_path):
                self.callback(f"Error: Missing file {src_file}.\n错误：缺少 {src_file}")
                return
            try:
                shutil.copy(src_path, dest_path)
                self.callback(f"Installed {dest_name}.\n已安装 {dest_name}")
            except Exception as e:
                self.callback(self.callback(f"") or self.callback(merge_bilingual("installation_failed").format(e)))
                return
        self.callback(merge_bilingual("installation_complete"))
        self.callback("DONE")

class InstallerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        # 用户选择后显示单语界面
        self.language = "en"
        self.strings = LANGUAGE_STRINGS[self.language]
        self.install_dir = ""
        self.version = ""
        self.script_dir = os.path.dirname(os.path.abspath(__file__))
        self.title("PotPlayer ChatGPT Translate Installer")
        self.geometry("500x450")
        self.resizable(False, False)
        self.frames = {}
        for F in (LanguageFrame, WelcomeFrame, LicenseFrame, DirectoryFrame, VersionFrame, ProgressFrame, FinishFrame):
            page_name = F.__name__
            frame = F(parent=self, controller=self)
            self.frames[page_name] = frame
            frame.place(relwidth=1, relheight=1)
        self.show_frame("LanguageFrame")
    def show_frame(self, page_name):
        frame = self.frames[page_name]
        frame.tkraise()
        if hasattr(frame, "on_show"):
            frame.on_show()
    def update_progress(self, msg):
        self.frames["ProgressFrame"].append_text(msg)
    def start_installation(self):
        thread = InstallThread(self.install_dir, self.version, self.script_dir, self.install_callback)
        thread.start()
    def install_callback(self, msg):
        self.after(0, lambda: self.update_progress(msg))
        if msg == "DONE":
            self.after(2000, lambda: self.show_frame("FinishFrame"))

class LanguageFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lang_var = tk.StringVar(value="en")
        lbl = tk.Label(self, text=controller.strings["choose_language"], font=("Arial", 12))
        lbl.pack(pady=20)
        rb_en = tk.Radiobutton(self, text=controller.strings["language_english"], variable=self.lang_var, value="en", font=("Arial", 10))
        rb_en.pack(pady=5)
        rb_zh = tk.Radiobutton(self, text=controller.strings["language_chinese"], variable=self.lang_var, value="zh", font=("Arial", 10))
        rb_zh.pack(pady=5)
        btn = tk.Button(self, text=controller.strings["next"], width=12, command=self.select_language)
        btn.pack(pady=20)
    def select_language(self):
        self.controller.language = self.lang_var.get()
        self.controller.strings = LANGUAGE_STRINGS[self.lang_var.get()]
        self.controller.show_frame("WelcomeFrame")

class WelcomeFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 14), wraplength=400)
        self.lbl.pack(pady=40)
        self.btn = tk.Button(self, text="", width=12, command=lambda: controller.show_frame("LicenseFrame"))
        self.btn.pack(pady=20)
        self.author = tk.Label(self, text=controller.strings["author_info"], font=("Arial", 10), fg="blue", cursor="hand2")
        self.author.pack(side="bottom", pady=10)
        self.author.bind("<Button-1>", lambda e: webbrowser.open("https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"))
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["welcome_message"])
        self.btn.config(text=s["next"])
        self.author.config(text=s["author_info"])

class LicenseFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.title_lbl = tk.Label(self, text=self.controller.strings["license_title"], font=("Arial", 14))
        self.title_lbl.pack(pady=10)
        self.text_area = tk.Text(self, height=15, width=60)
        self.text_area.insert(tk.END, MIT_LICENSE_TEXT)
        self.text_area.config(state="disabled")
        self.text_area.pack(pady=10)
        frm = tk.Frame(self)
        frm.pack(pady=10)
        self.agree_btn = tk.Button(frm, text=self.controller.strings["license_agree"], width=15, command=self.agree)
        self.agree_btn.pack(side="left", padx=5)
        self.disagree_btn = tk.Button(frm, text=self.controller.strings["license_disagree"], width=15, command=self.disagree)
        self.disagree_btn.pack(side="left", padx=5)
    def agree(self):
        self.controller.show_frame("DirectoryFrame")
    def disagree(self):
        messagebox.showwarning("Warning", self.controller.strings["license_reject"])
        self.controller.destroy()

class DirectoryFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        self.dir_var = tk.StringVar()
        self.entry = tk.Entry(self, textvariable=self.dir_var, width=50, state="readonly")
        self.entry.pack(pady=10)
        self.browse_btn = tk.Button(self, text="", width=10, command=self.browse)
        self.browse_btn.pack(pady=5)
        self.err_lbl = tk.Label(self, text="", fg="red")
        self.err_lbl.pack(pady=5)
        frm = tk.Frame(self)
        frm.pack(side="bottom", pady=20)
        self.back_btn = tk.Button(frm, text="", width=10, command=lambda: controller.show_frame("LicenseFrame"))
        self.back_btn.pack(side="left", padx=10)
        self.next_btn = tk.Button(frm, text="", width=10, command=self.next_step)
        self.next_btn.pack(side="right", padx=10)
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["select_install_dir"])
        self.browse_btn.config(text=s["browse"])
        self.back_btn.config(text=s["back"])
        self.next_btn.config(text=s["next"])
        detected = auto_detect_directory()
        if detected:
            if messagebox.askyesno("Confirm", s["confirm_path"].format(detected)):
                self.dir_var.set(detected)
                self.controller.install_dir = detected
                self.controller.show_frame("VersionFrame")
            else:
                self.dir_var.set("")
        else:
            self.dir_var.set("")
    def browse(self):
        d = filedialog.askdirectory()
        if d:
            self.dir_var.set(d)
            self.err_lbl.config(text="")
    def next_step(self):
        if self.dir_var.get():
            self.controller.install_dir = self.dir_var.get()
            self.controller.show_frame("VersionFrame")
        else:
            self.err_lbl.config(text=s["select_directory"])

class VersionFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        self.version_var = tk.StringVar(value="with_context")
        self.rb1 = tk.Radiobutton(self, text="", variable=self.version_var, value="with_context", font=("Arial", 10))
        self.rb1.pack(pady=5)
        self.desc1 = tk.Label(self, text="", font=("Arial", 9), wraplength=450, justify="left")
        self.desc1.pack(pady=2)
        self.rb2 = tk.Radiobutton(self, text="", variable=self.version_var, value="without_context", font=("Arial", 10))
        self.rb2.pack(pady=5)
        self.desc2 = tk.Label(self, text="", font=("Arial", 9), wraplength=450, justify="left")
        self.desc2.pack(pady=2)
        frm = tk.Frame(self)
        frm.pack(side="bottom", pady=20)
        self.back_btn = tk.Button(frm, text="", width=10, command=lambda: controller.show_frame("DirectoryFrame"))
        self.back_btn.pack(side="left", padx=10)
        self.next_btn = tk.Button(frm, text="", width=10, command=self.next_step)
        self.next_btn.pack(side="right", padx=10)
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["choose_version"])
        self.rb1.config(text=s["with_context"])
        self.desc1.config(text=s["with_context_description"])
        self.rb2.config(text=s["without_context"])
        self.desc2.config(text=s["without_context_description"])
        self.back_btn.config(text=s["back"])
        self.next_btn.config(text=s["next"])
    def next_step(self):
        self.controller.version = self.version_var.get()
        self.controller.show_frame("ProgressFrame")

class ProgressFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 12))
        self.lbl.pack(pady=10)
        self.txt = tk.Text(self, height=10, width=60, state="disabled")
        self.txt.pack(pady=5)
        frm = tk.Frame(self)
        frm.pack(side="bottom", pady=10)
        self.cancel_btn = tk.Button(frm, text="", width=10, command=self.controller.destroy)
        self.cancel_btn.pack()
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["install_progress"])
        self.cancel_btn.config(text=s["cancel"])
        self.txt.config(state="normal")
        self.txt.delete(1.0, tk.END)
        self.txt.config(state="disabled")
        self.controller.update_progress("Starting installation...\n开始安装...")
        self.controller.start_installation()
    def append_text(self, msg):
        self.txt.config(state="normal")
        self.txt.insert(tk.END, msg+"\n")
        self.txt.see(tk.END)
        self.txt.config(state="disabled")

class FinishFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.lbl = tk.Label(self, text="", font=("Arial", 14))
        self.lbl.pack(pady=40)
        self.finish_btn = tk.Button(self, text="", width=12, command=controller.destroy)
        self.finish_btn.pack(pady=20)
    def on_show(self):
        s = self.controller.strings
        self.lbl.config(text=s["installation_complete"])
        self.finish_btn.config(text=s["finish"])

def main():
    if not is_admin():
        restart_as_admin()
    app = InstallerApp()
    app.mainloop()

if __name__ == "__main__":
    main()
