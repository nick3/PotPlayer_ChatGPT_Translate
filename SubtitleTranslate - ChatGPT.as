/*
    PotPlayer 实时字幕翻译插件，基于 OpenAI ChatGPT API
*/

// 插件信息函数
string GetTitle() {
    return "{$CP949=ChatGPT 번역$}"
         + "{$CP950=ChatGPT 翻譯$}"
         + "{$CP936=ChatGPT 翻译$}"
         + "{$CP0=ChatGPT Translate$}";
}

string GetVersion() {
    return "0.0.0.12";
}

string GetDesc() {
    return "Real-time subtitle translation using OpenAI ChatGPT.";
}

string GetLoginTitle() {
    return "{$CP949=OpenAI 모델 및 API 키 구성$}"
         + "{$CP950=OpenAI 模型與 API 金鑰配置$}"
         + "{$CP936=OpenAI 模型与 API 密钥配置$}"
         + "{$CP0=OpenAI Model + API URL and API Key Configuration$}";
}

string GetLoginDesc() {
    return "{$CP949=모델 이름과 API 주소, 그리고 API 키를 입력하십시오 (예: gpt-4o-mini|https://api.openai.com/v1/chat/completions).$}\n"
         + "{$CP950=請輸入模型名稱與 API 地址，以及 API 金鑰（例如 gpt-4o-mini|https://api.openai.com/v1/chat/completions）。$}\n"
         + "{$CP936=请输入模型名称和 API 地址，以及 API 密钥（例如 gpt-4o-mini|https://api.openai.com/v1/chat/completions）。$}\n"
         + "{$CP0=Please enter the model name + API URL and provide the API Key (e.g., gpt-4o-mini|https://api.openai.com/v1/chat/completions).$}";
}

string GetUserText() {
    return "{$CP949=모델 이름|API 주소 (현재: " + selected_model + " | " + apiUrl + ")$}"
         + "{$CP950=模型名稱|API 地址 (目前: " + selected_model + " | " + apiUrl + ")$}"
         + "{$CP936=模型名称|API 地址 (目前: " + selected_model + " | " + apiUrl + ")$}"
         + "{$CP0=Model Name|API URL (Current: " + selected_model + " | " + apiUrl + ")$}";
}

string GetPasswordText() {
    return "{$CP949=API 키:$}"
         + "{$CP950=API 金鑰:$}"
         + "{$CP936=API 密钥:$}"
         + "{$CP0=API Key:$}";
}

// 全局变量
string api_key = "";
string selected_model = "gpt-4o-mini"; // 默认模型
string apiUrl = "https://api.openai.com/v1/chat/completions"; // 默认 API URL
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";

