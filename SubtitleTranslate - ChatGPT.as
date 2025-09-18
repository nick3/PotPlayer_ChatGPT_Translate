/*
    Real-time subtitle translation for PotPlayer using OpenAI ChatGPT API
*/

// Plugin Information Functions
string GetTitle() {
    return "{$CP949=ChatGPT 번역$}"
         + "{$CP950=ChatGPT 翻譯$}"
         + "{$CP936=ChatGPT 翻译$}"
         + "{$CP0=ChatGPT Translate$}";
}

string GetVersion() {
    return "1.6";
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
    return "{$CP949=모델 이름, API 주소, 선택적 nullkey, 지연(ms) 및 재시도 모드(0-3)를 입력하십시오 (예: gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1).$}"
         + "{$CP949=\n\n설치 프로그램에서 미리 구성한 값이 있다면 PotPlayer 패널에서 다시 설정하기 전까지 해당 값을 사용하며, 패널에서 설정하면 해당 설정이 항상 우선 적용됩니다.$}"
         + "{$CP950=請輸入模型名稱、API 地址、可選的 nullkey、延遲毫秒與重試模式(0-3)（例如: gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1）。$}"
         + "{$CP950=\n\n如果安裝包已寫入預設配置，在 PotPlayer 面板中未重新設定之前會沿用這些配置；一旦在面板中調整，將始終以面板設定為準。$}"
         + "{$CP936=请输入模型名称、API 地址、可选的 nullkey、延迟毫秒和重试模式(0-3)（例如: gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1）。$}"
         + "{$CP936=\n\n如果安装包已经写入默认配置，在 PotPlayer 面板中没有重新设置之前会继续使用这些配置；一旦在面板中修改，将始终以面板设置为准。$}"
         + "{$CP0=Please enter the model name, API URL, optional 'nullkey', optional delay in ms, and retry mode 0-3 (e.g., gpt-5-nano|https://api.openai.com/v1/chat/completions|nullkey|500|retry1).$}"
         + "{$CP0=\n\nInstaller defaults will remain in effect until you update the settings in PotPlayer's panel, and any panel changes will always take priority.$}";
}

string GetUserText() {
    return "{$CP949=모델 이름|API 주소|nullkey|지연(ms)|재시도 모드 (현재: " + selected_model + " | " + apiUrl + " | " + delay_ms + " | " + retry_mode + ")$}"
         + "{$CP950=模型名稱|API 地址|nullkey|延遲ms|重試模式 (目前: " + selected_model + " | " + apiUrl + " | " + delay_ms + " | " + retry_mode + ")$}"
         + "{$CP936=模型名称|API 地址|nullkey|延迟ms|重试模式 (目前: " + selected_model + " | " + apiUrl + " | " + delay_ms + " | " + retry_mode + ")$}"
         + "{$CP0=Model Name|API URL|nullkey|Delay ms|Retry mode (Current: " + selected_model + " | " + apiUrl + " | " + delay_ms + " | " + retry_mode + ")$}";
}

string GetPasswordText() {
    return "{$CP949=API 키:$}"
         + "{$CP950=API 金鑰:$}"
         + "{$CP936=API 密钥:$}"
         + "{$CP0=API Key:$}";
}

// Global Variables
// Pre-configured values (auto-filled by installer)
string pre_api_key = ""; // will be replaced during installation
string pre_selected_model = "gpt-5-nano"; // will be replaced during installation
string pre_apiUrl = "https://api.openai.com/v1/chat/completions"; // will be replaced during installation
string pre_delay_ms = "0"; // will be replaced during installation
string pre_retry_mode = "0"; // will be replaced during installation
string pre_context_token_budget = "6000"; // approx. tokens reserved for context (0 = auto)
string pre_context_truncation_mode = "drop_oldest"; // drop_oldest | smart_trim

