/*
    Real-time subtitle translation for PotPlayer using OpenAI ChatGPT API
    (Without Context Support)
*/

// Plugin Information Functions
string GetTitle() {
    return "{$CP949=ChatGPT 번역 (문맥 없음) $}"
         + "{$CP950=ChatGPT 翻譯 (無上下文) $}"
         + "{$CP936=ChatGPT 翻译 (无上下文) $}"
        + "{$CP0=ChatGPT Translate (No Context) $}";
}

string GetVersion() {
    return "1.4.1.1-wc";
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
    return "{$CP949=모델 이름과 API 주소, 그리고 API 키를 입력하십시오 (예: gpt-4o-mini|https://api.openai.com/v1/chat/completions).$}"
         + "{$CP950=請輸入模型名稱與 API 地址，以及 API 金鑰（例如: gpt-4o-mini|https://api.openai.com/v1/chat/completions）。$}"
         + "{$CP936=请输入模型名称和 API 地址，以及 API 密钥（例如: gpt-4o-mini|https://api.openai.com/v1/chat/completions）。$}"
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
   Modified ServerLogin with API base detection logic.
   - For official API base (api.openai.com), if API key or model check fails, return error.
   - For third-party API base, if issues occur, return warning messages but still save settings.
   - All returned messages use English only.
*/
string ServerLogin(string User, string Pass) {
    User = User.Trim();
    Pass = Pass.Trim();

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
        return "Model name not entered. Please enter a valid model name.\n";
    }
    if (!customApiUrl.empty()) {
        while (customApiUrl.length() > 0 && customApiUrl.substr(customApiUrl.length()-1, 1) == "/") {
            customApiUrl = customApiUrl.substr(0, customApiUrl.length()-1);
        }
        apiUrl = customApiUrl;
    } else {
        apiUrl = "https://api.openai.com/v1/chat/completions";
    }
    if (Pass.empty()) {
        return "API Key not configured. Please enter a valid API Key.\n";
    }

    // Determine if using official API base
    bool isOfficial = (apiUrl.find("api.openai.com") != -1);

    // Construct verify URL
    string verifyUrl = "";
    if (isOfficial) {
        int pos = apiUrl.find("chat/completions");
        if (pos != -1)
            verifyUrl = apiUrl.substr(0, pos) + "models";
        else
            verifyUrl = "https://api.openai.com/v1/models";
    } else {
        int lastSlash = apiUrl.findLast("/");
        if (lastSlash != -1)
            verifyUrl = apiUrl.substr(0, lastSlash) + "/models";
        else
            verifyUrl = apiUrl + "/models";
    }

    string verifyHeaders = "Authorization: Bearer " + Pass + "\nContent-Type: application/json";
    string verifyResponse = HostUrlGetString(verifyUrl, UserAgent, verifyHeaders, "");
    string retMsg = "";
    if (verifyResponse.empty()) {
        if (isOfficial)
            return "API Key verification failed: No response from server. Please check network connection or API Key.\n";
        else
            retMsg += "Warning: API Key verification failed: No response from server (third-party API base, possible false positive).\n";
    }

    JsonReader reader;
    JsonValue root;
    if (!reader.parse(verifyResponse, root)) {
        if (isOfficial)
            return "Failed to parse API verification response.\n";
        else
            retMsg += "Warning: Failed to parse API verification response (third-party API base, possible false positive).\n";
    }

    if (!root["error"].isNull()) {
        string errorMsg = root["error"]["message"].asString();
        if (isOfficial)
            return "API Key verification failed: " + errorMsg + "\n";
        else
            retMsg += "Warning: API Key verification failed: " + errorMsg + " (third-party API base, possible false positive).\n";
    }

    bool modelFound = false;
    bool dataValid = (!root["data"].isNull() && root["data"].isArray());
    if (isOfficial) {
        if (!dataValid)
            return "Invalid response format during API Key verification (official API).\n";
    } else {
        if (!dataValid) {
            retMsg += "Warning: Unable to verify model list using third-party API base (possible false positive).\n";
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
                return "The specified model '" + userModel + "' is not available in the API. Please check the model name.\n";
            else
                retMsg += "Warning: The specified model '" + userModel + "' is not available in the API (third-party API base, possible false positive).\n";
        }
    }

    // Save settings
    selected_model = userModel;
    api_key = Pass;
    HostSaveString("wc_gpt_api_key", api_key);
    HostSaveString("wc_gpt_selected_model", selected_model);
    HostSaveString("wc_gpt_apiUrl", apiUrl);
    if (isOfficial)
        return "200 ok";
    else
        return retMsg + "API Key and model name (plus API URL) configured, but verification results may be false positives due to third-party API base.\n";
}

