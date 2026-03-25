import Quickshell
import QtQuick

ShellRoot {
    // Force lazy singletons to instantiate
    property var _niriListener: NiriListener
    property var _layoutConfig: LayoutConfig

    Bar {}
    WorkspacePopup {}
    NotificationPopup {}
}