string api_key = pre_api_key;
string selected_model = pre_selected_model; // Default model
string apiUrl = pre_apiUrl; // Default API URL
string delay_ms = pre_delay_ms; // Request delay in ms
string retry_mode = pre_retry_mode; // Auto retry mode
string context_token_budget = pre_context_token_budget; // Approximate token budget for context
string context_truncation_mode = pre_context_truncation_mode; // Truncation mode when context exceeds budget
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
array<string> subtitleHistory;  // Global subtitle history

// Helper functions to load configuration while respecting installer defaults
string BuildConfigSentinel(const string &in key) {
    return "#__POTPLAYER_CFG_UNSET__#" + key + "#__";
}

string LoadInstallerConfig(const string &in key, const string &in installerValue) {
    string sentinel = BuildConfigSentinel(key);
    string storedValue = HostLoadString(key, sentinel);
    if (storedValue == sentinel)
        return installerValue;
    return storedValue;
}

void RefreshConfiguration() {
    api_key = LoadInstallerConfig("gpt_api_key", pre_api_key);
    selected_model = LoadInstallerConfig("gpt_selected_model", pre_selected_model);
    apiUrl = LoadInstallerConfig("gpt_apiUrl", pre_apiUrl);
    delay_ms = LoadInstallerConfig("gpt_delay_ms", pre_delay_ms);
    retry_mode = LoadInstallerConfig("gpt_retry_mode", pre_retry_mode);
    context_token_budget = LoadInstallerConfig("gpt_context_token_budget", pre_context_token_budget);
    context_truncation_mode = LoadInstallerConfig("gpt_context_truncation_mode", pre_context_truncation_mode);
}

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

bool IsDigits(const string &in s) {
    if (s.length() == 0)
        return false;
    for (uint i = 0; i < s.length(); i++) {
        uint8 c = s[i];
        if (c < 48 || c > 57)
            return false;
    }
    return true;
}

int ParseInt(const string &in s) {
    int v = 0;
    for (uint i = 0; i < s.length(); i++) {
        uint8 c = s[i];
        if (c < 48 || c > 57)
            return 0;
        v = v * 10 + (c - 48);
    }
    return v;
}

bool EqualsIgnoreCase(const string &in a, const string &in b) {
    if (a.length() != b.length())
        return false;
    for (uint i = 0; i < a.length(); i++) {
        uint8 ca = a[i];
        uint8 cb = b[i];
        if (ca >= 65 && ca <= 90)
            ca += 32;
        if (cb >= 65 && cb <= 90)
            cb += 32;
        if (ca != cb)
            return false;
    }
    return true;
}

