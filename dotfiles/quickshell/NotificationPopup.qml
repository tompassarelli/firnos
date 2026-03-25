import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

PanelWindow {
    id: popup

    anchors {
        top: true
        right: true
    }
    margins {
        top: LayoutConfig.gap
        right: BarState.rightBarWidth + 2 * LayoutConfig.gap
    }

    implicitWidth: 210
    implicitHeight: notificationColumn.implicitHeight
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

            let replaced = false;

            // Replace existing notification with same ID or same transient app
            for (let i = 0; i < notificationModel.count; i++) {
                let existing = notificationModel.get(i).notif;
                if (existing.id === notification.id
                    || (notification.appName === "notify-send"
                        && existing.appName === "notify-send")) {
                    notificationModel.set(i, { notif: notification });
                    replaced = true;
                    break;
                }
            }

            if (!replaced)
                notificationModel.insert(0, { notif: notification });

            // Reset the shared transient timer for notify-send replacements
            if (notification.appName === "notify-send") {
                transientTimer.notifObj = notification;
                transientTimer.restart();
                return;
            }

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

    Timer {
        id: transientTimer
        property var notifObj: null
        interval: 2000
        repeat: false
        onTriggered: {
            if (!notifObj) return;
            for (let i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).notif === notifObj) {
                    notifObj.dismiss();
                    notificationModel.remove(i);
                    break;
                }
            }
            notifObj = null;
        }
    }

    Process {
        id: focusAppProc
        property var command: []
    }

    Column {
        id: notificationColumn
        anchors.fill: parent
        spacing: LayoutConfig.gap

        Repeater {
            model: notificationModel
            delegate: Rectangle {
                id: notifRect
                width: notificationColumn.width
                implicitHeight: Math.max(30, contentLayout.implicitHeight + 12)
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
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    anchors.topMargin: 6
                    anchors.bottomMargin: 6
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
                        visible: {
                            let acts = model.notif.actions;
                            for (let i = 0; i < acts.length; i++)
                                if (acts[i].identifier !== "default") return true;
                            return false;
                        }
                        Repeater {
                            model: {
                                let raw = notifRect.parent ? notificationModel.get(index)?.notif.actions ?? [] : [];
                                let filtered = [];
                                for (let i = 0; i < raw.length; i++)
                                    if (raw[i].identifier !== "default") filtered.push(raw[i]);
                                return filtered;
                            }
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
