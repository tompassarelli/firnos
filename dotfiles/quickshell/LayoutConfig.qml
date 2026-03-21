pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    readonly property int gap: _gap
    readonly property int cornerRadius: _cornerRadius
    property int _gap: 8
    property int _cornerRadius: 10

    Process {
        command: ["sh", "-c", "grep -m1 '^\\s*gaps ' ~/.config/niri/config.kdl | tr -dc '0-9'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim())
                if (!isNaN(val)) root._gap = val
            }
        }
    }

    Process {
        command: ["sh", "-c", "grep -m1 'geometry-corner-radius' ~/.config/niri/config.kdl | tr -dc '0-9'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim())
                if (!isNaN(val)) root._cornerRadius = val
            }
        }
    }
}