// API Key and API Base verification process
string ServerLogin(string User, string Pass) {
    string errorAccum = "";
    User = User.Trim();
    Pass = Pass.Trim();
    array<string> tokens;
    int start = 0;
    for (int i = 0; i <= int(User.length()); i++) {
        if (i == int(User.length()) || User.substr(i, 1) == "|") {
            string token = User.substr(start, i - start).Trim();
            tokens.insertLast(token);
            start = i + 1;
        }
    }
    string userModel = "";
    string customApiUrl = "";
    bool allowNullApiKey = (Pass == "");
    string delayToken = "";
    string retryToken = "";
    if (tokens.length() >= 1) {
        userModel = tokens[0];
    }
    for (int i = 1; i < int(tokens.length()); i++) {
        string t = tokens[i];
        if (t == "nullkey")
            allowNullApiKey = true;
        else if (t.substr(0,5) == "retry" && IsDigits(t.substr(5)))
            retryToken = t.substr(5);
        else if (IsDigits(t))
            delayToken = t;
        else if (customApiUrl == "")
            customApiUrl = t;
    }
    if (retryToken != "")
        retry_mode = retryToken;
    if (delayToken != "")
        delay_ms = delayToken;
    if (userModel == "") {
        errorAccum += "Model name not entered. Please enter a valid model name.\n";
        return errorAccum;
    }
    string apiUrlLocal = "";
    if (customApiUrl != "") {
        apiUrlLocal = customApiUrl;
        while (apiUrlLocal != "" && apiUrlLocal.substr(apiUrlLocal.length()-1, 1) == "/")
            apiUrlLocal = apiUrlLocal.substr(0, apiUrlLocal.length()-1);
    } else {
        apiUrlLocal = pre_apiUrl;
    }
    if (!allowNullApiKey && Pass == "") {
        errorAccum += "API Key not configured. Please enter a valid API Key.\n";
        return errorAccum;
    }
    bool isOfficial = (apiUrlLocal.find("api.openai.com") != -1);
    string verifyHeaders = "Authorization: Bearer " + Pass + "\nContent-Type: application/json";
    string testSystemMsg = "You are a test assistant.";
    string testUserMsg = "Hello";
    string escapedTestSystemMsg = JsonEscape(testSystemMsg);
    string escapedTestUserMsg = JsonEscape(testUserMsg);
    string testRequestData = "{\"model\":\"" + userModel + "\","
                             "\"messages\":[{\"role\":\"system\",\"content\":\"" + escapedTestSystemMsg + "\"},"
                             "{\"role\":\"user\",\"content\":\"" + escapedTestUserMsg + "\"}],"
                             "\"max_tokens\":1,\"temperature\":0}";
    string testResponse = HostUrlGetString(apiUrlLocal, UserAgent, verifyHeaders, testRequestData);
    if (testResponse != "") {
        JsonReader testReader;
        JsonValue testRoot;
        if (testReader.parse(testResponse, testRoot)) {
            if (testRoot.isObject() && testRoot["choices"].isArray() && testRoot["choices"].size() > 0) {
                selected_model = userModel;
                api_key = Pass;
                HostSaveString("gpt_api_key", api_key);
                HostSaveString("gpt_selected_model", selected_model);
                HostSaveString("gpt_apiUrl", apiUrlLocal);
                HostSaveString("gpt_delay_ms", delay_ms);
    HostSaveString("gpt_retry_mode", retry_mode);
                return "200 ok";
            } else {
                if (testRoot.isObject() && testRoot["error"].isObject() && testRoot["error"]["message"].isString())
                    errorAccum += "Test message error: " + testRoot["error"]["message"].asString() + "\n";
                else
                    errorAccum += "Test message response invalid.\n";
            }
        } else {
            errorAccum += "Failed to parse test message response.\n";
        }
    } else {
        errorAccum += "No response from server when sending test message.\n";
    }
    if (apiUrlLocal.find("chat/completions") == -1) {
        string correctedApiUrl = apiUrlLocal + "/chat/completions";
        string correctedTestResponse = HostUrlGetString(correctedApiUrl, UserAgent, verifyHeaders, testRequestData);
        if (correctedTestResponse != "") {
            JsonReader correctedReader;
            JsonValue correctedRoot;
            if (correctedReader.parse(correctedTestResponse, correctedRoot)) {
                if (correctedRoot.isObject() && correctedRoot["choices"].isArray() && correctedRoot["choices"].size() > 0) {
                    apiUrlLocal = correctedApiUrl;
                    selected_model = userModel;
                    api_key = Pass;
                    HostSaveString("gpt_api_key", api_key);
                    HostSaveString("gpt_selected_model", selected_model);
                    HostSaveString("gpt_apiUrl", apiUrlLocal);
                    HostSaveString("gpt_delay_ms", delay_ms);
    HostSaveString("gpt_retry_mode", retry_mode);
                    return "Warning: Your API base was auto-corrected to: " + apiUrlLocal + "\n200 ok";
                } else {
                    if (correctedRoot.isObject() && correctedRoot["error"].isObject() && correctedRoot["error"]["message"].isString())
                        errorAccum += "Auto-correction test error: " + correctedRoot["error"]["message"].asString() + "\n";
                    else
                        errorAccum += "Auto-correction test response invalid.\n";
                }
            } else {
                errorAccum += "Failed to parse auto-correction test response.\n";
            }
        } else {
            errorAccum += "No response from server after auto-correction.\n";
        }
    }
    if (isOfficial) {
        string verifyUrl = "";
        int pos = apiUrlLocal.find("chat/completions");
        if (pos != -1)
            verifyUrl = apiUrlLocal.substr(0, pos) + "models";
        else
            verifyUrl = "https://api.openai.com/v1/models";
        string verifyResponse = HostUrlGetString(verifyUrl, UserAgent, verifyHeaders, "");
        if (verifyResponse == "")
            errorAccum += "Server connection failed: Unable to retrieve model list. Check network and API Base.\n";
        else {
            JsonReader reader;
            JsonValue root;
            if (!reader.parse(verifyResponse, root))
                errorAccum += "Failed to parse model list response. Check API Base and API Key.\n";
            else {
                if (root.isObject() && root["error"].isObject() && root["error"]["message"].isString())
                    errorAccum += "API error during model list retrieval: " + root["error"]["message"].asString() + "\n";
                else if (root.isObject() && root["data"].isArray()) {
                    bool modelFound = false;
                    int dataSize = root["data"].size();
                    for (int i = 0; i < dataSize; i++) {
                        JsonValue element = root["data"][i];
                        if (element.isObject() && element["id"].isString()) {
                            if (element["id"].asString() == userModel) {
                                modelFound = true;
                                break;
                            }
                        }
                    }
                    if (!modelFound)
                        errorAccum += "The specified model '" + userModel + "' is not available in the official API.\n";
                } else
                    errorAccum += "Invalid format of model list response.\n";
            }
        }
    } else {
        errorAccum += "API verification via model list skipped for third-party API Base.\n";
    }
    if (!allowNullApiKey && Pass.length() < 20)
        errorAccum += "API Key verification failed: API Key length may too short. Please verify your API Key.\n";
    if (errorAccum != "")
        return "API verification failed with the following issues:\n\n" + errorAccum;
    return "Unknown error during API verification. Please check your network, API Key, and API Base settings.\n";
}

