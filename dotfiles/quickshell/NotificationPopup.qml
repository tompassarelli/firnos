import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

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

    implicitWidth: 350
    implicitHeight: notificationColumn.implicitHeight + 2 * LayoutConfig.gap
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: notificationModel.count > 0

    StylixColors { id: colors }

    NotificationServer {
        id: notifServer
        bodySupported: true
        actionsSupported: true
        imageSupported: false
        persistenceSupported: false

        onNotification: notification => {
            // Suppress Spotify track change notifications
            if (notification.appName === "Spotify") {
                notification.tracked = false;
                return;
            }

            notification.tracked = true;

            // Replace existing notification with same ID
            for (let i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).notif.id === notification.id) {
                    notificationModel.set(i, { notif: notification });
                    return;
                }
            }

            notificationModel.insert(0, { notif: notification });

            // Auto-dismiss after 5 seconds unless timeout is 0 (sticky)
            let timeout = notification.expireTimeout;
            if (timeout < 0) timeout = 5000;
            if (timeout > 0) {
                dismissTimer.createObject(popup, {
                    interval: timeout,
                    notifObj: notification
                });
            }
        }
    }

    Component {
        id: dismissTimer
        Timer {
            property var notifObj
            running: true
            repeat: false
            onTriggered: {
                for (let i = 0; i < notificationModel.count; i++) {
                    if (notificationModel.get(i).notif === notifObj) {
                        notifObj.dismiss();
                        notificationModel.remove(i);
                        break;
                    }
                }
                destroy();
            }
        }
    }

    ListModel {
        id: notificationModel
    }

    Process {
        id: focusAppProc
        property var command: []
    }

    Column {
        id: notificationColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: LayoutConfig.gap
        spacing: LayoutConfig.gap

        Repeater {
            model: notificationModel
            delegate: Rectangle {
                id: notifRect
                width: notificationColumn.width
                implicitHeight: contentLayout.implicitHeight + 20
                radius: LayoutConfig.cornerRadius
                color: Qt.rgba(colors.base00.r, colors.base00.g, colors.base00.b, 0.9)

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let n = model.notif;
                        // Invoke default action if available
                        for (let i = 0; i < n.actions.length; i++) {
                            if (n.actions[i].identifier === "default") {
                                n.actions[i].invoke();
                                notificationModel.remove(index);
                                return;
                            }
                        }
                        // Otherwise try to focus the app that sent the notification
                        if (n.appName !== "") {
                            focusAppProc.command = ["niri", "msg", "action", "focus-window", "--app-id", n.appName.toLowerCase()];
                            focusAppProc.running = true;
                        }
                        n.dismiss();
                        notificationModel.remove(index);
                    }
                }

                ColumnLayout {
                    id: contentLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: model.notif.summary
                            color: colors.base05
                            font.family: colors.fontFamily
                            font.pointSize: 10
                            font.bold: true
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.notif.appName
                            color: colors.base04
                            font.family: colors.fontFamily
                            font.pointSize: 8
                        }

                        Text {
                            text: "\u{f0156}"
                            color: colors.base04
                            font.family: colors.fontFamily
                            font.pointSize: 10

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    model.notif.dismiss();
                                    notificationModel.remove(index);
                                }
                            }
                        }
                    }

                    Text {
                        text: model.notif.body
                        color: colors.base04
                        font.family: colors.fontFamily
                        font.pointSize: 9
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        visible: text !== ""
                    }

                    Row {
                        spacing: 8
                        visible: model.notif.actions.length > 0
                        Repeater {
                            model: notifRect.parent ? notificationModel.get(index)?.notif.actions ?? [] : []
                            delegate: Rectangle {
                                width: actionText.implicitWidth + 16
                                height: actionText.implicitHeight + 8
                                radius: LayoutConfig.cornerRadius / 2
                                color: colors.base02

                                Text {
                                    id: actionText
                                    anchors.centerIn: parent
                                    text: modelData.text
                                    color: colors.base05
                                    font.family: colors.fontFamily
                                    font.pointSize: 8
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: modelData.invoke()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
