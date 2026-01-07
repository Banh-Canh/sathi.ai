import QtQuick
import qs.Common 
import qs.Widgets

DankRectangle {
    id: root
    property string text: ""
    property bool isUser: false

    // @todo we want to address the bubble width so that its the total width of the child + padding 
    // unfortunately my attempts at this didn't work yet. So we'll keep the width fixed to its parent.
    width: parent.width 
    height: msgText.height + (Theme.spacingL * 2)

    // Alignment in the Column
    anchors.right: root.isUser ? parent.right : undefined
    anchors.left: root.isUser ? undefined : parent.left
    
    color: root.isUser ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
    radius: Theme.cornerRadius
    
    StyledText {
        id: msgText
        text: root.text
        textFormat: Text.MarkdownText
        onLinkActivated: link => Qt.openUrlExternally(link)
        
        // Use full available width minus padding
        width: root.width - (Theme.spacingL * 2)
        wrapMode: Text.Wrap
        
        anchors.centerIn: parent
        color: Theme.surfaceText
    }    
}
