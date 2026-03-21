pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property int lastWorkspaceId: -1

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: BarState.workspaceSwitchActive = false
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
                            BarState.workspaceSwitchActive = false
                            BarState.overviewOpen = true
                        } else {
                            BarState.overviewOpen = false
                        }
                    }

                    if ("WorkspaceActivated" in event) {
                        const wa = event.WorkspaceActivated
                        if (wa.focused) {
                            for (let i = 0; i < BarState.workspaceModel.count; i++) {
                                const ws = BarState.workspaceModel.get(i)
                                BarState.workspaceModel.setProperty(i, "isActive", ws.wsId === wa.id)
                            }
                            if (root.lastWorkspaceId !== -1 && wa.id !== root.lastWorkspaceId && !BarState.overviewOpen) {
                                BarState.workspaceSwitchActive = true
                                hideTimer.restart()
                            }
                            root.lastWorkspaceId = wa.id
                        }
                    }

                    if ("WorkspacesChanged" in event) {
                        const workspaces = event.WorkspacesChanged.workspaces
                        workspaces.sort((a, b) => a.idx - b.idx)
                        BarState.workspaceModel.clear()
                        for (const ws of workspaces) {
                            BarState.workspaceModel.append({
                                wsId: ws.id,
                                idx: ws.idx,
                                name: ws.name || "",
                                isActive: ws.is_focused
                            })
                        }
                        const focused = workspaces.find(w => w.is_focused)
                        if (focused && root.lastWorkspaceId === -1)
                            root.lastWorkspaceId = focused.id
                    }
                } catch(e) {}
            }
        }
    }
}
