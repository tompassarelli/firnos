pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    property bool overviewOpen: false
    property bool workspaceSwitchActive: false
    property ListModel workspaceModel: ListModel {}

    IpcHandler {
        target: "bar"

        function peek(): void {
            workspaceSwitchActive = true
        }
    }
}
