import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Widgets

Scope {
    id: root

    property string currentPath: "/home"
    property var pathHistory: []
    property bool panelVisible: false

    signal fileSelected(string path)

    function show() {
        panelVisible = true;
    }

    function hide() {
        panelVisible = false;
    }

    function goBack() {
        if (pathHistory.length > 1) {
            pathHistory.pop();
            currentPath = pathHistory[pathHistory.length - 1];
            pathHistory = pathHistory.slice();
        }
    }

    function goToPath(path) {
        pathHistory.push(path);
        currentPath = path;
        pathHistory = pathHistory.slice();
    }

    function goHome() {
        currentPath = pathHistory[0];
        pathHistory = [currentPath];
    }

    Component.onCompleted: {
        const homeVar = Qt.application.arguments.find((arg) => {
            return arg.startsWith("HOME=");
        });
        if (homeVar)
            currentPath = homeVar.replace("HOME=", "");
        else
            currentPath = "/home";
        pathHistory = [currentPath];
    }

    PanelWindow {
        id: floatingPanel

        visible: root.panelVisible
        implicitWidth: 900
        implicitHeight: 620
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        color: "transparent"

        Shortcut {
            sequence: "Escape"
            onActivated: root.panelVisible = false
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 16
            color: Color.mSurface || "#1e1e1e"
            radius: 12
            border.width: 1
            border.color: Color.mOutline || "#3a3a3a"

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    color: Color.mSurfaceVariant || "#2a2a2a"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Color.mOutlineVariant || "#3a3a3a"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 8

                        // Back
                        Button {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            enabled: root.pathHistory.length > 1
                            opacity: enabled ? 1 : 0.3
                            onClicked: root.goBack()

                            background: Rectangle {
                                color: parent.enabled && parent.hovered ? (Color.mSurfaceVariant || "#3a3a3a") : "transparent"
                                radius: 6
                            }

                            contentItem: Text {
                                text: "←"
                                color: Color.mOnSurface || "#e0e0e0"
                                font.pixelSize: 18
                                font.family: "monospace"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 24
                            color: Color.mOutlineVariant || "#3a3a3a"
                        }

                        // Path bar
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: Color.mSurface || "#252525"
                            radius: 6
                            border.width: 1
                            border.color: Color.mOutlineVariant || "#3a3a3a"

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                text: root.currentPath || ""
                                color: Color.mOnSurface || "#e0e0e0"
                                font.family: "monospace"
                                font.pixelSize: 13
                                elide: Text.ElideMiddle
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 24
                            color: Color.mOutlineVariant || "#3a3a3a"
                        }

                        // Home
                        Button {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            onClicked: root.goHome()

                            background: Rectangle {
                                color: parent.hovered ? (Color.mSurfaceVariant || "#3a3a3a") : "transparent"
                                radius: 6
                            }

                            contentItem: Text {
                                text: "~"
                                color: Color.mOnSurface || "#e0e0e0"
                                font.pixelSize: 18
                                font.family: "monospace"
                                font.weight: Font.Bold
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                        // Close
                        Button {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            onClicked: root.panelVisible = false

                            background: Rectangle {
                                color: parent.hovered ? (Color.mError || "#dc3545") : "transparent"
                                radius: 6
                            }

                            contentItem: Text {
                                text: "×"
                                color: parent.parent.hovered ? "#ffffff" : (Color.mOnSurface || "#e0e0e0")
                                font.pixelSize: 24
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                        }

                    }

                }

                // File grid
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    Flickable {
                        contentWidth: gridContainer.width
                        contentHeight: gridContainer.height

                        Item {
                            id: gridContainer

                            width: Math.max(parent.parent.width, gridFlow.width)
                            height: gridFlow.height + 48

                            Flow {
                                id: gridFlow

                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 24
                                width: {
                                    var cols = Math.floor((parent.width - 48) / 200);
                                    if (cols < 1)
                                        cols = 1;

                                    return cols * 200;
                                }
                                spacing: 20

                                Repeater {
                                    model: folderModel

                                    delegate: Item {
                                        width: 180
                                        height: 200

                                        Rectangle {
                                            anchors.fill: parent
                                            color: "transparent"
                                            scale: itemMouse.pressed ? 0.96 : 1

                                            ColumnLayout {
                                                anchors.fill: parent
                                                spacing: 8

                                                // Thumbnail / folder icon
                                                Rectangle {
                                                    Layout.preferredWidth: 180
                                                    Layout.preferredHeight: 140
                                                    color: Color.mSurfaceVariant || "#2a2a2a"
                                                    radius: 8
                                                    clip: true

                                                    // Folder icon
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "📁"
                                                        font.pixelSize: 52
                                                        visible: model.fileIsDir
                                                    }

                                                    // Image thumbnail
                                                    Image {
                                                        anchors.fill: parent
                                                        source: !model.fileIsDir ? ("file://" + model.filePath) : ""
                                                        visible: !model.fileIsDir
                                                        fillMode: Image.PreserveAspectCrop
                                                        smooth: true
                                                        asynchronous: true
                                                        opacity: status === Image.Ready ? 1 : 0

                                                        Behavior on opacity {
                                                            NumberAnimation {
                                                                duration: 200
                                                            }

                                                        }

                                                    }

                                                    // Loading indicator
                                                    Text {
                                                        anchors.centerIn: parent
                                                        text: "…"
                                                        color: Color.mOnSurfaceVariant || "#888"
                                                        font.pixelSize: 24
                                                        visible: !model.fileIsDir && parent.children[1].status === Image.Loading
                                                    }

                                                    // Format badge
                                                    Rectangle {
                                                        anchors.right: parent.right
                                                        anchors.bottom: parent.bottom
                                                        anchors.margins: 6
                                                        width: fileTypeText.width + 12
                                                        height: 20
                                                        color: "#cc000000"
                                                        radius: 4
                                                        visible: !model.fileIsDir

                                                        Text {
                                                            id: fileTypeText

                                                            anchors.centerIn: parent
                                                            text: {
                                                                const fileName = model.fileName || "";
                                                                const ext = fileName.split('.').pop().toUpperCase();
                                                                return ext || "IMG";
                                                            }
                                                            color: "#ffffff"
                                                            font.family: "monospace"
                                                            font.pixelSize: 10
                                                            font.weight: Font.Bold
                                                        }

                                                    }

                                                }

                                                // Filename
                                                Text {
                                                    Layout.preferredWidth: 180
                                                    Layout.preferredHeight: 40
                                                    text: model.fileName || ""
                                                    color: Color.mOnSurface || "#e0e0e0"
                                                    font.family: "sans-serif"
                                                    font.pixelSize: 12
                                                    font.weight: model.fileIsDir ? Font.Medium : Font.Normal
                                                    elide: Text.ElideMiddle
                                                    wrapMode: Text.Wrap
                                                    maximumLineCount: 2
                                                    horizontalAlignment: Text.AlignHCenter
                                                    verticalAlignment: Text.AlignTop
                                                }

                                            }

                                            MouseArea {
                                                id: itemMouse

                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (model.fileIsDir) {
                                                        root.goToPath(model.filePath);
                                                    } else {
                                                        root.fileSelected(model.filePath);
                                                        root.panelVisible = false;
                                                    }
                                                }
                                            }

                                            Behavior on scale {
                                                NumberAnimation {
                                                    duration: 80
                                                }

                                            }

                                        }

                                    }

                                }

                            }

                        }

                    }

                }

                // Footer
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: Color.mSurfaceVariant || "#2a2a2a"

                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Color.mOutlineVariant || "#3a3a3a"
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 16

                        Text {
                            text: {
                                let images = 0;
                                let dirs = 0;
                                for (let i = 0; i < folderModel.count; i++) {
                                    if (folderModel.get(i, "fileIsDir"))
                                        dirs++;
                                    else
                                        images++;
                                }
                                return images + " images · " + dirs + " folders";
                            }
                            color: Color.mOnSurfaceVariant || "#888888"
                            font.family: "sans-serif"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Click image to select · Click folder to open"
                            color: Color.mOnSurfaceVariant || "#666666"
                            font.family: "sans-serif"
                            font.pixelSize: 11
                            opacity: 0.7
                        }
                    }
                }
            }
        }
    }

    FolderListModel {
        id: folderModel

        folder: root.currentPath ? ("file://" + root.currentPath) : ""
        nameFilters: ["*.png", "*.PNG", "*.jpg", "*.JPG", "*.jpeg", "*.JPEG", "*.svg", "*.SVG", "*.webp", "*.WEBP", "*.gif", "*.GIF"]
        showDirs: true
        showDotAndDotDot: false
        showHidden: false
        sortField: FolderListModel.Name
    }

}