// Supported Language List
array<string> LangTable =
{
    "", // Auto Detect
    "af", // Afrikaans
    "sq", // Albanian
    "am", // Amharic
    "ar", // Arabic
    "hy", // Armenian
    "az", // Azerbaijani
    "eu", // Basque
    "be", // Belarusian
    "bn", // Bengali
    "bs", // Bosnian
    "bg", // Bulgarian
    "ca", // Catalan
    "ceb", // Cebuano
    "ny", // Chichewa
    "zh-CN", // Chinese (Simplified)
    "zh-TW", // Chinese (Traditional)
    "co", // Corsican
    "hr", // Croatian
    "cs", // Czech
    "da", // Danish
    "nl", // Dutch
    "en", // English
    "eo", // Esperanto
    "et", // Estonian
    "tl", // Filipino
    "fi", // Finnish
    "fr", // French
    "fy", // Frisian
    "gl", // Galician
    "ka", // Georgian
    "de", // German
    "el", // Greek
    "gu", // Gujarati
    "ht", // Haitian Creole
    "ha", // Hausa
    "haw", // Hawaiian
    "he", // Hebrew
    "hi", // Hindi
    "hmn", // Hmong
    "hu", // Hungarian
    "is", // Icelandic
    "ig", // Igbo
    "id", // Indonesian
    "ga", // Irish
    "it", // Italian
    "ja", // Japanese
    "jw", // Javanese
    "kn", // Kannada
    "kk", // Kazakh
    "km", // Khmer
    "ko", // Korean
    "ku", // Kurdish (Kurmanji)
    "ky", // Kyrgyz
    "lo", // Lao
    "la", // Latin
    "lv", // Latvian
    "lt", // Lithuanian
    "lb", // Luxembourgish
    "mk", // Macedonian
    "ms", // Malay
    "mg", // Malagasy
    "ml", // Malayalam
    "mt", // Maltese
    "mi", // Maori
    "mr", // Marathi
    "mn", // Mongolian
    "my", // Myanmar (Burmese)
    "ne", // Nepali
    "no", // Norwegian
    "ps", // Pashto
    "fa", // Persian
    "pl", // Polish
    "pt", // Portuguese
    "pa", // Punjabi
    "ro", // Romanian
    "ru", // Russian
    "sm", // Samoan
    "gd", // Scots Gaelic
    "sr", // Serbian
    "st", // Sesotho
    "sn", // Shona
    "sd", // Sindhi
    "si", // Sinhala
    "sk", // Slovak
    "sl", // Slovenian
    "so", // Somali
    "es", // Spanish
    "su", // Sundanese
    "sw", // Swahili
    "sv", // Swedish
    "tg", // Tajik
    "ta", // Tamil
    "te", // Telugu
    "th", // Thai
    "tr", // Turkish
    "uk", // Ukrainian
    "ur", // Urdu
    "uz", // Uzbek
    "vi", // Vietnamese
    "cy", // Welsh
    "xh", // Xhosa
    "yi", // Yiddish
    "yo", // Yoruba
    "zu" // Zulu
};

array<string> GetSrcLangs() {
    array<string> ret = LangTable;
    return ret;
}

array<string> GetDstLangs() {
    array<string> ret = LangTable;
    return ret;
}

