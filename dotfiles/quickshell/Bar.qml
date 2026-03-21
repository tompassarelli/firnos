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

    margins {
        top: LayoutConfig.gap
        left: LayoutConfig.gap
        right: LayoutConfig.gap
    }

    implicitHeight: 30
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    mask: Region {
        regions: BarState.overviewOpen ? [leftMask, rightMask] : []
    }
    Region { id: leftMask; item: leftRect }
    Region { id: rightMask; item: rightRect }

    StylixColors { id: colors }

    Item {
        anchors.fill: parent
        opacity: BarState.overviewOpen ? 1 : 0

        Rectangle {
            id: leftRect
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: workspaceRow.implicitWidth + 26
            radius: LayoutConfig.cornerRadius
            color: Qt.rgba(colors.base00.r, colors.base00.g, colors.base00.b, 0.7)

            WorkspaceRow {
                id: workspaceRow
                anchors.left: parent.left
                anchors.leftMargin: 13
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            id: rightRect
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: statusRow.implicitWidth + 26
            radius: LayoutConfig.cornerRadius
            color: Qt.rgba(colors.base00.r, colors.base00.g, colors.base00.b, 0.7)

            Row {
                id: statusRow
                anchors.right: parent.right
                anchors.rightMargin: 13
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Text {
                    id: clock
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

                Text {
                    id: wifiText
                    anchors.verticalCenter: parent.verticalCenter
                    color: colors.base05
                    font.family: colors.fontFamily
                    font.pointSize: 10

                    Timer {
                        interval: 5000
                        running: true
                        repeat: true
                        triggeredOnStart: true
                        onTriggered: wifiProc.running = true
                    }

                    Process {
                        id: wifiProc
                        command: ["nmcli", "-t", "-f", "SIGNAL,ACTIVE,SSID", "dev", "wifi"]
                        stdout: SplitParser {
                            onRead: data => {
                                const parts = data.split(":")
                                if (parts[1] === "yes") {
                                    wifiText.text = "\u{f0928} " + parts[0] + "%"
                                }
                            }
                        }
                        onExited: (code, status) => {
                            if (code !== 0) wifiText.text = "\u{f092d}"
                        }
                    }
                }

                Text {
                    id: batteryText
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
                            onRead: data => batteryText.text = "\u{f0079} " + data.trim() + "%"
                        }
                    }
                }
            }
        }
    }
}
