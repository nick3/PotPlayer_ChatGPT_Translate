import os
import sys
import ctypes
import threading
import shutil
import locale
import win32com.client
import tkinter as tk
from tkinter import filedialog, simpledialog, messagebox
import webbrowser

# --------------------------
# 多语言字符串配置
# --------------------------
LANGUAGE_STRINGS = {
    "en": {
        "admin_required": "This installer needs to be run with administrator privileges.\n\n此安装器需要以管理员权限运行。",
        "select_directory": "Please select the Translate directory for PotPlayer.",
        "installation_complete": "Installation completed successfully!",
        "choose_version": "Choose the version to install:",
        "without_context": "Installer without Context Handling",
        "with_context": "Installer with Context Handling",
        "installation_failed": "Installation failed: {}",
        "installation_done": "Installation completed. Press OK to exit.",
        "error_occurred": "An error occurred: {}",
        "default_path_not_found": "Default path not found: {}",
        "scanning_drives": "Scanning all drives, please wait...",
        "found_directory": "Directory found: {}",
        "no_directory_found": "No directory found.",
        "enter_directory": "Please enter the full path to the PotPlayer Translate directory:",
        "welcome_message": "Welcome to the PotPlayer ChatGPT Translate Installer",
        "new_installer_notice": "The new installer has been completed. Press Next to continue.",
        "select_install_dir": "Select the PotPlayer Translate directory:",
        "browse": "Browse",
        "next": "Next",
        "back": "Back",
        "choose_install_version": "Choose the version to install:",
        "install_progress": "Installation Progress:",
        "cancel": "Cancel",
        "finish": "Finish",
        "choose_language": "Choose your language:",
        "language_english": "English",
        "language_chinese": "中文",
        "with_context_description": "Features: Advanced context-aware processing for more accurate translations. However, it consumes more tokens and may be more expensive.",
        "without_context_description": "Features: A lightweight version without contextual processing. It uses fewer tokens, making it more cost-effective.",
        "confirm_path": "Detected PotPlayer path:\n{}\n\nIs this correct? (If you do not understand, please choose Yes)",
        "file_exists_prompt": "File {} already exists. Please choose:",
        "upgrade_option": "Upgrade",
        "new_copy_option": "Install New Copy",
        "rename_confirm": "Confirm",
        "upgrade_clicked_wrong": "I clicked wrong, upgrade",
        "rename_prompt": "Enter new name for the new script file:",
        "author_info": "Author: Felix3322  |  Project: https://github.com/Felix3322/PotPlayer_Chatgpt_Translate"
    },
    "zh": {
        "admin_required": "This installer needs to be run with administrator privileges.\n\n此安装器需要以管理员权限运行。",
        "select_directory": "请选择PotPlayer的Translate目录。",
        "installation_complete": "安装成功！",
        "choose_version": "请选择安装的版本:",
        "without_context": "不带上下文处理的安装包",
        "with_context": "带上下文处理的安装包",
        "installation_failed": "安装失败: {}",
        "installation_done": "安装完成，按OK退出。",
        "error_occurred": "发生错误: {}",
        "default_path_not_found": "默认路径未找到: {}",
        "scanning_drives": "正在扫描硬盘，请稍候...",
        "found_directory": "找到目录: {}",
        "no_directory_found": "未找到目录。",
        "enter_directory": "请输入PotPlayer的Translate目录完整路径：",
        "welcome_message": "欢迎使用PotPlayer ChatGPT 翻译安装程序",
        "new_installer_notice": "新的安装器已完成编写，按下一步继续",
        "select_install_dir": "请选择PotPlayer的Translate目录：",
        "browse": "浏览",
        "next": "下一步",
        "back": "上一步",
        "choose_install_version": "请选择安装的版本：",
        "install_progress": "安装进度：",
        "cancel": "取消",
        "finish": "完成",
        "choose_language": "选择语言:",
        "language_english": "English",
        "language_chinese": "中文",
        "with_context_description": "特点: 具备高级上下文感知处理, 提供更精准的翻译效果, 但会消耗更多 tokens, 可能导致较高成本.",
        "without_context_description": "特点: 轻量版, 不包含上下文处理, 占用更少 tokens, 成本更低.",
        "confirm_path": "检测到的PotPlayer路径:\n{}\n\n是否正确？(如果看不懂，请选择是)",
        "file_exists_prompt": "文件 {} 已存在，请选择：",
        "upgrade_option": "我在升级",
        "new_copy_option": "我想安装新的副本",
        "rename_confirm": "确认",
        "upgrade_clicked_wrong": "点错了，我在升级",
        "rename_prompt": "请输入新脚本文件名：",
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

# --------------------------
# 辅助函数
# --------------------------
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False

def restart_as_admin(strings):
    # 管理员提示保持双语（因语言选择尚未进行）
    messagebox.showwarning("Admin Required", strings["admin_required"])
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

def get_path_from_installation_dir(strings):
    potential_dirs = [
        r"C:\Program Files\DAUM\PotPlayer",
        r"C:\Program Files (x86)\DAUM\PotPlayer"
    ]
    # 扫描其他盘符下的可能安装目录
    drives = [f"{chr(x)}:\\" for x in range(65, 91) if os.path.exists(f"{chr(x)}:\\")]
    for drive in drives:
        potential_dirs.append(os.path.join(drive, "DAUM", "PotPlayer"))
    for dir_path in potential_dirs:
        if os.path.exists(dir_path):
            for lnk_name in ["PotPlayer 64 bit.lnk", "PotPlayer.lnk", "PotPlayer 32 bit.lnk"]:
                lnk_path = os.path.join(dir_path, lnk_name)
                if os.path.exists(lnk_path):
                    potplayer_path = get_path_from_shortcut(lnk_path)
                    if potplayer_path:
                        translate_dir = os.path.join(os.path.dirname(potplayer_path), "Extension", "Subtitle", "Translate")
                        if os.path.exists(translate_dir):
                            return translate_dir
    return None

def scan_drives(strings):
    drives = [f"{chr(x)}:\\" for x in range(65, 91) if os.path.exists(f"{chr(x)}:\\")]
    for drive in drives:
        potential_path = os.path.join(drive, "Program Files", "DAUM", "PotPlayer", "Extension", "Subtitle", "Translate")
        if os.path.exists(potential_path):
            return potential_path
    return None

# 自定义对话框：当文件冲突时先询问用户选择“我在升级”或“我想安装新的副本”
# 如果选择“我想安装新的副本”，再弹出重命名对话框，提供“确认”和“点错了，我在升级”两个选项
def ask_conflict_resolution(filename, strings):
    result = None

    # 第一步：选择升级或安装副本
    dialog = tk.Toplevel()
    dialog.title("Conflict")
    label = tk.Label(dialog, text=strings["file_exists_prompt"].format(filename), font=("Arial", 10))
    label.pack(padx=20, pady=10)
    btn_frame = tk.Frame(dialog)
    btn_frame.pack(pady=10)
    def choose_upgrade():
        nonlocal result
        result = "upgrade"
        dialog.destroy()
    def choose_new_copy():
        nonlocal result
        result = "new_copy"
        dialog.destroy()
    btn_upgrade = tk.Button(btn_frame, text=strings.get("upgrade_option"), width=15, command=choose_upgrade)
    btn_upgrade.pack(side="left", padx=5)
    btn_new = tk.Button(btn_frame, text=strings.get("new_copy_option"), width=15, command=choose_new_copy)
    btn_new.pack(side="left", padx=5)
    dialog.grab_set()
    dialog.wait_window()

    if result == "upgrade":
        return "upgrade"
    elif result == "new_copy":
        # 第二步：弹出重命名对话框
        rename_dialog = tk.Toplevel()
        rename_dialog.title("Rename")
        rename_label = tk.Label(rename_dialog, text=strings.get("rename_prompt"), font=("Arial", 10))
        rename_label.pack(padx=20, pady=10)
        entry_var = tk.StringVar(value=filename)
        entry = tk.Entry(rename_dialog, textvariable=entry_var, width=40)
        entry.pack(padx=20, pady=5)
        rename_result = None
        def confirm_rename():
            nonlocal rename_result
            rename_result = entry_var.get()
            rename_dialog.destroy()
        def cancel_to_upgrade():
            nonlocal rename_result
            rename_result = "upgrade"
            rename_dialog.destroy()
        btn_frame2 = tk.Frame(rename_dialog)
        btn_frame2.pack(pady=10)
        btn_confirm = tk.Button(btn_frame2, text=strings.get("rename_confirm"), width=15, command=confirm_rename)
        btn_confirm.pack(side="left", padx=5)
        btn_cancel = tk.Button(btn_frame2, text=strings.get("upgrade_clicked_wrong"), width=15, command=cancel_to_upgrade)
        btn_cancel.pack(side="left", padx=5)
        rename_dialog.grab_set()
        rename_dialog.wait_window()
        return rename_result

# --------------------------
# GUI各页面实现（各页面均继承自tk.Frame）
# --------------------------
class LanguageFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        label = tk.Label(self, text="Choose your language:", font=("Arial", 12))
        label.pack(pady=20)
        self.lang_var = tk.StringVar(value="en")
        radio_en = tk.Radiobutton(self, text="English", variable=self.lang_var, value="en", font=("Arial", 10))
        radio_en.pack(pady=5)
        radio_zh = tk.Radiobutton(self, text="中文", variable=self.lang_var, value="zh", font=("Arial", 10))
        radio_zh.pack(pady=5)
        next_button = tk.Button(self, text="Next", width=12, command=self.select_language)
        next_button.pack(pady=20)

    def select_language(self):
        selected = self.lang_var.get()
        self.controller.strings = LANGUAGE_STRINGS[selected]
        self.controller.show_frame("WelcomeFrame")

    def on_show(self):
        pass

class WelcomeFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.label = tk.Label(self, text="", font=("Arial", 14), wraplength=400)
        self.label.pack(pady=40)
        self.next_button = tk.Button(self, text="", width=12,
                                     command=lambda: controller.show_frame("DirectoryFrame"))
        self.next_button.pack(pady=20)
        # 可点击的项目链接（蓝色、带下划线）
        self.author_label = tk.Label(self, text="", font=("Arial", 10), fg="blue", cursor="hand2")
        self.author_label.pack(side="bottom", pady=10)
        self.author_label.bind("<Button-1>", self.open_project_link)

    def open_project_link(self, event):
        webbrowser.open("https://github.com/Felix3322/PotPlayer_Chatgpt_Translate")

    def on_show(self):
        strings = self.controller.strings
        msg = strings.get("welcome_message", "") + "\n\n" + strings.get("new_installer_notice", "")
        self.label.config(text=msg)
        self.next_button.config(text=strings.get("next", "Next"))
        self.author_label.config(text=strings.get("author_info", ""))

class DirectoryFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.label = tk.Label(self, text="", font=("Arial", 12))
        self.label.pack(pady=10)
        self.dir_var = tk.StringVar()
        self.entry = tk.Entry(self, textvariable=self.dir_var, width=50, state="readonly")
        self.entry.pack(pady=10)
        self.browse_button = tk.Button(self, text="", width=10, command=self.browse_directory)
        self.browse_button.pack(pady=5)
        self.error_label = tk.Label(self, text="", fg="red")
        self.error_label.pack(pady=5)
        button_frame = tk.Frame(self)
        button_frame.pack(side="bottom", pady=20)
        self.back_button = tk.Button(button_frame, text="", width=10,
                                     command=lambda: controller.show_frame("WelcomeFrame"))
        self.back_button.pack(side="left", padx=10)
        self.next_button = tk.Button(button_frame, text="", width=10, command=self.save_and_next)
        self.next_button.pack(side="right", padx=10)

    def on_show(self):
        strings = self.controller.strings
        self.label.config(text=strings.get("select_install_dir", "Select the PotPlayer Translate directory:"))
        self.browse_button.config(text=strings.get("browse", "Browse"))
        self.back_button.config(text=strings.get("back", "Back"))
        self.next_button.config(text=strings.get("next", "Next"))
        # 自动检测PotPlayer路径
        detected = get_path_from_installation_dir(strings) or scan_drives(strings)
        if detected:
            confirm = messagebox.askyesno("Confirm", strings["confirm_path"].format(detected))
            if confirm:
                self.dir_var.set(detected)
                self.error_label.config(text="")
                self.controller.install_dir = self.dir_var.get()
                self.controller.show_frame("VersionFrame")
            else:
                self.dir_var.set("")
        else:
            self.dir_var.set("")

    def browse_directory(self):
        directory = filedialog.askdirectory()
        if directory:
            self.dir_var.set(directory)
            self.error_label.config(text="")

    def save_and_next(self):
        if self.dir_var.get():
            self.controller.install_dir = self.dir_var.get()
            self.controller.show_frame("VersionFrame")
        else:
            self.error_label.config(text=self.controller.strings.get("select_directory", "Please select a directory."))

class VersionFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.label = tk.Label(self, text="", font=("Arial", 12))
        self.label.pack(pady=10)
        self.version_var = tk.StringVar(value="with_context")
        self.radio_with = tk.Radiobutton(self, text="", variable=self.version_var, value="with_context", font=("Arial", 10))
        self.radio_with.pack(pady=5)
        self.with_desc = tk.Label(self, text="", font=("Arial", 9), wraplength=450, justify="left")
        self.with_desc.pack(pady=2)
        self.radio_without = tk.Radiobutton(self, text="", variable=self.version_var, value="without_context", font=("Arial", 10))
        self.radio_without.pack(pady=5)
        self.without_desc = tk.Label(self, text="", font=("Arial", 9), wraplength=450, justify="left")
        self.without_desc.pack(pady=2)
        button_frame = tk.Frame(self)
        button_frame.pack(side="bottom", pady=20)
        self.back_button = tk.Button(button_frame, text="", width=10,
                                     command=lambda: controller.show_frame("DirectoryFrame"))
        self.back_button.pack(side="left", padx=10)
        self.next_button = tk.Button(button_frame, text="", width=10, command=self.save_and_next)
        self.next_button.pack(side="right", padx=10)

    def on_show(self):
        strings = self.controller.strings
        self.label.config(text=strings.get("choose_install_version", "Choose the version to install:"))
        self.radio_with.config(text=strings.get("with_context", "Installer with Context Handling"))
        self.with_desc.config(text=strings.get("with_context_description", ""))
        self.radio_without.config(text=strings.get("without_context", "Installer without Context Handling"))
        self.without_desc.config(text=strings.get("without_context_description", ""))
        self.back_button.config(text=strings.get("back", "Back"))
        self.next_button.config(text=strings.get("next", "Next"))

    def save_and_next(self):
        self.controller.version = self.version_var.get()
        self.controller.show_frame("ProgressFrame")

class ProgressFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.label = tk.Label(self, text="", font=("Arial", 12))
        self.label.pack(pady=10)
        self.text = tk.Text(self, height=10, width=60, state="disabled")
        self.text.pack(pady=5)
        button_frame = tk.Frame(self)
        button_frame.pack(side="bottom", pady=10)
        self.cancel_button = tk.Button(button_frame, text="", width=10, command=self.cancel_installation)
        self.cancel_button.pack()
        self.install_thread = None

    def on_show(self):
        strings = self.controller.strings
        self.label.config(text=strings.get("install_progress", "Installation Progress:"))
        self.cancel_button.config(text=strings.get("cancel", "Cancel"))
        self.text.config(state="normal")
        self.text.delete(1.0, tk.END)
        self.text.config(state="disabled")
        self.controller.update_progress("Starting installation...")
        self.install_thread = threading.Thread(target=self.run_installation)
        self.install_thread.start()

    def append_text(self, msg):
        self.text.config(state="normal")
        self.text.insert(tk.END, msg + "\n")
        self.text.see(tk.END)
        self.text.config(state="disabled")

    def run_installation(self):
        install_dir = self.controller.install_dir
        version = self.controller.version
        strings = self.controller.strings
        script_dir = os.path.dirname(os.path.abspath(__file__))

        for src_file, dest_name in OFFLINE_FILES.get(version, []):
            src_path = os.path.join(script_dir, src_file)
            dest_path = os.path.join(install_dir, dest_name)
            if os.path.exists(dest_path):
                decision = ask_conflict_resolution(dest_name, strings)
                # 如果返回"upgrade"，直接覆盖；如果返回非"upgrade"则视为新文件名
                if decision == "upgrade":
                    pass  # 保持dest_path不变，直接覆盖
                else:
                    if not decision or decision.strip() == "":
                        self.controller.update_progress(f"Installation aborted due to invalid name for {dest_name}.")
                        return
                    dest_path = os.path.join(install_dir, decision)
            self.controller.update_progress(f"Copying {src_file} ...")
            if not os.path.exists(src_path):
                self.controller.update_progress(f"Error: Missing file {src_file} in script directory.")
                return
            try:
                shutil.copy(src_path, dest_path)
                self.controller.update_progress(f"Installed {dest_name}.")
            except Exception as e:
                self.controller.update_progress(strings.get("installation_failed", "Installation failed: {}").format(e))
                return
        self.controller.update_progress(strings.get("installation_complete", "Installation completed successfully!"))
        self.controller.after(2000, lambda: self.controller.show_frame("FinishFrame"))

    def cancel_installation(self):
        self.controller.destroy()

class FinishFrame(tk.Frame):
    def __init__(self, parent, controller):
        super().__init__(parent)
        self.controller = controller
        self.label = tk.Label(self, text="", font=("Arial", 14))
        self.label.pack(pady=40)
        self.finish_button = tk.Button(self, text="", width=12, command=controller.destroy)
        self.finish_button.pack(pady=20)

    def on_show(self):
        strings = self.controller.strings
        self.label.config(text=strings.get("installation_complete", "Installation completed successfully!"))
        self.finish_button.config(text=strings.get("finish", "Finish"))

# --------------------------
# 主应用程序类
# --------------------------
class InstallerApp(tk.Tk):
    def __init__(self):
        super().__init__()
        # 默认使用英文配置；语言选择页将更新为用户选择的配置
        self.strings = LANGUAGE_STRINGS["en"]
        self.title("PotPlayer ChatGPT Translate Installer")
        self.geometry("500x450")
        self.resizable(False, False)
        self.install_dir = None
        self.version = None

        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)
        self.frames = {}
        for F in (LanguageFrame, WelcomeFrame, DirectoryFrame, VersionFrame, ProgressFrame, FinishFrame):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            self.frames[page_name] = frame
            frame.grid(row=0, column=0, sticky="nsew")

    def show_frame(self, page_name):
        frame = self.frames[page_name]
        frame.tkraise()
        if hasattr(frame, "on_show"):
            frame.on_show()

    def update_progress(self, msg):
        self.after(0, lambda: self.frames["ProgressFrame"].append_text(msg))

# --------------------------
# 主函数
# --------------------------
def main():
    # 如果不是管理员，则以管理员权限重启（管理员提示保持双语，因为语言选择在前）
    if not is_admin():
        restart_as_admin(LANGUAGE_STRINGS["en"])
    app = InstallerApp()
    app.show_frame("LanguageFrame")
    app.mainloop()

if __name__ == "__main__":
    main()
