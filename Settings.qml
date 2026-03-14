import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi
    property var _pickerCallback: null

    function save() {
        pluginApi.pluginSettings.iconActive = pluginApi.pluginSettings.iconActive;
        pluginApi.pluginSettings.iconUrgent = pluginApi.pluginSettings.iconUrgent;
        pluginApi.pluginSettings.iconNearby = pluginApi.pluginSettings.iconNearby;
        pluginApi.pluginSettings.iconFar = pluginApi.pluginSettings.iconFar;
        pluginApi.saveSettings();
    }

    spacing: Style.marginM || 16
    Component.onCompleted: {
        if (!pluginApi.pluginSettings.iconActive)
            pluginApi.pluginSettings.iconActive = "";

        if (!pluginApi.pluginSettings.iconUrgent)
            pluginApi.pluginSettings.iconUrgent = "";

        if (!pluginApi.pluginSettings.iconNearby)
            pluginApi.pluginSettings.iconNearby = "";

        if (!pluginApi.pluginSettings.iconFar)
            pluginApi.pluginSettings.iconFar = "";

        if (pluginApi.pluginSettings.workspaceDisplayMode === undefined)
            pluginApi.pluginSettings.workspaceDisplayMode = "all";

        if (pluginApi.pluginSettings.sizeFocused === undefined)
            pluginApi.pluginSettings.sizeFocused = 1.7;

        if (pluginApi.pluginSettings.sizeUrgent === undefined)
            pluginApi.pluginSettings.sizeUrgent = 1.5;

        if (pluginApi.pluginSettings.sizeOccupied === undefined)
            pluginApi.pluginSettings.sizeOccupied = 1.4;

        if (pluginApi.pluginSettings.sizeEmpty === undefined)
            pluginApi.pluginSettings.sizeEmpty = 1.2;

        if (pluginApi.pluginSettings.glowSize === undefined)
            pluginApi.pluginSettings.glowSize = 2.2;
        if (pluginApi.pluginSettings.glowOpacity === undefined)
            pluginApi.pluginSettings.glowOpacity = 0.50;
        if (pluginApi.pluginSettings.glowBlur === undefined)
            pluginApi.pluginSettings.glowBlur = 1.0;
        if (pluginApi.pluginSettings.glowBlurMax === undefined)
            pluginApi.pluginSettings.glowBlurMax = 32;

        if (pluginApi.pluginSettings.urgentGlowSize === undefined)
            pluginApi.pluginSettings.urgentGlowSize = 2.2;
        if (pluginApi.pluginSettings.urgentGlowOpacity === undefined)
            pluginApi.pluginSettings.urgentGlowOpacity = 0.50;
        if (pluginApi.pluginSettings.urgentGlowBlur === undefined)
            pluginApi.pluginSettings.urgentGlowBlur = 1.0;
        if (pluginApi.pluginSettings.urgentGlowBlurMax === undefined)
            pluginApi.pluginSettings.urgentGlowBlurMax = 32;

        pluginApi.saveSettings();
    }

    NLabel {
        label: "🌙 Ranni Moon Workspaces"
        description: "Customize each workspace state. Type an emoji, or click Browse to pick an image or SVG. Leave empty for defaults."
    }

    NLabel {
        label: "Workspace visibility"
        description: "Choose which workspace pills to show in the bar."
    }

    // Segmented pill selector
    Rectangle {
        Layout.fillWidth: true
        height: 40
        radius: 10
        color: Color.mSurfaceVariant || "#0E1428"
        border.color: Color.mOutline || "#9DBCF5"
        border.width: 1

        readonly property var modes: [
            { value: "all",             icon: "", label: "All" },
            { value: "active-occupied", icon: "", label: "Active" },
            { value: "once",            icon: "", label: "+ 1 empty" }
        ]

        RowLayout {
            anchors.fill: parent
            anchors.margins: 4
            spacing: 4

            Repeater {
                model: parent.parent.modes

                delegate: Rectangle {
                    id: seg
                    readonly property bool active: pluginApi.pluginSettings.workspaceDisplayMode === modelData.value
                    readonly property bool hov: segMa.containsMouse

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 7
                    color: active ? (Color.mPrimary || "#9DBCF5")
                                  : hov    ? (Color.mHover   || "#2A3355")
                                           : "transparent"

                    Behavior on color { ColorAnimation { duration: 140 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: modelData.icon
                            font.pixelSize: 13
                            color: seg.active ? (Color.mOnPrimary || "#10131c") : (Color.mOnSurfaceVariant || "#A9B7E6")
                            Behavior on color { ColorAnimation { duration: 140 } }
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: 12
                            font.weight: seg.active ? Font.DemiBold : Font.Normal
                            color: seg.active ? (Color.mOnPrimary || "#10131c") : (Color.mOnSurfaceVariant || "#A9B7E6")
                            Behavior on color { ColorAnimation { duration: 140 } }
                        }
                    }

                    MouseArea {
                        id: segMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            pluginApi.pluginSettings.workspaceDisplayMode = modelData.value
                            pluginApi.saveSettings()
                        }
                    }
                }
            }
        }
    }

    // Focused
    NLabel {
        label: "Focused — you are here"
        description: "Default: 🌕  Full moon"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            width: 38
            height: 38
            radius: 6
            color: Color.mSurfaceVariant || "#2a2a2a"
            border.color: Color.mOutline || "#3a3a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: (pluginApi.pluginSettings.iconActive || "").startsWith("/") ? "" : (pluginApi.pluginSettings.iconActive || "🌕")
                font.pixelSize: 22
                visible: !(pluginApi.pluginSettings.iconActive || "").startsWith("/")
            }

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: (pluginApi.pluginSettings.iconActive || "").startsWith("/") ? ("file://" + pluginApi.pluginSettings.iconActive) : ""
                visible: (pluginApi.pluginSettings.iconActive || "").startsWith("/")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

        }

        TextField {
            id: fieldActive

            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: pluginApi.pluginSettings.iconActive || ""
            placeholderText: "emoji or /path/to/image.png"
            color: Color.mPrimary || "#9DBCF5"
            placeholderTextColor: Color.mOnSurfaceVariant || "#A9B7E6"
            font.pixelSize: 13
            onEditingFinished: {
                pluginApi.pluginSettings.iconActive = text;
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.activeFocus ? (Color.mSurfaceVariant || "#333") : (Color.mSurface || "#1e1e1e")
                radius: 6
                border.width: 1
                border.color: parent.activeFocus ? (Color.mPrimary || "#4fc3f7") : (Color.mOutline || "#3a3a3a")

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "Browse…"
            onClicked: {
                root._pickerCallback = function(p) {
                    pluginApi.pluginSettings.iconActive = p;
                    fieldActive.text = p;
                    pluginApi.saveSettings();
                };
                picker.show();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mPrimary || "#4fc3f7") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#fff" : (Color.mOnSurface || "#e0e0e0")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "✕"
            visible: (pluginApi.pluginSettings.iconActive || "").startsWith("/")
            onClicked: {
                pluginApi.pluginSettings.iconActive = "";
                fieldActive.text = "";
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mErrorContainer || "#5c1a1a") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: Color.mOnSurface || "#e0e0e0"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

    }

    // Urgent
    NLabel {
        label: "Urgent — new activity from elsewhere"
        description: "Default: 🌟  Star (pulses gold)"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            width: 38
            height: 38
            radius: 6
            color: Color.mSurfaceVariant || "#2a2a2a"
            border.color: Color.mOutline || "#3a3a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: (pluginApi.pluginSettings.iconUrgent || "").startsWith("/") ? "" : (pluginApi.pluginSettings.iconUrgent || "🌟")
                font.pixelSize: 22
                visible: !(pluginApi.pluginSettings.iconUrgent || "").startsWith("/")
            }

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: (pluginApi.pluginSettings.iconUrgent || "").startsWith("/") ? ("file://" + pluginApi.pluginSettings.iconUrgent) : ""
                visible: (pluginApi.pluginSettings.iconUrgent || "").startsWith("/")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

        }

        TextField {
            id: fieldUrgent

            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: pluginApi.pluginSettings.iconUrgent || ""
            placeholderText: "emoji or /path/to/image.png"
            color: Color.mPrimary || "#9DBCF5"
            placeholderTextColor: Color.mOnSurfaceVariant || "#A9B7E6"
            font.pixelSize: 13
            onEditingFinished: {
                pluginApi.pluginSettings.iconUrgent = text;
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.activeFocus ? (Color.mSurfaceVariant || "#333") : (Color.mSurface || "#1e1e1e")
                radius: 6
                border.width: 1
                border.color: parent.activeFocus ? (Color.mPrimary || "#4fc3f7") : (Color.mOutline || "#3a3a3a")

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "Browse…"
            onClicked: {
                root._pickerCallback = function(p) {
                    pluginApi.pluginSettings.iconUrgent = p;
                    fieldUrgent.text = p;
                    pluginApi.saveSettings();
                };
                picker.show();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mPrimary || "#4fc3f7") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#fff" : (Color.mOnSurface || "#e0e0e0")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "✕"
            visible: (pluginApi.pluginSettings.iconUrgent || "").startsWith("/")
            onClicked: {
                pluginApi.pluginSettings.iconUrgent = "";
                fieldUrgent.text = "";
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mErrorContainer || "#5c1a1a") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: Color.mOnSurface || "#e0e0e0"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

    }

    // Occupied
    NLabel {
        label: "Occupied — has windows, not focused"
        description: "Default: 🌗  Half moon"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            width: 38
            height: 38
            radius: 6
            color: Color.mSurfaceVariant || "#2a2a2a"
            border.color: Color.mOutline || "#3a3a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: (pluginApi.pluginSettings.iconNearby || "").startsWith("/") ? "" : (pluginApi.pluginSettings.iconNearby || "🌗")
                font.pixelSize: 22
                visible: !(pluginApi.pluginSettings.iconNearby || "").startsWith("/")
            }

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: (pluginApi.pluginSettings.iconNearby || "").startsWith("/") ? ("file://" + pluginApi.pluginSettings.iconNearby) : ""
                visible: (pluginApi.pluginSettings.iconNearby || "").startsWith("/")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

        }

        TextField {
            id: fieldNearby

            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: pluginApi.pluginSettings.iconNearby || ""
            placeholderText: "emoji or /path/to/image.png"
            color: Color.mPrimary || "#9DBCF5"
            placeholderTextColor: Color.mOnSurfaceVariant || "#A9B7E6"
            font.pixelSize: 13
            onEditingFinished: {
                pluginApi.pluginSettings.iconNearby = text;
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.activeFocus ? (Color.mSurfaceVariant || "#333") : (Color.mSurface || "#1e1e1e")
                radius: 6
                border.width: 1
                border.color: parent.activeFocus ? (Color.mPrimary || "#4fc3f7") : (Color.mOutline || "#3a3a3a")

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "Browse…"
            onClicked: {
                root._pickerCallback = function(p) {
                    pluginApi.pluginSettings.iconNearby = p;
                    fieldNearby.text = p;
                    pluginApi.saveSettings();
                };
                picker.show();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mPrimary || "#4fc3f7") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#fff" : (Color.mOnSurface || "#e0e0e0")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "✕"
            visible: (pluginApi.pluginSettings.iconNearby || "").startsWith("/")
            onClicked: {
                pluginApi.pluginSettings.iconNearby = "";
                fieldNearby.text = "";
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mErrorContainer || "#5c1a1a") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: Color.mOnSurface || "#e0e0e0"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

    }

    // Empty
    NLabel {
        label: "Empty — no windows"
        description: "Default: 🌙  Crescent moon"
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Rectangle {
            width: 38
            height: 38
            radius: 6
            color: Color.mSurfaceVariant || "#2a2a2a"
            border.color: Color.mOutline || "#3a3a3a"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: (pluginApi.pluginSettings.iconFar || "").startsWith("/") ? "" : (pluginApi.pluginSettings.iconFar || "🌙")
                font.pixelSize: 22
                visible: !(pluginApi.pluginSettings.iconFar || "").startsWith("/")
            }

            Image {
                anchors.fill: parent
                anchors.margins: 4
                source: (pluginApi.pluginSettings.iconFar || "").startsWith("/") ? ("file://" + pluginApi.pluginSettings.iconFar) : ""
                visible: (pluginApi.pluginSettings.iconFar || "").startsWith("/")
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

        }

        TextField {
            id: fieldFar

            Layout.fillWidth: true
            Layout.preferredHeight: 38
            text: pluginApi.pluginSettings.iconFar || ""
            placeholderText: "emoji or /path/to/image.png"
            color: Color.mPrimary || "#9DBCF5"
            placeholderTextColor: Color.mOnSurfaceVariant || "#A9B7E6"
            font.pixelSize: 13
            onEditingFinished: {
                pluginApi.pluginSettings.iconFar = text;
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.activeFocus ? (Color.mSurfaceVariant || "#333") : (Color.mSurface || "#1e1e1e")
                radius: 6
                border.width: 1
                border.color: parent.activeFocus ? (Color.mPrimary || "#4fc3f7") : (Color.mOutline || "#3a3a3a")

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "Browse…"
            onClicked: {
                root._pickerCallback = function(p) {
                    pluginApi.pluginSettings.iconFar = p;
                    fieldFar.text = p;
                    pluginApi.saveSettings();
                };
                picker.show();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mPrimary || "#4fc3f7") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: parent.hovered ? "#fff" : (Color.mOnSurface || "#e0e0e0")
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        Button {
            Layout.preferredHeight: 38
            text: "✕"
            visible: (pluginApi.pluginSettings.iconFar || "").startsWith("/")
            onClicked: {
                pluginApi.pluginSettings.iconFar = "";
                fieldFar.text = "";
                pluginApi.saveSettings();
            }

            background: Rectangle {
                color: parent.hovered ? (Color.mErrorContainer || "#5c1a1a") : (Color.mSurfaceVariant || "#2a2a2a")
                radius: 6
                border.width: 1
                border.color: Color.mOutline || "#3a3a3a"

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            contentItem: Text {
                text: parent.text
                color: Color.mOnSurface || "#e0e0e0"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

    }

    // Icon sizes
    NLabel {
        label: "Icon sizes"
        description: "Scale each icon independently. The slider multiplies the bar's base font size."
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
            model: [{
                "label": "Focused  🌕",
                "key": "sizeFocused",
                "def": 1.7
            }, {
                "label": "Urgent   🌟",
                "key": "sizeUrgent",
                "def": 1.5
            }, {
                "label": "Occupied 🌗",
                "key": "sizeOccupied",
                "def": 1.4
            }, {
                "label": "Empty    🌙",
                "key": "sizeEmpty",
                "def": 1.2
            }]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: modelData.label
                    color: Color.mOnSurface || "#e0e0e0"
                    font.pixelSize: 13
                    font.family: Style.fontFamily || "sans-serif"
                    Layout.preferredWidth: 120
                }

                Item {
                    id: sliderTrack

                    readonly property real minVal: 0.5
                    readonly property real maxVal: 5.0
                    readonly property real trackW: width - handle.width
                    readonly property string settingKey: modelData.key
                    readonly property real defVal: modelData.def
                    property real currentVal: {
                        var v = pluginApi.pluginSettings[settingKey];
                        return (v !== undefined) ? v : defVal;
                    }

                    function snap(v) {
                        return Math.round(Math.max(minVal, Math.min(maxVal, v)) / 0.05) * 0.05;
                    }

                    function posFromVal(v) {
                        return (v - minVal) / (maxVal - minVal) * trackW;
                    }

                    function valFromPos(px) {
                        return snap(minVal + Math.max(0, Math.min(px, trackW)) / trackW * (maxVal - minVal));
                    }

                    Layout.fillWidth: true
                    height: 28

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: handle.width / 2
                        width: parent.trackW
                        height: 4
                        radius: 2
                        color: Color.mSurfaceVariant || "#3a3a3a"

                        Rectangle {
                            width: sliderTrack.posFromVal(sliderTrack.currentVal)
                            height: parent.height
                            radius: 2
                            color: Color.mPrimary || "#4fc3f7"
                        }

                    }

                    Rectangle {
                        id: handle

                        anchors.verticalCenter: parent.verticalCenter
                        x: sliderTrack.posFromVal(sliderTrack.currentVal)
                        width: 18
                        height: 18
                        radius: 9
                        color: dragArea.pressed ? (Color.mPrimaryContainer || "#1a5070") : (Color.mPrimary || "#4fc3f7")
                        border.color: "#ffffff"
                        border.width: 1

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }

                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        preventStealing: true
                        onPressed: (mouse) => {
                            var v = sliderTrack.valFromPos(mouse.x - handle.width / 2);
                            sliderTrack.currentVal = v;
                            pluginApi.pluginSettings[sliderTrack.settingKey] = Math.round(v * 100) / 100;
                            pluginApi.saveSettings();
                        }
                    }

                    MouseArea {
                        id: dragArea

                        property real startX: 0
                        property real startVal: 0

                        x: handle.x - 4
                        y: 0
                        width: handle.width + 8
                        height: parent.height
                        preventStealing: true
                        cursorShape: Qt.SizeHorCursor
                        onPressed: (mouse) => {
                            startX = mouse.x;
                            startVal = sliderTrack.currentVal;
                        }
                        onPositionChanged: (mouse) => {
                            if (!pressed)
                                return ;

                            var delta = mouse.x - startX;
                            var newVal = sliderTrack.snap(startVal + delta / sliderTrack.trackW * (sliderTrack.maxVal - sliderTrack.minVal));
                            sliderTrack.currentVal = newVal;
                            pluginApi.pluginSettings[sliderTrack.settingKey] = Math.round(newVal * 100) / 100;
                            pluginApi.saveSettings();
                        }
                    }

                }

                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 28
                    color: Color.mSurfaceVariant || "#2a2a2a"
                    radius: 6
                    border.color: Color.mOutline || "#3a3a3a"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: sliderTrack.currentVal.toFixed(2) + "×"
                        color: Color.mPrimary || "#4fc3f7"
                        font.pixelSize: 12
                        font.family: "monospace"
                    }

                }

                Button {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    text: "↺"
                    onClicked: {
                        sliderTrack.currentVal = sliderTrack.defVal;
                        pluginApi.pluginSettings[sliderTrack.settingKey] = sliderTrack.defVal;
                        pluginApi.saveSettings();
                    }

                    background: Rectangle {
                        color: parent.hovered ? (Color.mSurfaceVariant || "#333") : "transparent"
                        radius: 6
                        border.width: 1
                        border.color: Color.mOutline || "#3a3a3a"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                    contentItem: Text {
                        text: parent.text
                        color: Color.mOnSurfaceVariant || "#888"
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                }

            }

        }

    }

    // Glow
    NLabel {
        label: "Glow"
        description: "Controls the soft light behind each icon. Size multiplies the icon size. Opacity sets brightness. Blur softens the edge (0 = sharp, 1 = very soft). Blur radius sets how many pixels it spreads."
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
            model: [
                { "label": "Size ✦",       "key": "glowSize",    "def": 2.2,  "min": 0.0, "max": 5.0,  "step": 0.05, "unit": "×",  "dec": 2 },
                { "label": "Opacity ✦",    "key": "glowOpacity", "def": 0.50, "min": 0.0, "max": 1.0,  "step": 0.01, "unit": "",   "dec": 2 },
                { "label": "Blur soft ✦",  "key": "glowBlur",    "def": 1.0,  "min": 0.0, "max": 1.0,  "step": 0.01, "unit": "",   "dec": 2 },
                { "label": "Blur radius ✦","key": "glowBlurMax", "def": 32,   "min": 0.0, "max": 64.0, "step": 1.0,  "unit": "px", "dec": 0 }
            ]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: modelData.label
                    color: Color.mOnSurface || "#e0e0e0"
                    font.pixelSize: 13
                    font.family: Style.fontFamily || "sans-serif"
                    Layout.preferredWidth: 120
                }

                Item {
                    id: glowSlider
                    Layout.fillWidth: true
                    height: 28

                    readonly property real minVal:     modelData.min
                    readonly property real maxVal:     modelData.max
                    readonly property real stepVal:    modelData.step
                    readonly property real trackW:     width - glowHandle.width
                    readonly property string settingKey: modelData.key
                    readonly property real defVal:     modelData.def
                    readonly property string unit:     modelData.unit
                    readonly property int dec:         modelData.dec

                    property real currentVal: {
                        var v = pluginApi.pluginSettings[settingKey]
                        return (v !== undefined) ? v : defVal
                    }

                    function snap(v) {
                        return Math.round(Math.max(minVal, Math.min(maxVal, v)) / stepVal) * stepVal
                    }
                    function posFromVal(v) {
                        return (v - minVal) / (maxVal - minVal) * trackW
                    }
                    function valFromPos(px) {
                        return snap(minVal + Math.max(0, Math.min(px, trackW)) / trackW * (maxVal - minVal))
                    }

                    // Track
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: glowHandle.width / 2; width: parent.trackW
                        height: 4; radius: 2
                        color: Color.mSurfaceVariant || "#3a3a3a"
                        Rectangle {
                            width: glowSlider.posFromVal(glowSlider.currentVal)
                            height: parent.height; radius: 2
                            color: Color.mPrimary || "#4fc3f7"
                        }
                    }

                    // Handle
                    Rectangle {
                        id: glowHandle
                        anchors.verticalCenter: parent.verticalCenter
                        x: glowSlider.posFromVal(glowSlider.currentVal)
                        width: 18; height: 18; radius: 9
                        color: glowDrag.pressed ? (Color.mPrimaryContainer || "#1a5070") : (Color.mPrimary || "#4fc3f7")
                        border.color: "#ffffff"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        preventStealing: true
                        onPressed: (mouse) => {
                            var v = glowSlider.valFromPos(mouse.x - glowHandle.width / 2)
                            glowSlider.currentVal = v
                            pluginApi.pluginSettings[glowSlider.settingKey] = Math.round(v / glowSlider.stepVal) * glowSlider.stepVal
                            pluginApi.saveSettings()
                        }
                    }

                    MouseArea {
                        id: glowDrag
                        property real startX: 0
                        property real startVal: 0
                        x: glowHandle.x - 4; y: 0
                        width: glowHandle.width + 8; height: parent.height
                        preventStealing: true
                        cursorShape: Qt.SizeHorCursor
                        onPressed: (mouse) => { startX = mouse.x; startVal = glowSlider.currentVal }
                        onPositionChanged: (mouse) => {
                            if (!pressed) return
                            var delta = mouse.x - startX
                            var newVal = glowSlider.snap(startVal + delta / glowSlider.trackW * (glowSlider.maxVal - glowSlider.minVal))
                            glowSlider.currentVal = newVal
                            pluginApi.pluginSettings[glowSlider.settingKey] = Math.round(newVal / glowSlider.stepVal) * glowSlider.stepVal
                            pluginApi.saveSettings()
                        }
                    }
                }

                // Value badge
                Rectangle {
                    Layout.preferredWidth: 56; Layout.preferredHeight: 28
                    color: Color.mSurfaceVariant || "#2a2a2a"; radius: 6
                    border.color: Color.mOutline || "#3a3a3a"; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: glowSlider.currentVal.toFixed(glowSlider.dec) + glowSlider.unit
                        color: Color.mPrimary || "#4fc3f7"
                        font.pixelSize: 12; font.family: "monospace"
                    }
                }

                // Per-row reset
                Button {
                    Layout.preferredWidth: 28; Layout.preferredHeight: 28
                    text: "↺"
                    onClicked: {
                        glowSlider.currentVal = glowSlider.defVal
                        pluginApi.pluginSettings[glowSlider.settingKey] = glowSlider.defVal
                        pluginApi.saveSettings()
                    }
                    background: Rectangle {
                        color: parent.hovered ? (Color.mSurfaceVariant || "#333") : "transparent"
                        radius: 6; border.width: 1; border.color: Color.mOutline || "#3a3a3a"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Text {
                        text: parent.text; color: Color.mOnSurfaceVariant || "#888"
                        font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Urgent Glo
    NLabel {
        label: "Urgent Glow"
        description: "Independent glow settings for the urgent (pulsing) state. Size multiplies the icon size. Opacity sets brightness. Blur softens the edge (0 = sharp, 1 = very soft). Blur radius sets how many pixels it spreads."
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 10

        Repeater {
            model: [
                { "label": "Size ✦",       "key": "urgentGlowSize",    "def": 2.2,  "min": 0.0, "max": 5.0,  "step": 0.05, "unit": "×",  "dec": 2 },
                { "label": "Opacity ✦",    "key": "urgentGlowOpacity", "def": 0.50, "min": 0.0, "max": 1.0,  "step": 0.01, "unit": "",   "dec": 2 },
                { "label": "Blur soft ✦",  "key": "urgentGlowBlur",    "def": 1.0,  "min": 0.0, "max": 1.0,  "step": 0.01, "unit": "",   "dec": 2 },
                { "label": "Blur radius ✦","key": "urgentGlowBlurMax", "def": 32,   "min": 0.0, "max": 64.0, "step": 1.0,  "unit": "px", "dec": 0 }
            ]

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: modelData.label
                    color: Color.mOnSurface || "#e0e0e0"
                    font.pixelSize: 13
                    font.family: Style.fontFamily || "sans-serif"
                    Layout.preferredWidth: 120
                }

                Item {
                    id: urgentGlowSlider
                    Layout.fillWidth: true
                    height: 28

                    readonly property real minVal:     modelData.min
                    readonly property real maxVal:     modelData.max
                    readonly property real stepVal:    modelData.step
                    readonly property real trackW:     width - urgentGlowHandle.width
                    readonly property string settingKey: modelData.key
                    readonly property real defVal:     modelData.def
                    readonly property string unit:     modelData.unit
                    readonly property int dec:         modelData.dec

                    property real currentVal: {
                        var v = pluginApi.pluginSettings[settingKey]
                        return (v !== undefined) ? v : defVal
                    }

                    function snap(v) {
                        return Math.round(Math.max(minVal, Math.min(maxVal, v)) / stepVal) * stepVal
                    }
                    function posFromVal(v) {
                        return (v - minVal) / (maxVal - minVal) * trackW
                    }
                    function valFromPos(px) {
                        return snap(minVal + Math.max(0, Math.min(px, trackW)) / trackW * (maxVal - minVal))
                    }

                    // Track
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        x: urgentGlowHandle.width / 2; width: parent.trackW
                        height: 4; radius: 2
                        color: Color.mSurfaceVariant || "#3a3a3a"
                        Rectangle {
                            width: urgentGlowSlider.posFromVal(urgentGlowSlider.currentVal)
                            height: parent.height; radius: 2
                            color: Color.mPrimary || "#4fc3f7"
                        }
                    }

                    // Handle
                    Rectangle {
                        id: urgentGlowHandle
                        anchors.verticalCenter: parent.verticalCenter
                        x: urgentGlowSlider.posFromVal(urgentGlowSlider.currentVal)
                        width: 18; height: 18; radius: 9
                        color: urgentGlowDrag.pressed ? (Color.mPrimaryContainer || "#1a5070") : (Color.mPrimary || "#4fc3f7")
                        border.color: "#ffffff"; border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        preventStealing: true
                        onPressed: (mouse) => {
                            var v = urgentGlowSlider.valFromPos(mouse.x - urgentGlowHandle.width / 2)
                            urgentGlowSlider.currentVal = v
                            pluginApi.pluginSettings[urgentGlowSlider.settingKey] = Math.round(v / urgentGlowSlider.stepVal) * urgentGlowSlider.stepVal
                            pluginApi.saveSettings()
                        }
                    }

                    MouseArea {
                        id: urgentGlowDrag
                        property real startX: 0
                        property real startVal: 0
                        x: urgentGlowHandle.x - 4; y: 0
                        width: urgentGlowHandle.width + 8; height: parent.height
                        preventStealing: true
                        cursorShape: Qt.SizeHorCursor
                        onPressed: (mouse) => { startX = mouse.x; startVal = urgentGlowSlider.currentVal }
                        onPositionChanged: (mouse) => {
                            if (!pressed) return
                            var delta = mouse.x - startX
                            var newVal = urgentGlowSlider.snap(startVal + delta / urgentGlowSlider.trackW * (urgentGlowSlider.maxVal - urgentGlowSlider.minVal))
                            urgentGlowSlider.currentVal = newVal
                            pluginApi.pluginSettings[urgentGlowSlider.settingKey] = Math.round(newVal / urgentGlowSlider.stepVal) * urgentGlowSlider.stepVal
                            pluginApi.saveSettings()
                        }
                    }
                }

                // Value badge
                Rectangle {
                    Layout.preferredWidth: 56; Layout.preferredHeight: 28
                    color: Color.mSurfaceVariant || "#2a2a2a"; radius: 6
                    border.color: Color.mOutline || "#3a3a3a"; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: urgentGlowSlider.currentVal.toFixed(urgentGlowSlider.dec) + urgentGlowSlider.unit
                        color: Color.mPrimary || "#4fc3f7"
                        font.pixelSize: 12; font.family: "monospace"
                    }
                }

                // Per-row reset
                Button {
                    Layout.preferredWidth: 28; Layout.preferredHeight: 28
                    text: "↺"
                    onClicked: {
                        urgentGlowSlider.currentVal = urgentGlowSlider.defVal
                        pluginApi.pluginSettings[urgentGlowSlider.settingKey] = urgentGlowSlider.defVal
                        pluginApi.saveSettings()
                    }
                    background: Rectangle {
                        color: parent.hovered ? (Color.mSurfaceVariant || "#333") : "transparent"
                        radius: 6; border.width: 1; border.color: Color.mOutline || "#3a3a3a"
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    contentItem: Text {
                        text: parent.text; color: Color.mOnSurfaceVariant || "#888"
                        font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                }
            }
        }
    }

    // Reset
    Button {
        Layout.alignment: Qt.AlignRight
        Layout.preferredHeight: 34
        text: "Reset to defaults"
        onClicked: {
            pluginApi.pluginSettings.iconActive = "";
            fieldActive.text = "";
            pluginApi.pluginSettings.iconUrgent = "";
            fieldUrgent.text = "";
            pluginApi.pluginSettings.iconNearby = "";
            fieldNearby.text = "";
            pluginApi.pluginSettings.iconFar = "";
            fieldFar.text = "";
            pluginApi.pluginSettings.workspaceDisplayMode = "all";
            pluginApi.pluginSettings.sizeFocused = 1.7;
            pluginApi.pluginSettings.sizeUrgent = 1.5;
            pluginApi.pluginSettings.sizeOccupied = 1.4;
            pluginApi.pluginSettings.sizeEmpty = 1.2;
            pluginApi.pluginSettings.glowSize    = 2.2;
            pluginApi.pluginSettings.glowOpacity = 0.50;
            pluginApi.pluginSettings.glowBlur    = 1.0;
            pluginApi.pluginSettings.glowBlurMax = 32;
            pluginApi.pluginSettings.urgentGlowSize    = 2.2;
            pluginApi.pluginSettings.urgentGlowOpacity = 0.50;
            pluginApi.pluginSettings.urgentGlowBlur    = 1.0;
            pluginApi.pluginSettings.urgentGlowBlurMax = 32;
            pluginApi.saveSettings();
        }

        background: Rectangle {
            color: parent.hovered ? (Color.mSurfaceVariant || "#333") : "transparent"
            radius: 6
            border.width: 1
            border.color: Color.mOutline || "#3a3a3a"

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }

            }

        }

        contentItem: Text {
            text: parent.text
            color: Color.mOnSurfaceVariant || "#888"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

    }

    // Image picker panel
    ImagePickerPanel {
        id: picker

        onFileSelected: function(path) {
            if (root._pickerCallback) {
                root._pickerCallback(path);
                root._pickerCallback = null;
            }
        }
    }

}
