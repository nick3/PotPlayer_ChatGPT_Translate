/*
    Real-time subtitle translation for PotPlayer using OpenAI ChatGPT API
*/

string GetTitle() {
    return "{$CP949=ChatGPT 번역$}"
         + "{$CP950=ChatGPT 翻譯$}"
         + "{$CP936=ChatGPT 翻译$}"
         + "{$CP0=ChatGPT Translate$}";
}

string GetVersion() {
    return "1.4.1";
}

string GetDesc() {
    return "{$CP949=실시간 자막 번역 (OpenAI ChatGPT 사용)$}"
         + "{$CP950=實時字幕翻譯 (使用 OpenAI ChatGPT)$}"
         + "{$CP936=实时字幕翻译 (使用 OpenAI ChatGPT)$}"
         + "{$CP0=Real-time subtitle translation using OpenAI ChatGPT.}$";
}

string GetLoginTitle() {
    return "{$CP949=OpenAI 모델 및 API 키 구성$}"
         + "{$CP950=OpenAI 模型與 API 金鑰配置$}"
         + "{$CP936=OpenAI 模型与 API 密钥配置$}"
         + "{$CP0=OpenAI Model + API URL and API Key Configuration$}";
}

string GetLoginDesc() {
    return "{$CP949=모델 이름과 API 주소, 그리고 API 키를 입력하십시오 (예: gpt-4o-mini|https://api.openai.com/v1/chat/completions).$}"
         + "{$CP950=請輸入模型名稱與 API 地址，以及 API 金鑰（例如: gpt-4o-mini|https://api.openai.com/v1/chat/completions）。$}"
         + "{$CP936=请输入模型名称和 API 地址，以及 API 密钥（例如: gpt-4o-mini|https://api.openai.com/v1/chat/completions）。$}"
         + "{$CP0=Please enter the model name + API URL and provide the API Key (e.g., gpt-4o-mini|https://api.openai.com/v1/chat/completions).}$";
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

// Global Variables
string api_key = "";
string selected_model = "gpt-4o-mini"; // Default model
string apiUrl = "https://api.openai.com/v1/chat/completions"; // Default API URL
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
    "zu"  // Zulu
};

array<string> GetSrcLangs() {
    array<string> ret = LangTable;
    return ret;
}

array<string> GetDstLangs() {
    array<string> ret = LangTable;
    return ret;
}

