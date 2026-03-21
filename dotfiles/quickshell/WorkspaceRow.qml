import QtQuick

Row {
    spacing: 0

    StylixColors { id: colors }

    Repeater {
        model: BarState.workspaceModel

        Row {
            spacing: 0

            Text {
                visible: model.index > 0
                anchors.verticalCenter: parent.verticalCenter
                color: colors.base03
                font.family: colors.fontFamily
                font.pointSize: 9
                text: " / "
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: wsText.implicitWidth + 16
                height: wsText.implicitHeight + 6
                radius: 4
                color: model.isActive ? colors.base0B : "transparent"

                Text {
                    id: wsText
                    anchors.centerIn: parent
                    color: model.isActive ? colors.base00 : colors.base04
                    font.family: colors.fontFamily
                    font.pointSize: 10
                    text: {
                        let label = String(model.idx)
                        if (model.name) label += "  " + model.name
                        return label
                    }
                }
            }
        }
    }
}
