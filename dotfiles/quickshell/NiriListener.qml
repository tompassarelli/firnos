import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int lastWorkspaceId: -1

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: BarState.visible = false
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    const event = JSON.parse(data)

                    if ("OverviewOpenedOrClosed" in event) {
                        if (event.OverviewOpenedOrClosed.is_open) {
                            hideTimer.stop()
                            BarState.visible = true
                        } else {
                            hideTimer.restart()
                        }
                    }

                    if ("WorkspaceActivated" in event) {
                        const wa = event.WorkspaceActivated
                        if (wa.focused) {
                            if (root.lastWorkspaceId !== -1 && wa.id !== root.lastWorkspaceId) {
                                BarState.visible = true
                                hideTimer.restart()
                            }
                            root.lastWorkspaceId = wa.id
                        }
                    }

                    if ("WorkspacesChanged" in event) {
                        const focused = event.WorkspacesChanged.workspaces.find(w => w.is_focused)
                        if (focused && root.lastWorkspaceId === -1)
                            root.lastWorkspaceId = focused.id
                    }
                } catch(e) {}
            }
        }
    }
}
