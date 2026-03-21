pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property bool overviewOpen: false
    property bool workspaceSwitchActive: false
    property ListModel workspaceModel: ListModel {}

    Timer {
        id: peekTimer
        interval: 1000
        onTriggered: workspaceSwitchActive = false
    }

    IpcHandler {
        target: "bar"

        function peek(): void {
            workspaceSwitchActive = true
            peekTimer.restart()
        }
    }
}
