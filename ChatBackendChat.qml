import QtQuick
import Quickshell.Io

Process {
    id: root

    property string apiKey: ""
    signal newMessage(string text, bool isError)

    property string pluginPath: Qt.resolvedUrl(".").toString().replace("file://", "")

    environment: { "GEMINI_API_KEY": apiKey }
    command: [pluginPath + "backend/.venv/bin/python3", "-u", pluginPath + "backend/main.py"]
    
    running: false

    stdout: SplitParser {

        onRead: function(line) { 
            console.log('api key? ', root.apiKey )
            console.log("Script:", line)
            const lines = line.split("\n");
            
            for (let i = 0; i < lines.length; i++) {
               const line = lines[i].trim();
               if (line === "") continue;
            
                try {
                    const response = JSON.parse(line);
                    if (response.text) {
                        root.newMessage(response.text, false);
                    } else if (response.error) {
                        root.newMessage("Error: " + response.error, true);
                    }
                } catch (err) {
                    console.warn("Failed to parse backend response:", err, line);
                }
            }
        }
    }

    stderr: SplitParser {
        onRead: line => {
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