// Logout Interface to clear model name and API Key
void ServerLogout() {
    api_key = "";
    selected_model = pre_selected_model;
    apiUrl = pre_apiUrl;
    delay_ms = pre_delay_ms;
    retry_mode = pre_retry_mode;
    context_token_budget = pre_context_token_budget;
    context_truncation_mode = pre_context_truncation_mode;
    HostSaveString("gpt_api_key", "");
    HostSaveString("gpt_selected_model", selected_model);
    HostSaveString("gpt_apiUrl", apiUrl);
    HostSaveString("gpt_delay_ms", delay_ms);
    HostSaveString("gpt_retry_mode", retry_mode);
    HostSaveString("gpt_context_token_budget", context_token_budget);
    HostSaveString("gpt_context_truncation_mode", context_truncation_mode);
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
    output.replace("/", "\\/");
    return output;
}

// Function to estimate token count based on character length
int EstimateTokenCount(const string &in text) {
    return int(float(text.length()) / 4);
}

// Function to get the model's maximum context length
int GetModelMaxTokens(const string &in modelName) {
    string trimmedModel = modelName.Trim();
    if (trimmedModel == "")
        return 4096;

    // Known model prefixes mapped to approximate maximum context length (tokens).
    array<string> knownContexts = {
        "gpt-5-nano", "128000",
        "gpt-5-mini", "128000",
        "gpt-5", "200000",
        "gpt-4.1-nano", "128000",
        "gpt-4.1-mini", "128000",
        "gpt-4.1-realtime", "128000",
        "gpt-4.1-preview", "128000",
        "gpt-4.1", "128000",
        "gpt-4o-mini-translate", "128000",
        "gpt-4o-mini-transcribe", "128000",
        "gpt-4o-mini-audio", "128000",
        "gpt-4o-mini", "128000",
        "gpt-4o-realtime-preview", "128000",
        "gpt-4o-realtime", "128000",
        "gpt-4o-audio-preview", "128000",
        "gpt-4o", "128000",
        "gpt-4-turbo-preview", "128000",
        "gpt-4-turbo", "128000",
        "gpt-3.5-turbo-16k", "16384",
        "gpt-3.5-turbo", "4096",
        "o4-mini", "64000",
        "o3-mini", "64000",
        "o1-preview", "128000",
        "o1-mini", "64000",
        "o1", "128000",
        "glm-4-plus", "128000",
        "glm-4-air", "128000",
        "glm-4", "128000",
        "glm-3", "32000",
        "claude-3.5-sonnet", "200000",
        "claude-3.5-haiku", "200000",
        "claude-3-opus", "200000",
        "claude-3-sonnet", "200000",
        "claude-3-haiku", "200000",
        "claude-2.1", "200000",
        "gemini-1.5-pro", "1000000",
        "gemini-1.5-flash-8b", "1000000",
        "gemini-1.5-flash", "1000000",
        "gemini-1.0-pro", "32000",
        "gemini-1.0", "32000",
        "gemini-pro", "32000",
        "deepseek-r1", "131072",
        "deepseek-chat", "131072",
        "deepseek-v3", "131072",
        "qwen2.5", "131072",
        "qwen2", "131072",
        "qwen1.5", "65536",
        "qwen", "32768",
        "yi-1.5", "131072",
        "yi-large", "131072",
        "yi-34b", "131072",
        "yi-9b", "65536",
        "llama-3.2", "128000",
        "llama-3.1-405b", "128000",
        "llama-3.1-70b", "128000",
        "llama-3.1-8b", "128000",
        "llama-3.1", "128000",
        "llama-3-70b", "8192",
        "llama-3-8b", "8192",
        "llama-2", "4096",
        "mixtral-8x22b", "65536",
        "mixtral-8x7b", "32768",
        "mistral-large", "32000",
        "mistral-medium", "32000",
        "mistral-small", "16000",
        "phi-3.5", "128000",
        "phi-3", "128000",
        "grok-2", "131072",
        "grok-1.5", "131072"
    };
    for (uint i = 0; i + 1 < knownContexts.length(); i += 2) {
        string pattern = knownContexts[i];
        if (trimmedModel.length() >= pattern.length() && trimmedModel.substr(0, pattern.length()) == pattern)
            return ParseInt(knownContexts[i + 1]);
    }

    if (trimmedModel.find("1000k") != -1 || trimmedModel.find("1m") != -1)
        return 1000000;
    if (trimmedModel.find("512k") != -1)
        return 524288;
    if (trimmedModel.find("320k") != -1)
        return 320000;
    if (trimmedModel.find("256k") != -1)
        return 256000;
    if (trimmedModel.find("200k") != -1)
        return 200000;
    if (trimmedModel.find("160k") != -1)
        return 160000;
    if (trimmedModel.find("131k") != -1 || trimmedModel.find("130k") != -1)
        return 131072;
    if (trimmedModel.find("128k") != -1)
        return 128000;
    if (trimmedModel.find("100k") != -1)
        return 100000;
    if (trimmedModel.find("80k") != -1)
        return 80000;
    if (trimmedModel.find("65k") != -1)
        return 65000;
    if (trimmedModel.find("64k") != -1)
        return 64000;
    if (trimmedModel.find("40k") != -1)
        return 40000;
    if (trimmedModel.find("32k") != -1)
        return 32768;
    if (trimmedModel.find("16k") != -1)
        return 16384;
    if (trimmedModel.find("8k") != -1)
        return 8192;
    if (trimmedModel.find("4k") != -1)
        return 4096;

    if (trimmedModel.find("flash") != -1)
        return 1000000;
    if (trimmedModel.find("deepseek") != -1)
        return 131072;
    if (trimmedModel.find("grok") != -1)
        return 131072;
    if (trimmedModel.find("yi") != -1)
        return 131072;
    if (trimmedModel.find("phi-3") != -1)
        return 128000;
    if (trimmedModel.find("phi") != -1)
        return 8192;
    if (trimmedModel.find("llama-3.2") != -1 || trimmedModel.find("llama-3.1") != -1)
        return 128000;
    if (trimmedModel.find("llama-3") != -1)
        return 8192;
    if (trimmedModel.find("llama-2") != -1)
        return 4096;
    if (trimmedModel.find("claude") != -1)
        return 200000;
    if (trimmedModel.find("gemini") != -1)
        return 32000;

    if (trimmedModel.find("nano") != -1)
        return 128000;
    if (trimmedModel.find("mini") != -1)
        return 64000;
    if (trimmedModel.find("sonnet") != -1)
        return 200000;
    if (trimmedModel.find("haiku") != -1)
        return 128000;
    if (trimmedModel.find("opus") != -1)
        return 200000;
    if (trimmedModel.find("qwen") != -1)
        return 32768;
    if (trimmedModel.find("glm") != -1)
        return 128000;
    if (trimmedModel.find("mistral") != -1)
        return 32000;
    if (trimmedModel.find("mixtral") != -1)
        return 65536;

    return 4096;
}