/*
   ServerLogin:
   - Process user input for model name, API URL, and API Key.
   - Trim extra spaces and remove trailing slash from API URL.
   - Verify API Key and model; return multi-language error messages if any issue.
*/
string ServerLogin(string User, string Pass) {
    User = User.Trim();
    Pass = Pass.Trim();
    int sepPos = User.find("|");
    string userModel = "";
    string customApiUrl = "";
    if (sepPos != -1) {
        // Trim both sides of the separator to remove extra spaces
        userModel = User.substr(0, sepPos).Trim();
        customApiUrl = User.substr(sepPos + 1).Trim();
    } else {
        userModel = User;
        customApiUrl = "";
    }
    if (userModel.empty()) {
        return "{$CP949=모델 이름이 입력되지 않았습니다. 올바른 모델 이름을 입력하십시오.$}"
             + "{$CP950=未輸入模型名稱，請輸入有效的模型名稱。$}"
             + "{$CP936=未输入模型名称，请输入有效的模型名称。$}"
             + "{$CP0=Model name not entered. Please enter a valid model name.}$}";
    }
    // Remove trailing slash(es) from API URL if present
    if (!customApiUrl.empty()) {
        while (customApiUrl.length() > 0 && customApiUrl.substr(customApiUrl.length()-1, 1) == "/") {
            customApiUrl = customApiUrl.substr(0, customApiUrl.length()-1);
        }
        apiUrl = customApiUrl;
    } else {
        apiUrl = "https://api.openai.com/v1/chat/completions";
    }
    if (Pass.empty()) {
        return "{$CP949=API 키가 구성되지 않았습니다. 올바른 API 키를 입력하십시오.$}"
             + "{$CP950=未配置 API 金鑰，請輸入有效的 API 金鑰。$}"
             + "{$CP936=未配置 API 密钥，请输入有效的 API 密钥。$}"
             + "{$CP0=API Key not configured. Please enter a valid API Key.}$}";
    }
    bool isOfficial = (apiUrl.find("api.openai.com") != -1);
    string verifyUrl = "";
    if (isOfficial) {
        int pos = apiUrl.find("chat/completions");
        if (pos != -1)
            verifyUrl = apiUrl.substr(0, pos) + "models";
        else
            verifyUrl = "https://api.openai.com/v1/models";
    } else {
        // For third-party API base, API URL already processed; simply append "/models"
        verifyUrl = apiUrl + "/models";
    }
    string verifyHeaders = "Authorization: Bearer " + Pass + "\nContent-Type: application/json";
    string verifyResponse = HostUrlGetString(verifyUrl, UserAgent, verifyHeaders, "");
    string retMsg = "";
    if (verifyResponse.empty()) {
        if (isOfficial)
            return "{$CP949=API 키 검증 실패: 서버로부터 응답이 없습니다. 네트워크 연결 또는 API 키를 확인하십시오.$}"
                 + "{$CP950=API 金鑰驗證失敗：伺服器未回應，請檢查網路連線或 API 金鑰。$}"
                 + "{$CP936=API 密钥验证失败：服务器未响应，请检查网络连接或 API 密钥。$}"
                 + "{$CP0=API Key verification failed: No response from server. Please check network connection or API Key.}$}";
        else
            retMsg += "{$CP949=경고: API 키 검증 실패 - 서버로부터 응답이 없습니다 (제3자 API, 오인 가능성 있음).$}"
                    + "{$CP950=警告：API 金鑰驗證失敗 - 伺服器未回應（第三方 API，可能為誤報）。$}"
                    + "{$CP936=警告：API 密钥验证失败 - 服务器未响应（第三方 API，可能为误报）。$}"
                    + "{$CP0=Warning: API Key verification failed: No response from server (third-party API base, possible false positive).}$}";
    }
    JsonReader reader;
    JsonValue root;
    if (!reader.parse(verifyResponse, root)) {
        if (isOfficial)
            return "{$CP949=API 키 검증 응답 파싱 실패.$}"
                 + "{$CP950=解析 API 金鑰驗證回應失敗。$}"
                 + "{$CP936=解析 API 密钥验证响应失败。$}"
                 + "{$CP0=Failed to parse API verification response.}$}";
        else
            retMsg += "{$CP949=경고: API 키 검증 응답 파싱 실패 (제3자 API, 오인 가능성 있음).$}"
                    + "{$CP950=警告：解析 API 金鑰驗證回應失敗（第三方 API，可能為誤報）。$}"
                    + "{$CP936=警告：解析 API 密钥验证响应失败（第三方 API，可能为误报）。$}"
                    + "{$CP0=Warning: Failed to parse API verification response (third-party API base, possible false positive).}$}";
    }
    if (!root["error"].isNull()) {
        string errorMsg = root["error"]["message"].asString();
        if (isOfficial)
            return "{$CP949=API 키 검증 실패: " + errorMsg + "$}"
                 + "{$CP950=API 金鑰驗證失敗: " + errorMsg + "$}"
                 + "{$CP936=API 密钥验证失败: " + errorMsg + "$}"
                 + "{$CP0=API Key verification failed: " + errorMsg + "$}";
        else
            retMsg += "{$CP949=경고: API 키 검증 실패: " + errorMsg + " (제3자 API, 오인 가능성 있음).$}"
                    + "{$CP950=警告：API 金鑰驗證失敗: " + errorMsg + "（第三方 API，可能為誤報）。$}"
                    + "{$CP936=警告：API 密钥验证失败: " + errorMsg + "（第三方 API，可能为误报）。$}"
                    + "{$CP0=Warning: API Key verification failed: " + errorMsg + " (third-party API base, possible false positive).}$}";
    }
    bool modelFound = false;
    bool dataValid = (!root["data"].isNull() && root["data"].isArray());
    if (isOfficial) {
        if (!dataValid)
            return "{$CP949=공식 API에서 API 키 검증 중 응답 형식이 올바르지 않습니다.$}"
                 + "{$CP950=官方 API 返回的 API 金鑰驗證回應格式不正確。$}"
                 + "{$CP936=官方 API 返回的 API 密钥验证响应格式不正确。$}"
                 + "{$CP0=Invalid response format during API Key verification (official API).}$}";
    } else {
        if (!dataValid) {
            retMsg += "{$CP949=경고: 제3자 API에서 모델 목록 검증 불가 (오인 가능성 있음).$}"
                    + "{$CP950=警告：無法使用第三方 API 驗證模型列表（可能為誤報）。$}"
                    + "{$CP936=警告：无法使用第三方 API 验证模型列表（可能为误报）。$}"
                    + "{$CP0=Warning: Unable to verify model list using third-party API base (possible false positive).}$}";
            modelFound = true; // Skip model check
        }
    }
    if (dataValid) {
        for (int i = 0; ; i++) {
            JsonValue element = root["data"][i];
            if (element.isNull()) break;
            if (element["id"].asString() == userModel) {
                modelFound = true;
                break;
            }
        }
        if (!modelFound) {
            if (isOfficial)
                return "{$CP949=지정된 모델 '" + userModel + "'이(가) API에서 사용할 수 없습니다. 모델 이름을 확인하십시오.$}"
                     + "{$CP950=指定的模型 '" + userModel + "' 在 API 中不可用，請檢查模型名稱。$}"
                     + "{$CP936=指定的模型 '" + userModel + "' 在 API 中不可用，请检查模型名称。$}"
                     + "{$CP0=The specified model '" + userModel + "' is not available in the API. Please check the model name.}$}";
            else
                retMsg += "{$CP949=경고: 지정된 모델 '" + userModel + "'이(가) API에서 사용할 수 없습니다 (제3자 API, 오인 가능성 있음).$}"
                        + "{$CP950=警告：指定的模型 '" + userModel + "' 在 API 中不可用（第三方 API，可能為誤報）。$}"
                        + "{$CP936=警告：指定的模型 '" + userModel + "' 在 API 中不可用（第三方 API，可能为误报）。$}"
                        + "{$CP0=Warning: The specified model '" + userModel + "' is not available in the API (third-party API base, possible false positive).}$}";
        }
    }
    selected_model = userModel;
    api_key = Pass;
    HostSaveString("gpt_api_key", api_key);
    HostSaveString("gpt_selected_model", selected_model);
    HostSaveString("gpt_apiUrl", apiUrl);
    if (isOfficial)
        return "{$CP949=200 ok$}"
             + "{$CP950=200 ok$}"
             + "{$CP936=200 ok$}"
             + "{$CP0=200 ok$}";
    else
        return retMsg + "{$CP949=설정 완료.$}"
                      + "{$CP950=設定完成。$}"
                      + "{$CP936=设置完成。$}"
                      + "{$CP0=Configuration completed.}$}";
}

