import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "sathi.ai"

    StyledText {
        width: parent.width
        text: "Sathi AI Plugin Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Google Gemini Api Key"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "geminiApiKey"
        // label: "Google Gemini API Key"
        description: "Enter your Google Gemini API key"
        placeholder: "Enter API key"
        defaultValue: ""
    }
}