// Translation Function
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    RefreshConfiguration();

    if (api_key == "") {
        HostPrintUTF8("API Key not configured. Please enter it in the settings menu.\n");
        return "";
    }

    if (DstLang == "" || DstLang == "Auto Detect") {
        HostPrintUTF8("Target language not specified. Please select a target language.\n");
        return "";
    }

    if (SrcLang == "" || SrcLang == "Auto Detect") {
        SrcLang = "";
    }

    subtitleHistory.insertLast(Text);

    int maxTokens = GetModelMaxTokens(selected_model);
    int safeBudget = maxTokens - 1000;
    if (safeBudget < 0)
        safeBudget = maxTokens;
    if (safeBudget < 0)
        safeBudget = 0;

    int configuredBudget = ParseInt(context_token_budget);
    if (configuredBudget <= 0 || configuredBudget > safeBudget)
        configuredBudget = safeBudget;

    string truncMode = context_truncation_mode;
    bool useSmartTrim = EqualsIgnoreCase(truncMode, "smart_trim");

    int currentTokens = EstimateTokenCount(Text);
    if (currentTokens < 0)
        currentTokens = 0;
    int availableForContext = safeBudget - currentTokens;
    if (availableForContext < 0)
        availableForContext = 0;
    if (availableForContext > configuredBudget)
        availableForContext = configuredBudget;

    array<string> contextSegments;
    int usedContextTokens = 0;
    int idx = int(subtitleHistory.length()) - 2;
    while (idx >= 0 && usedContextTokens < availableForContext) {
        string subtitle = subtitleHistory[idx];
        int subtitleTokens = EstimateTokenCount(subtitle);
        if (subtitleTokens <= 0) {
            idx--;
            continue;
        }
        if (usedContextTokens + subtitleTokens <= availableForContext) {
            contextSegments.insertAt(0, subtitle);
            usedContextTokens += subtitleTokens;
        } else if (useSmartTrim) {
            int remainingTokens = availableForContext - usedContextTokens;
            if (remainingTokens > 0) {
                int charBudget = remainingTokens * 4;
                int subtitleLength = int(subtitle.length());
                if (charBudget < subtitleLength)
                    subtitle = subtitle.substr(subtitleLength - charBudget, charBudget);
                contextSegments.insertAt(0, subtitle);
            }
            usedContextTokens = availableForContext;
            break;
        } else {
            break;
        }
        idx--;
    }

    string context = "";
    for (uint ctxIndex = 0; ctxIndex < contextSegments.length(); ctxIndex++) {
        if (ctxIndex > 0)
            context += "\n";
        context += contextSegments[ctxIndex];
    }

    int historyBudget = configuredBudget;
    if (historyBudget <= 0)
        historyBudget = safeBudget;
    if (historyBudget < 0)
        historyBudget = 0;
    int historyTarget = historyBudget > 0 ? int(historyBudget / 16) : 0;
    if (historyTarget < 96)
        historyTarget = 96;
    if (historyTarget > 2048)
        historyTarget = 2048;
    int shrinkTarget = historyTarget - 64;
    if (shrinkTarget < 64)
        shrinkTarget = historyTarget / 2;
    if (shrinkTarget < 32)
        shrinkTarget = 32;
    if (subtitleHistory.length() > historyTarget) {
        while (subtitleHistory.length() > shrinkTarget) {
            subtitleHistory.removeAt(0);
        }
    }

    string systemMsg =
        "You are an expert subtitle translate tool with a deep understanding of both language and culture."
        "Based on contextual clues, you provide translations that capture not only the literal meaning but also the nuanced metaphors, euphemisms, and cultural symbols embedded in the dialogue."
        "Your translations reflect the intended tone and cultural context, ensuring that every subtle reference and idiomatic expression is accurately conveyed."
        "I will provide you with some context for better translations, but DO NOT output any of them.\n"

        "Rules:\n"
        "1. Output the translation only."
        "2. Do NOT output extra comments or explanations."
        "3. Do NOT use any special characters or formatting in the translation.";

    string userMsg =
        "Translate the complete content under the section 'Subtitle to translate' based on the section 'Subtitle context', if it exists.\n\n"
        "Source language: " + (SrcLang == "" ? "Auto Detect" : SrcLang) + "\n"
        "Target language: " + DstLang + "\n\n";

    if (context != "") {
        userMsg += "[Subtitle context](DO NOT OUTPUT!):\n" + "{" + context + "}\n\n";
    }

    userMsg += "[Subtitle to translate]:\n" + "{" + Text + "}";

    string escapedSystemMsg = JsonEscape(systemMsg);
    string escapedUserMsg = JsonEscape(userMsg);

    string requestData = "{\"model\":\"" + selected_model + "\","
                         "\"messages\":[{\"role\":\"system\",\"content\":\"" + escapedSystemMsg + "\"},"
                         "{\"role\":\"user\",\"content\":\"" + escapedUserMsg + "\"}],"
                         "\"max_tokens\":1000,\"temperature\":0}";

    string headers = "Authorization: Bearer " + api_key + "\nContent-Type: application/json";
    int delayInt = ParseInt(delay_ms);
    int retryModeInt = ParseInt(retry_mode);
    string response = "";
    int attempts = 0;
    while (true) {
        if (attempts == 0 || (retryModeInt == 3 && attempts > 0)) {
            if (delayInt > 0)
                HostSleep(delayInt);
        }
        response = HostUrlGetString(apiUrl, UserAgent, headers, requestData);
        if (response != "" || retryModeInt == 0 || (retryModeInt == 1 && attempts >= 1))
            break;
        attempts++;
    }
    if (response == "") {
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
    if (choices.isArray() && choices.size() > 0 &&
        choices[0].isObject() &&
        choices[0]["message"].isObject() &&
        choices[0]["message"]["content"].isString()) {
        string translatedText = choices[0]["message"]["content"].asString();
        if (selected_model.find("gemini") != -1) {
            while (translatedText.length() > 0 && translatedText.substr(translatedText.length() - 1, 1) == "\n") {
                translatedText = translatedText.substr(0, translatedText.length() - 1);
            }
        }
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            string UNICODE_RLE = "\u202B";
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText.Trim();
    }

    if (Root.isObject() &&
        Root["error"].isObject() &&
        Root["error"]["message"].isString()) {
        string errorMessage = Root["error"]["message"].asString();
        HostPrintUTF8("API Error: " + errorMessage + "\n");
        return "API Error: " + errorMessage;
    } else {
        HostPrintUTF8("Translation failed. Please check input parameters or API Key configuration.\n");
        return "Translation failed. Please check input parameters or API Key configuration.";
    }
}

// Plugin Initialization
void OnInitialize() {
    HostPrintUTF8("ChatGPT translation plugin loaded.\n");
    RefreshConfiguration();
    if (api_key != "") {
        HostPrintUTF8("Saved API Key, model name, and API URL loaded.\n");
    }
}

// Plugin Finalization
void OnFinalize() {
    HostPrintUTF8("ChatGPT translation plugin unloaded.\n");
}
