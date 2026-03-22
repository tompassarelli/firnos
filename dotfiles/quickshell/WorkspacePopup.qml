import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: popup

    anchors {
        top: true
        left: true
    }
    margins {
        top: LayoutConfig.gap
        left: LayoutConfig.gap
    }

    implicitWidth: workspaceRow.implicitWidth + 26
    implicitHeight: 30

    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: contentRect.opacity > 0

    StylixColors { id: colors }

    Process {
        id: keyReleaseMonitor
        running: BarState.workspaceSwitchActive
        command: ["python3", Qt.resolvedUrl("key-release-monitor.py").toString().replace("file://", "")]
        stdout: SplitParser {
            onRead: data => {
                BarState.workspaceSwitchActive = false
            }
        }
    }

    Rectangle {
        id: contentRect
        anchors.fill: parent
        radius: LayoutConfig.cornerRadius
        color: colors.base00
        opacity: BarState.workspaceSwitchActive && !BarState.overviewOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        WorkspaceRow {
            id: workspaceRow
            anchors.left: parent.left
            anchors.leftMargin: 13
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
