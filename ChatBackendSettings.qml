import QtQuick
import Quickshell.Io

Process {
    id: root

    property string apiKey: ""
    signal newMessage(string text, bool isError)

    property string pluginPath: Qt.resolvedUrl(".").toString().replace("file://", "")

    environment: { "GEMINI_API_KEY": apiKey }
    command: [pluginPath + "backend/.venv/bin/python3", "-u", pluginPath + "backend/main.py", '--list']
    
    running: false

    stdout: SplitParser {

        onRead: function(message) { 
            try {
                return root.newMessage(message, false);
            } catch (err) {
                console.warn("Failed to parse backend response:", err, message);
                return root.newMessage("Error: Invalid response from backend", true);
            }
        }
    }

    stderr: SplitParser {
        onRead: line => {
            console.log('error reading?')
            if (line.trim()) {
                ToastService.showError("Script error", line)
            }
        }
    }



    function sendMessage(text) {
        console.log('trying to send a message from ChatBackend:', text);
        console.log('is running:', root.running);
        if (root.running) {
            root.write(text + "\n");
        } else {
            root.newMessage("Error: Backend not running", true);
        }
    }
}