//
// JSON String Escape Function (added slash escaping for model names with '/')
//
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    output.replace("/", "\\/");  // Escape forward slash
    return output;
}

// Global variable for storing subtitle history (for context support)
array<string> subtitleHistory;
string UNICODE_RLE = "\u202B"; // For Right-to-Left languages

int EstimateTokenCount(const string &in text) {
    return int(float(text.length()) / 4);
}

int GetModelMaxTokens(const string &in modelName) {
    if (modelName == "gpt-3.5-turbo")
        return 4096;
    else if (modelName == "gpt-3.5-turbo-16k")
        return 16384;
    else if (modelName == "gpt-4o")
        return 128000;
    else if (modelName == "gpt-4o-mini")
        return 128000;
    else
        return 4096;
}

string Translate(string Text, string &in SrcLang, string &in DstLang) {
    api_key = HostLoadString("gpt_api_key", "");
    selected_model = HostLoadString("gpt_selected_model", "gpt-4o-mini");
    apiUrl = HostLoadString("gpt_apiUrl", "https://api.openai.com/v1/chat/completions");
    if (api_key.empty()) {
        return "{$CP949=API 키가 구성되지 않았습니다. 설정 메뉴에서 입력하십시오.$}"
             + "{$CP950=未配置 API 金鑰，請在設定選單中輸入。$}"
             + "{$CP936=未配置 API 密钥，请在设置菜单中输入。$}"
             + "{$CP0=API Key not configured. Please enter it in the settings menu.}$}";
    }
    if (DstLang.empty() || DstLang == "Auto Detect") {
        return "{$CP949=목표 언어가 지정되지 않았습니다. 목표 언어를 선택하십시오.$}"
             + "{$CP950=未指定目標語言，請選擇目標語言。$}"
             + "{$CP936=未指定目标语言，请选择目标语言。$}"
             + "{$CP0=Target language not specified. Please select a target language.}$}";
    }
    if (SrcLang.empty() || SrcLang == "Auto Detect") {
        SrcLang = "";
    }
    // Add the current subtitle to the history
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
    if (!SrcLang.empty()) {
        prompt += " from " + SrcLang;
    }
    prompt += " to " + DstLang + ". Use the context to provide better translation.\n";
    if (!context.empty()) {
        prompt += "Context:\n" + context + "\n";
    }
    prompt += "Subtitle to translate:\n" + Text;
    string escapedPrompt = JsonEscape(prompt);
    string requestData = "{\"model\":\"" + selected_model + "\"," +
                         "\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}]," +
                         "\"max_tokens\":1000,\"temperature\":0}";
    string headers = "Authorization: Bearer " + api_key + "\nContent-Type: application/json";
    string response = HostUrlGetString(apiUrl, UserAgent, headers, requestData);
    if (response.empty()) {
        HostPrintUTF8("Translation request failed. Please check network connection or API Key.\n");
        return "";
    }
    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        HostPrintUTF8("Failed to parse API response.\n");
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
        // Handle RTL languages.
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText.Trim();
    }
    if (Root["error"]["message"].isString()) {
        string errorMessage = Root["error"]["message"].asString();
        HostPrintUTF8("API Error: " + errorMessage + "\n");
        return "{$CP949=API 오류: " + errorMessage + "$}"
             + "{$CP950=API 錯誤: " + errorMessage + "$}"
             + "{$CP936=API 错误: " + errorMessage + "$}"
             + "{$CP0=API Error: " + errorMessage + "$}";
    } else {
        HostPrintUTF8("Translation failed. Please check input parameters or API Key configuration.\n");
        return "{$CP949=번역 실패: 입력 매개변수 또는 API 키 구성을 확인하십시오.$}"
             + "{$CP950=翻譯失敗：請檢查輸入參數或 API 金鑰配置。$}"
             + "{$CP936=翻译失败：请检查输入参数或 API 密钥配置。$}"
             + "{$CP0=Translation failed. Please check input parameters or API Key configuration.}$}";
    }
}

void OnInitialize() {
    HostPrintUTF8("ChatGPT translation plugin loaded.\n");
    // Load model name, API Key, and API URL from temporary storage (if saved)
    api_key = HostLoadString("gpt_api_key", "");
    selected_model = HostLoadString("gpt_selected_model", "gpt-4o-mini");
    apiUrl = HostLoadString("gpt_apiUrl", "https://api.openai.com/v1/chat/completions");
    if (!api_key.empty()) {
        HostPrintUTF8("Saved API Key, model name, and API URL loaded.\n");
    }
}

void OnFinalize() {
    HostPrintUTF8("ChatGPT translation plugin unloaded.\n");
}
