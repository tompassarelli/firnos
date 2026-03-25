pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property bool overviewOpen: false
    property bool workspaceSwitchActive: false
    property ListModel workspaceModel: ListModel {}
    property real rightBarWidth: 0

    IpcHandler {
        target: "bar"

        function peek(): void {
            workspaceSwitchActive = true
        }
    }
}
