import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

TextArea {
    id: root

    signal accepted()

    color: Theme.surfaceText
    font.pixelSize: Theme.fontSizeMedium
    selectedTextColor: Theme.onPrimary
    selectionColor: Theme.primary

    wrapMode: TextEdit.Wrap
    
    placeholderText: "Type a message..."
    placeholderTextColor: Theme.surfaceText

    background: Rectangle {
        implicitHeight: 40
        color: Theme.surfaceContainerHigh
        radius: Theme.cornerRadius
        border.width: 1
        border.color: root.activeFocus ? Theme.primary : "transparent"
    }

    padding: Theme.spacingM

    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            if (event.modifiers & Qt.ShiftModifier) {
                // Allow new line implicitly by not accepting the event
                event.accepted = false; 
            } else {
                event.accepted = true;
                root.accepted();
            }
        }
    }
}