// Logout Interface to clear model name and API Key
void ServerLogout() {
    api_key = "";
    selected_model = "gpt-4o-mini";
    apiUrl = "https://api.openai.com/v1/chat/completions";
    HostSaveString("wc_gpt_api_key", "");
    HostSaveString("wc_gpt_selected_model", selected_model);
    HostSaveString("wc_gpt_apiUrl", apiUrl);
    HostPrintUTF8("Successfully logged out.\n");
}

// JSON String Escape Function
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    output.replace("/", "\\/");  // Escape forward slash for model names with '/'
    return output;
}

string Translate(string Text, string &in SrcLang, string &in DstLang) {
    api_key = HostLoadString("wc_gpt_api_key", "");
    selected_model = HostLoadString("wc_gpt_selected_model", "gpt-4o-mini");
    apiUrl = HostLoadString("wc_gpt_apiUrl", "https://api.openai.com/v1/chat/completions");

    if (api_key.empty()) {
        HostPrintUTF8("API Key not configured. Please enter it in the settings menu.\n");
        return "";
    }

    if (DstLang.empty() || DstLang == "Auto Detect") {
        HostPrintUTF8("Target language not specified. Please select a target language.\n");
        return "";
    }

    if (SrcLang.empty() || SrcLang == "Auto Detect") {
        SrcLang = "";
    }

    // Construct the prompt
    string prompt = "You are a professional subtitle translator. Your task is to accurately translate the following subtitle while preserving its original tone, formatting, and meaning. Ensure proper grammar, natural fluency, and cultural appropriateness in the translation. Output only the translated text without additional comments or explanations.\n\n";

    // Specify source and target languages
    prompt += "Translate from " + (SrcLang.empty() ? "Auto Detect" : SrcLang);
    prompt += " to " + DstLang + ".\n";

    // Add subtitle text
    prompt += "Subtitle:\n" + Text + "\n";

    // JSON escape the prompt
    string escapedPrompt = JsonEscape(prompt);

    // Prepare the request data
    string requestData = "{\"model\":\"" + selected_model + "\"," +
                         "\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}]," +
                         "\"max_tokens\":1000,\"temperature\":0}";

    string headers = "Authorization: Bearer " + api_key + "\nContent-Type: application/json";

    // Send request
    string response = HostUrlGetString(apiUrl, UserAgent, headers, requestData);
    if (response.empty()) {
        HostPrintUTF8("Translation request failed. Please check network connection or API Key.\n");
        return "";
    }

    // Parse response
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
        // Handle right-to-left languages.
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            string UNICODE_RLE = "\u202B"; // For Right-to-Left languages
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText.Trim();
    }

    if (Root["error"]["message"].isString()) {
        string errorMessage = Root["error"]["message"].asString();
        HostPrintUTF8("API Error: " + errorMessage + "\n");
        return "API Error: " + errorMessage;
    } else {
        HostPrintUTF8("Translation failed. Please check input parameters or API Key configuration.\n");
        return "Translation failed. Please check input parameters or API Key configuration.";
    }

    return "";
}

// Plugin Initialization
void OnInitialize() {
    HostPrintUTF8("ChatGPT translation plugin loaded.\n");
    // Load model name, API Key, and apiUrl from temporary storage (if saved)
    api_key = HostLoadString("wc_gpt_api_key", "");
    selected_model = HostLoadString("wc_gpt_selected_model", "gpt-4o-mini");
    apiUrl = HostLoadString("wc_gpt_apiUrl", "https://api.openai.com/v1/chat/completions");
    if (!api_key.empty()) {
        HostPrintUTF8("Saved API Key, model name, and API URL loaded.\n");
    }
}

// Plugin Finalization
void OnFinalize() {
    HostPrintUTF8("ChatGPT translation plugin unloaded.\n");
}
