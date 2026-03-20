import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    StylixColors { id: colors }

    property bool barVisible: false
    property int lastWorkspaceId: -1

    ListModel { id: workspaceModel }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: barVisible = false
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
                            barVisible = true
                        } else {
                            hideTimer.restart()
                        }
                    }

                    if ("WorkspaceActivated" in event) {
                        const wa = event.WorkspaceActivated
                        if (wa.focused) {
                            for (let i = 0; i < workspaceModel.count; i++) {
                                workspaceModel.setProperty(i, "isActive", workspaceModel.get(i).wsId === wa.id)
                            }
                            if (lastWorkspaceId !== -1 && wa.id !== lastWorkspaceId) {
                                barVisible = true
                                hideTimer.restart()
                            }
                            lastWorkspaceId = wa.id
                        }
                    }

                    if ("WorkspacesChanged" in event) {
                        const workspaces = event.WorkspacesChanged.workspaces
                        workspaces.sort((a, b) => a.idx - b.idx)
                        workspaceModel.clear()
                        for (const ws of workspaces) {
                            workspaceModel.append({
                                wsId: ws.id,
                                idx: ws.idx,
                                name: ws.name || "",
                                isActive: ws.is_focused
                            })
                        }
                        const focused = workspaces.find(w => w.is_focused)
                        if (focused && lastWorkspaceId === -1)
                            lastWorkspaceId = focused.id
                    }
                } catch(e) {}
            }
        }
    }

    Rectangle {
        id: barRect
        anchors.fill: parent
        color: Qt.rgba(colors.base00.r, colors.base00.g, colors.base00.b, 0.7)
        opacity: barVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13

            Item {
                Layout.fillWidth: true

                Text {
                    id: clock
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: colors.base05
                    font.family: colors.fontFamily
                    font.pointSize: 10

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: clock.text = Qt.formatDateTime(new Date(), "dddd h:mm AP")
                    }
                }
            }

            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Repeater {
                    model: workspaceModel

                    Text {
                        color: model.isActive ? colors.base05 : colors.base03
                        font.family: colors.fontFamily
                        font.pointSize: 10
                        text: model.name || String(model.idx)
                    }
                }
            }

            Item {
                Layout.fillWidth: true

                Text {
                    id: batteryText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    color: colors.base05
                    font.family: colors.fontFamily
                    font.pointSize: 10

                Timer {
                    interval: 5000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: batteryProc.running = true
                }

                Process {
                    id: batteryProc
                    command: ["cat", "/sys/class/power_supply/BAT1/capacity"]
                    stdout: SplitParser {
                        onRead: data => batteryText.text = data.trim() + "%"
                    }
                }
                }
            }
        }
    }
}
