pragma Singleton
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

Singleton {
    property bool overviewOpen: false
    property bool workspaceSwitchActive: false
    property ListModel workspaceModel: ListModel {}
    property real rightBarWidth: 0
    property bool pinned: true

    // Current notification to show inline in bar
    property string notifSummary: ""
    property string notifBody: ""
    property string notifAppName: ""
    property var notifActions: []
    property var notifObj: null
    property bool notifVisible: false

    IpcHandler {
        target: "bar"

        function peek(): void {
            workspaceSwitchActive = true
        }
    }

    NotificationServer {
        id: notifServer
        bodySupported: true
        actionsSupported: true
        imageSupported: false
        persistenceSupported: false

        onNotification: notification => {
            // Suppress Spotify
            if (notification.appName === "Spotify") {
                notification.tracked = false;
                return;
            }

            notification.tracked = true;

            notifSummary = notification.summary;
            notifBody = notification.body;
            notifAppName = notification.appName;
            notifActions = notification.actions;
            notifObj = notification;
            notifVisible = true;

            // Auto-dismiss
            let timeout = notification.expireTimeout;
            if (timeout < 0) timeout = 5000;
            if (notification.appName === "notify-send") timeout = 2000;
            if (timeout > 0) {
                dismissTimer.interval = timeout;
                dismissTimer.restart();
            }
        }
    }

    Timer {
        id: dismissTimer
        repeat: false
        onTriggered: {
            if (notifObj) notifObj.dismiss();
            notifVisible = false;
            notifObj = null;
        }
    }

    function dismissNotification() {
        dismissTimer.stop();
        if (notifObj) notifObj.dismiss();
        notifVisible = false;
        notifObj = null;
    }

    function invokeDefaultAction() {
        if (!notifObj) return;
        for (let i = 0; i < notifActions.length; i++) {
            if (notifActions[i].identifier === "default") {
                notifActions[i].invoke();
                dismissNotification();
                return;
            }
        }
        // Focus the app
        if (notifAppName !== "") {
            focusProc.command = ["niri", "msg", "action", "focus-window", "--app-id", notifAppName.toLowerCase()];
            focusProc.running = true;
        }
        dismissNotification();
    }

    Process {
        id: focusProc
        property var command: []
    }
}