// 登录接口：输入模型名称|API URL 和 API Key
string ServerLogin(string User, string Pass) {
    User = User.Trim();
    Pass = Pass.Trim();

    // 根据是否含有 '|' 分割模型名称与 API 源地址
    int sepPos = User.find("|");
    string userModel = "";
    string customApiUrl = "";
    if (sepPos != -1) {
        userModel = User.substr(0, sepPos).Trim();
        customApiUrl = User.substr(sepPos + 1).Trim();
    } else {
        userModel = User;
        customApiUrl = "";
    }
    if (userModel.empty()) {
        HostPrintUTF8("{$CP949=모델 이름이 입력되지 않았습니다. 올바른 모델 이름을 입력하십시오.$}"
                      + "{$CP950=未輸入模型名稱。請輸入有效的模型名稱.$}"
                      + "{$CP936=未输入模型名称。请输入有效的模型名称.$}"
                      + "{$CP0=Model name not entered. Please enter a valid model name.$}\n");
        userModel = "gpt-4o-mini";
    }
    if (!customApiUrl.empty()) {
        apiUrl = customApiUrl;
    } else {
        apiUrl = "https://api.openai.com/v1/chat/completions";
    }
    if (Pass.empty()) {
        HostPrintUTF8("{$CP949=API 키가 설정되지 않았습니다. 유효한 API 키를 입력하십시오.$}"
                      + "{$CP950=API 金鑰未配置。請輸入有效的 API 金鑰.$}"
                      + "{$CP936=API 密钥未配置。请输入有效的 API 密钥.$}"
                      + "{$CP0=API Key not configured. Please enter a valid API Key.$}\n");
        return "fail";
    }
    // 验证 API Key 和模型
    string verifyUrl = "";
    if (apiUrl.find("openai") != -1) {
        int pos = apiUrl.find("chat/completions");
        if (pos != -1) {
            verifyUrl = apiUrl.substr(0, pos) + "models";
        } else {
            verifyUrl = "https://api.openai.com/v1/models";
        }
    } else {
        int lastSlash = apiUrl.findLast("/");
        if (lastSlash != -1) {
            verifyUrl = apiUrl.substr(0, lastSlash) + "/models";
        } else {
            verifyUrl = apiUrl + "/models";
        }
        HostPrintUTF8("{$CP949=경고: 제3자 API 베이스 사용 시 계정 검증에 오탐지가 발생할 수 있습니다.$}"
                      + "{$CP950=警告: 使用第三方 API 基础可能會導致帳號驗證出現誤報.$}"
                      + "{$CP936=警告: 使用第三方 API 基础可能会导致账户验证出现误报.$}"
                      + "{$CP0=Warning: Using third-party API base may result in false positives during account verification.$}\n");
    }
    string verifyHeaders = "Authorization: Bearer " + Pass + "\nContent-Type: application/json";
    string verifyResponse = HostUrlGetString(verifyUrl, UserAgent, verifyHeaders, "");
    if (verifyResponse.empty()) {
        HostPrintUTF8("{$CP949=API 키 검증 실패: 서버에서 응답이 없습니다. 네트워크 연결 또는 API 키를 확인하십시오.$}"
                      + "{$CP950=API 金鑰驗證失敗：伺服器無回應。請檢查網絡連接或 API 金鑰.$}"
                      + "{$CP936=API 密钥验证失败：服务器无响应。请检查网络连接或 API 密钥.$}"
                      + "{$CP0=API Key verification failed. No response from server. Please check network connection or API Key.$}\n");
        return "fail";
    }
    JsonReader reader;
    JsonValue root;
    if (!reader.parse(verifyResponse, root)) {
        HostPrintUTF8("{$CP949=API 키 검증 응답 파싱 실패.$}"
                      + "{$CP950=解析 API 金鑰驗證回應失敗.$}"
                      + "{$CP936=解析 API 响应失败.$}"
                      + "{$CP0=Failed to parse API verification response.$}\n");
        return "fail";
    }
    if (root.hasKey("error")) {
        string errorMsg = root["error"]["message"].asString();
        HostPrintUTF8("{$CP949=API 키 검증 실패: $}"
                      + "{$CP950=API 金鑰驗證失敗: $}"
                      + "{$CP936=API 密钥验证失败: $}"
                      + "{$CP0=API Key verification failed: $}" + errorMsg + "\n");
        return "fail";
    }
    if (!root.hasKey("data") || !root["data"].isArray()) {
        HostPrintUTF8("{$CP949=API 키 검증 중 응답 형식이 유효하지 않습니다.$}"
                      + "{$CP950=API 金鑰驗證時回應格式無效.$}"
                      + "{$CP936=API 密钥验证时响应格式无效.$}"
                      + "{$CP0=Invalid response format during API Key verification.$}\n");
        return "fail";
    }
    bool modelFound = false;
    for (int i = 0; i < root["data"].length(); i++) {
        if (root["data"][i]["id"].asString() == userModel) {
            modelFound = true;
            break;
        }
    }
    if (!modelFound) {
        HostPrintUTF8("{$CP949=지정된 모델 '" + userModel + "' 은(는) API에서 사용할 수 없습니다. 모델 이름을 확인하십시오.$}"
                      + "{$CP950=指定的模型 '" + userModel + "' 在 API 中不可用。請檢查模型名稱.$}"
                      + "{$CP936=指定的模型 '" + userModel + "' 在 API 中不可用。请检查模型名称.$}"
                      + "{$CP0=The specified model '" + userModel + "' is not available in the API. Please check the model name.$}\n");
        return "fail";
    }
    // 保存设置
    selected_model = userModel;
    api_key = Pass;
    HostSaveString("gpt_api_key", api_key);
    HostSaveString("gpt_selected_model", selected_model);
    HostSaveString("gpt_apiUrl", apiUrl);
    HostPrintUTF8("{$CP949=API 키와 모델 이름 (및 API URL)이 성공적으로 구성 및 검증되었습니다.$}"
                  + "{$CP950=API 金鑰與模型名稱（及 API URL）已成功配置並驗證.$}"
                  + "{$CP936=API 密钥与模型名称（及 API URL）已成功配置并验证.$}"
                  + "{$CP0=API Key and model name (plus API URL) successfully configured and verified.$}\n");
    return "200 ok";
}

