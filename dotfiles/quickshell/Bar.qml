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

    property bool barVisible: false
    property int lastWorkspaceId: -1

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
                            if (lastWorkspaceId !== -1 && wa.id !== lastWorkspaceId) {
                                barVisible = true
                                hideTimer.restart()
                            }
                            lastWorkspaceId = wa.id
                        }
                    }

                    if ("WorkspacesChanged" in event) {
                        const focused = event.WorkspacesChanged.workspaces.find(w => w.is_focused)
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
        color: Qt.rgba(0, 0, 0, 0.7)
        opacity: barVisible ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 300 }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 13
            anchors.rightMargin: 13

            Text {
                id: clock
                color: "#d4d4d4"
                font.family: "monospace"
                font.pointSize: 10

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    triggeredOnStart: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "dddd h:mm AP")
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                color: "#d4d4d4"
                font.family: "monospace"
                font.pointSize: 10
                text: "⬤"
            }

            Item { Layout.fillWidth: true }

            Text {
                id: batteryText
                color: "#d4d4d4"
                font.family: "monospace"
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
