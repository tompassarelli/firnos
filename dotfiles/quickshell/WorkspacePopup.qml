import QtQuick
import Quickshell
import Quickshell.Wayland

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
    visible: BarState.workspaceSwitchActive && !BarState.overviewOpen

    StylixColors { id: colors }

    Rectangle {
        anchors.fill: parent
        radius: LayoutConfig.cornerRadius
        color: colors.base00

        WorkspaceRow {
            id: workspaceRow
            anchors.left: parent.left
            anchors.leftMargin: 13
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