// 登出接口：清空设置
void ServerLogout() {
    api_key = "";
    selected_model = "gpt-4o-mini";
    apiUrl = "https://api.openai.com/v1/chat/completions";
    HostSaveString("gpt_api_key", "");
    HostSaveString("gpt_selected_model", selected_model);
    HostSaveString("gpt_apiUrl", apiUrl);
    HostPrintUTF8("{$CP949=성공적으로 로그아웃되었습니다.$}"
                  + "{$CP950=成功登出.$}"
                  + "{$CP936=成功登出.$}"
                  + "{$CP0=Successfully logged out.$}\n");
}

// JSON 转义
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    return output;
}

// 字幕历史和 RTL 标记
array<string> subtitleHistory;
string UNICODE_RLE = "\u202B";

// 粗略计算 token 数（平均 4 字符一 token）
int EstimateTokenCount(const string &in text) {
    return int(float(text.length()) / 4);
}

// 模型最大 token 限制
int GetModelMaxTokens(const string &in modelName) {
    if (modelName == "gpt-3.5-turbo") return 4096;
    else if (modelName == "gpt-3.5-turbo-16k") return 16384;
    else if (modelName == "gpt-4o" || modelName == "gpt-4o-mini") return 128000;
    else return 4096;
}

// 翻译函数
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    api_key = HostLoadString("gpt_api_key", "");
    selected_model = HostLoadString("gpt_selected_model", "gpt-4o-mini");
    apiUrl = HostLoadString("gpt_apiUrl", "https://api.openai.com/v1/chat/completions");

    if (api_key.empty()) {
        HostPrintUTF8("{$CP949=API 키가 설정되지 않았습니다. 설정 메뉴에서 입력하십시오.$}"
                      + "{$CP950=API 金鑰未配置。請在設定選單中輸入.$}"
                      + "{$CP936=API 密钥未配置。请在设置菜单中输入.$}"
                      + "{$CP0=API Key not configured. Please enter it in the settings menu.$}\n");
        return "";
    }
    if (DstLang.empty() || DstLang == "Auto Detect") {
        HostPrintUTF8("{$CP949=대상 언어가 지정되지 않았습니다. 대상 언어를 선택하십시오.$}"
                      + "{$CP950=未指定目標語言。請選擇目標語言.$}"
                      + "{$CP936=未指定目标语言。请选择目标语言.$}"
                      + "{$CP0=Target language not specified. Please select a target language.$}\n");
        return "";
    }
    if (SrcLang.empty() || SrcLang == "Auto Detect") { SrcLang = ""; }

    subtitleHistory.insertLast(Text);
    int maxTokens = GetModelMaxTokens(selected_model);
    string context = "";
    int tokenCount = EstimateTokenCount(Text);
    int i = int(subtitleHistory.length()) - 2;
    while (i >= 0 && tokenCount < (maxTokens - 1000)) {
        string subtitle = subtitleHistory[i];
        int subtitleTokens = EstimateTokenCount(subtitle);
        tokenCount += subtitleTokens;
        if (tokenCount < (maxTokens - 1000)) {
            context = subtitle + "\n" + context;
        }
        i--;
    }
    if (subtitleHistory.length() > 1000) {
        subtitleHistory.removeAt(0);
    }
    string prompt = "You are a professional translator. Please translate the following subtitle, output only translated results.";
    if (!SrcLang.empty()) { prompt += " from " + SrcLang; }
    prompt += " to " + DstLang + ". Use the context to provide better translation.\n";
    if (!context.empty()) { prompt += "Context:\n" + context + "\n"; }
    prompt += "Subtitle to translate:\n" + Text;
    string escapedPrompt = JsonEscape(prompt);
    string requestData = "{\"model\":\"" + selected_model + "\"," +
                         "\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}]," +
                         "\"max_tokens\":1000,\"temperature\":0}";
    string headers = "Authorization: Bearer " + api_key + "\nContent-Type: application/json";
    string response = HostUrlGetString(apiUrl, UserAgent, headers, requestData);
    if (response.empty()) {
        HostPrintUTF8("{$CP949=번역 요청 실패. 네트워크 연결 또는 API 키를 확인하십시오.$}"
                      + "{$CP950=翻譯請求失敗。請檢查網絡連接或 API 金鑰.$}"
                      + "{$CP936=翻译请求失败。请检查网络连接或 API 密钥.$}"
                      + "{$CP0=Translation request failed. Please check network connection or API Key.$}\n");
        return "";
    }
    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        HostPrintUTF8("{$CP949=API 응답 파싱 실패.$}"
                      + "{$CP950=解析 API 回應失敗.$}"
                      + "{$CP936=解析 API 响应失败.$}"
                      + "{$CP0=Failed to parse API response.$}\n");
        return "";
    }
    JsonValue choices = Root["choices"];
    if (choices.isArray() && choices[0]["message"]["content"].isString()) {
        string translatedText = choices[0]["message"]["content"].asString();
        if (selected_model.find("gemini") != -1) {
            while (translatedText.substr(translatedText.length() - 1, 1) == "\n") {
                translatedText = translatedText.substr(0, translatedText.length() - 1);
            }
        }
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8"; DstLang = "UTF8";
        return translatedText.Trim();
    }
    if (Root["error"]["message"].isString()) {
        string errorMessage = Root["error"]["message"].asString();
        HostPrintUTF8("{$CP949=API 오류: $}"
                      + "{$CP950=API 錯誤: $}"
                      + "{$CP936=API 错误: $}"
                      + "{$CP0=API Error: $}" + errorMessage + "\n");
    } else {
        HostPrintUTF8("{$CP949=번역 실패. 입력 매개변수 또는 API 키 구성을 확인하십시오.$}"
                      + "{$CP950=翻譯失敗。請檢查輸入參數或 API 金鑰配置.$}"
                      + "{$CP936=翻译失败。请检查输入参数或 API 密钥配置.$}"
                      + "{$CP0=Translation failed. Please check input parameters or API Key configuration.$}\n");
    }
    return "";
}

