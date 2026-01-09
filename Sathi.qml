import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "dank:sathi-ai"

    property var displayText: "✨"
    property bool isLoading: false
    property string aiModel: pluginData.aiModel || "gemini-flash-latest"

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            StyledText {
                text: root.displayText
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS
            StyledText {
                text: root.displayText
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    property ListModel chatModel: ListModel { }
    property ListModel availableAisModel: ListModel { }


    ChatBackendChat {
        id: backendChat
        apiKey: pluginData.geminiApiKey || ""
        running: false 
        model: root.aiModel

        onNewMessage: (text, isError) => {
            root.isLoading = false;
            chatModel.append({
                "text": text,
                "isUser": false,
                "shouldAnimate": true
            });
        }
    }

    ChatBackendSettings {
        id: backendSettings
        apiKey: pluginData.geminiApiKey || ""
        running: false
        onNewMessage: (text, isError) => {
            console.log('got new settings message:', text, isError);
            try {
                var data = JSON.parse(text);
                for (var i = 0; i < data.length; i++) {
                    availableAisModel.append(data[i]); // Append each item to the ListModel
                }

                console.log('models set to ', availableAisModel);
            } catch (err) {
                console.error('failed to set models:', err)
            }
        }


    }

    Component.onCompleted: {
        // Delay start to ensure pluginData is ready and env vars are set
        
        Qt.callLater(() => {
            if (pluginData.geminiApiKey) {
                console.log('running backends now!?')
                backendChat.running = true
                backendSettings.running = true
            }
        })
    }

    function processMessage(message) {
        console.log(pluginData.geminiApiKey);
        console.log(pluginData);        

        if (message === "") return;

        chatModel.append({ "text": message, "isUser": true, "shouldAnimate": false });
        root.isLoading = true;

        backendChat.sendMessage(message);
    }

    // function getPopoutContent() {
    //     const key = pluginData.geminiApiKey;

    //     if (key && key !== "") {
    //         console.log('i guess we got an api key!?')
    //         return chatPopout;
    //     } else {
    //         console.log("No API key set - is there a toast service!?"); 
    //         ToastService.showError("Script failed", "Exit code: " + exitCode)
    //     }
    // }

    popoutContent: chatPopout // getPopoutContent()

    Component {
        id: chatPopout
        PopoutComponent {
            id: popoutColumn
            showCloseButton: true

            
            Item {
                width: parent.width
                height: root.popoutHeight - popoutColumn.headerHeight -
                               popoutColumn.detailsHeight - Theme.spacingL

                AnimatedImage {
                    id: thinkingAnimation
                    anchors.centerIn: parent
                    width: 100 
                    height: 100
                    source: "thinking.gif"
                    fillMode: Image.PreserveAspectFit
                    
                    property bool isWaiting: (root.chatModel.count > 0 && root.chatModel.get(root.chatModel.count - 1).isUser)

                    opacity: isWaiting ? 0.5 : 0.0
                    playing: isWaiting
                    
                    onPlayingChanged: {
                        if (playing) currentFrame = 0
                    }
                    
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Flickable { 
                    id: flickable
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: columnBottomSection.top
                    anchors.bottomMargin: Theme.spacingL
                   
                    contentWidth: width
                    contentHeight: chatColumn.height
                    clip: true
                    flickableDirection: Flickable.VerticalFlick

                    function scrollToBottom() {
                        if (contentHeight > height)
                            contentY = contentHeight - height;
                    }

                    Column {
                        id: chatColumn
                        width: parent.width
                        spacing: Theme.spacingL
                        padding: Theme.spacingL
                        
                        onHeightChanged: flickable.scrollToBottom()

                        Repeater {
                            model: root.chatModel
                            delegate: ChatBubble {
                                text: model.text
                                isUser: model.isUser
                                shouldAnimate: model.shouldAnimate
                                width: chatColumn.width - (chatColumn.padding * 2)
                                onAnimationCompleted: model.shouldAnimate = false
                                opacity: thinkingAnimation.isWaiting ? 0.5 : 1.0
                            }
                        }

                    }
                }

                Column { 
                    id: columnBottomSection
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: Theme.spacingL
                    // anchors.bottomMargin: Theme.spacingL
                    // bottomPadding: 20
                    
                    spacing: Theme.spacingXS
                    
                    width: parent.width
                    // height: 75

                    // Dank Textfield at the bottom for user input
                    ChatInput {
                        id: chatInput
                        width: parent.width
                        // anchors.bottomMargin: Theme.spacingL
                        // anchors.margins: Theme.spacingL
                        onAccepted: {
                            // Handle the input text here
                            console.log("User input:", text); 
                            root.processMessage(text);
                            
                            text = ""; // Clear input after processing
                        }
                    }

                    // Display a small combo box at the bottom to change the model dynamically.
                    AiSelector {
                        id: cbModelSelector
                        model: availableAisModel
                        maxPopupHeight: popoutColumn.height * 0.6

                        currentValue: pluginData.aiModel ||  "gemini-flash-latest"
                        width: parent.width
                        textRole: "display_name"
                        valueRole: "name"

                        onActivated: {
                            if (pluginService) {
                                root.aiModel = currentValue
                                pluginService.savePluginData(pluginId, "aiModel", currentValue)
                            }
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 400
    popoutHeight: 500
}
