.pragma library
.import "gemini.js" as Gemini
.import "ollama.js" as Ollama

var ollamaUrl = "";
var geminiKey = "";
var loadedModels = {};
var modelKey = "";

function setGeminiApiKey(key) {
    geminiKey = key;
    Gemini.setApiKey(key);
}

function setOllamaUrl(url) {
    ollamaUrl = url;
    Ollama.setBaseUrl(url);
}

function getOllamaModels(callback) {
    console.log("Fetching Ollama models from URL: " + ollamaUrl);
    Ollama.listModels((models, error) => {
        processModels(models, callback, error);
    });
}

function getGeminiModels(callback) {
    console.log("Fetching Gemini models with API Key: " + geminiKey);
    Gemini.listModels((models, error) => {
        processModels(models, callback, error);
    });
}

function setModel(model) {
    console.log("Setting current model to: " + model);
    modelKey = model;
}

function currentModel() {
    return loadedModels[modelKey];
}

function processModels(models, callback, error) {
    if (models && models.length > 0) {
        // Set default model to first available if none selected
        if (currentModel === "") {
            setModel(models[0].name);
        }

        for (var i = 0; i < models.length; i++) {
            loadedModels[models[i].name] = models[i];
        }


        callback(models, null);
    }  
}

function setUseGrounding(enabled) {
    Gemini.setUseGrounding(enabled);
}

function setSystemPrompt(prompt) {
    Ollama.setSystemPrompt(prompt);
    Gemini.setSystemPrompt(prompt);
}

function listModels(callback) {
    callback(loadedModels);
}

function getProvider() {
    if (currentModel().provider === "ollama") {
        return Ollama
    } else if (currentModel().provider === "gemini") {
        return Gemini
    }
    
    new Error("Unknown provider: " + currentModel().provider);
}

function sendMessage(text, callback) {
    if (!currentModel()) {
        console.log("ModelKey: " + modelKey);
        callback(null, "No model selected");
        return;
    }

    getProvider().setModel(currentModel().name);
    getProvider().sendMessage(text, callback);
}