// 初始化插件
void OnInitialize() {
    HostPrintUTF8("{$CP949=ChatGPT 번역 플러그인 로드됨.$}"
                  + "{$CP950=ChatGPT 翻譯插件已加載.$}"
                  + "{$CP936=ChatGPT 翻译插件已加载.$}"
                  + "{$CP0=ChatGPT translation plugin loaded.$}\n");
    api_key = HostLoadString("gpt_api_key", "");
    selected_model = HostLoadString("gpt_selected_model", "gpt-4o-mini");
    apiUrl = HostLoadString("gpt_apiUrl", "https://api.openai.com/v1/chat/completions");
    if (!api_key.empty()) {
        HostPrintUTF8("{$CP949=저장된 API 키, 모델 이름, API URL 로드됨.$}"
                      + "{$CP950=已載入儲存的 API 金鑰、模型名稱和 API URL.$}"
                      + "{$CP936=已加载保存的 API 密钥、模型名称和 API URL.$}"
                      + "{$CP0=Saved API Key, model name, and API URL loaded.$}\n");
    }
}

// 卸载插件
void OnFinalize() {
    HostPrintUTF8("{$CP949=ChatGPT 번역 플러그인 언로드됨.$}"
                  + "{$CP950=ChatGPT 翻譯插件已卸載.$}"
                  + "{$CP936=ChatGPT 翻译插件已卸载.$}"
                  + "{$CP0=ChatGPT translation plugin unloaded.$}\n");
}
