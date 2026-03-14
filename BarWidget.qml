import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.Compositor
import QtQuick.Effects

// 🌙 Ranni Moon Workspaces — Lunar Princess Ranni theme
//
// State 0 — FOCUSED   🌕  you are here
// State 1 — URGENT    🌟  new activity from elsewhere
// State 2 — OCCUPIED  🌗  has windows, not focused
// State 3 — EMPTY     🌙  no windows

Item {
    id: wsWidget

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""

    readonly property string screenName:   screen?.name ?? ""
    readonly property string barPosition:  Settings.getBarPositionForScreen(screenName)
    readonly property bool   isVertical:   barPosition === "left" || barPosition === "right"

    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize:   Style.getBarFontSizeForScreen(screenName)
    readonly property real pillSize:      Math.max(barFontSize * 2.6, 48)
    readonly property int  baseTotalPills: 9
    readonly property int  pillSpacing:   6

    readonly property string workspaceDisplayMode: pluginApi?.pluginSettings?.workspaceDisplayMode || "all"

    readonly property var visibleWorkspaceIndices: {
        var indices = []

        if (workspaceDisplayMode === "once") {
            // Show all active/occupied + exactly 1 empty (first empty after last occupied)
            var occupiedList = []
            for (var oi = 1; oi <= baseTotalPills; oi++) {
                if (stateFor(oi) !== 3)
                    occupiedList.push(oi)
            }
            indices = occupiedList.slice()
            var lastOcc = occupiedList.length > 0 ? occupiedList[occupiedList.length - 1] : 0
            var emptyFound = false
            for (var ei = lastOcc + 1; ei <= baseTotalPills && !emptyFound; ei++) {
                if (stateFor(ei) === 3) { indices.push(ei); emptyFound = true }
            }
            if (!emptyFound) {
                for (var fi = 1; fi <= baseTotalPills && !emptyFound; fi++) {
                    if (stateFor(fi) === 3) { indices.push(fi); emptyFound = true }
                }
            }
        } else {
            for (var i = 1; i <= baseTotalPills; i++) {
                if (workspaceDisplayMode !== "active-occupied" || stateFor(i) !== 3)
                    indices.push(i)
            }
        }

        if (indices.length === 0)
            indices.push(1)

        return indices
    }

    readonly property int totalPills: visibleWorkspaceIndices.length

    readonly property real totalLength: pillSize * totalPills + pillSpacing * (totalPills - 1) + Style.marginL * 2

    readonly property real contentWidth:  isVertical ? capsuleHeight : totalLength
    readonly property real contentHeight: isVertical ? totalLength   : capsuleHeight

    implicitWidth:  contentWidth
    implicitHeight: contentHeight

    // Colors — Lunar color scheme
    readonly property color ranniBlue:   "#9DBCF5"
    readonly property color ranniGlow:   "#2A3355"
    readonly property color urgentColor: "#C45A7A"
    readonly property color urgentGlow:  "#10131c"

    // Glow settings (focused)
    readonly property real glowSize:    pluginApi?.pluginSettings?.glowSize    ?? 2.2
    readonly property real glowOpacity: pluginApi?.pluginSettings?.glowOpacity ?? 0.50
    readonly property real glowBlur:    pluginApi?.pluginSettings?.glowBlur    ?? 1.0
    readonly property real glowBlurMax: pluginApi?.pluginSettings?.glowBlurMax ?? 32

    // Glow settings (urgent — independent)
    readonly property real urgentGlowSize:    pluginApi?.pluginSettings?.urgentGlowSize    ?? 2.2
    readonly property real urgentGlowOpacity: pluginApi?.pluginSettings?.urgentGlowOpacity ?? 0.50
    readonly property real urgentGlowBlur:    pluginApi?.pluginSettings?.urgentGlowBlur    ?? 1.0
    readonly property real urgentGlowBlurMax: pluginApi?.pluginSettings?.urgentGlowBlurMax ?? 32

    // Icons
    readonly property string iconFocused:  pluginApi?.pluginSettings?.iconActive  || "🌕"
    readonly property string iconUrgent:   pluginApi?.pluginSettings?.iconUrgent  || "🌟"
    readonly property string iconOccupied: pluginApi?.pluginSettings?.iconNearby  || "🌗"
    readonly property string iconEmpty:    pluginApi?.pluginSettings?.iconFar     || "🌙"

    // Size multipliers
    readonly property real multFocused:  pluginApi?.pluginSettings?.sizeFocused  ?? 2.4
    readonly property real multUrgent:   pluginApi?.pluginSettings?.sizeUrgent   ?? 2.1
    readonly property real multOccupied: pluginApi?.pluginSettings?.sizeOccupied ?? 1.9
    readonly property real multEmpty:    pluginApi?.pluginSettings?.sizeEmpty    ?? 1.6

    readonly property real sizeFocused:  barFontSize * multFocused
    readonly property real sizeUrgent:   barFontSize * multUrgent
    readonly property real sizeOccupied: barFontSize * multOccupied
    readonly property real sizeEmpty:    barFontSize * multEmpty

    // Workspace state
    readonly property var wsModel: CompositorService.workspaces

    readonly property var wsStateMap: {
        var m = {}
        for (var i = 0; i < wsModel.count; i++) {
            var ws = wsModel.get(i)
            m[ws.idx] = {
                focused:  ws.isFocused  === true,
                urgent:   ws.isUrgent   === true,
                occupied: ws.isOccupied === true
            }
        }
        return m
    }

    function stateFor(idx) {
        var s = wsStateMap[idx]
        if (!s)         return 3
        if (s.focused)  return 0
        if (s.urgent)   return 1
        if (s.occupied) return 2
        return 3
    }

    function glyphFor(state) {
        if (state === 0) return iconFocused
        if (state === 1) return iconUrgent
        if (state === 2) return iconOccupied
        return iconEmpty
    }

    function colorFor(state) {
        if (state === 0) return ranniBlue
        if (state === 1) return urgentColor
        if (state === 2) return Qt.rgba(0.616, 0.737, 0.961, 0.75)
        return                  Qt.rgba(0.616, 0.737, 0.961, 0.40)
    }

    function sizeFor(state) {
        if (state === 0) return sizeFocused
        if (state === 1) return sizeUrgent
        if (state === 2) return sizeOccupied
        return sizeEmpty
    }

    function glowColorFor(state) {
        return state === 1 ? urgentGlow : ranniGlow
    }

    function glowSizeFor(state) {
        return state === 1 ? urgentGlowSize : glowSize
    }

    function glowOpacityFor(state) {
        return state === 1 ? urgentGlowOpacity : glowOpacity
    }

    function glowBlurFor(state) {
        return state === 1 ? urgentGlowBlur : glowBlur
    }

    function glowBlurMaxFor(state) {
        return state === 1 ? urgentGlowBlurMax : glowBlurMax
    }

    // Visual capsule
    Rectangle {
        id: visualCapsule
        anchors.centerIn: parent
        width:  wsWidget.contentWidth
        height: wsWidget.contentHeight
        radius: Style.radiusL
        color:  Style.capsuleColor
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        Grid {
            anchors.centerIn: parent
            columns: wsWidget.isVertical ? 1 : wsWidget.totalPills
            rows:    wsWidget.isVertical ? wsWidget.totalPills : 1
            spacing: wsWidget.pillSpacing

            Repeater {
                model: wsWidget.visibleWorkspaceIndices

                delegate: Item {
                    id: pill
                    readonly property int    wsIdx:      modelData
                    readonly property int    state:      wsWidget.stateFor(wsIdx)
                    readonly property string glyph:      wsWidget.glyphFor(state)
                    readonly property color  glyphColor: wsWidget.colorFor(state)
                    readonly property real   glyphSize:  wsWidget.sizeFor(state)
                    readonly property bool   isFile:     glyph.startsWith("/")

                    width:  wsWidget.isVertical ? wsWidget.contentWidth : wsWidget.pillSize
                    height: wsWidget.isVertical ? wsWidget.pillSize      : wsWidget.contentHeight

                    // Glow
                    Rectangle {
                        id: glowRect
                        anchors.centerIn: parent
                        width:  pill.glyphSize * wsWidget.glowSizeFor(pill.state)
                        height: pill.glyphSize * wsWidget.glowSizeFor(pill.state)
                        radius: width / 2
                        color:  wsWidget.glowColorFor(pill.state)

                        opacity: (pill.state === 0 || pill.state === 1)
                                ? wsWidget.glowOpacityFor(pill.state)
                                : 0.0

                        layer.enabled: wsWidget.glowOpacityFor(pill.state) > 0
                        layer.effect: MultiEffect {
                            blurEnabled: true
                            blur:    wsWidget.glowBlurFor(pill.state)
                            blurMax: wsWidget.glowBlurMaxFor(pill.state)
                        }

                        Behavior on opacity { NumberAnimation { duration: 280 } }
                        Behavior on color   { ColorAnimation  { duration: 220 } }

                        SequentialAnimation on opacity {
                            running: pill.state === 1
                            loops:   Animation.Infinite
                            NumberAnimation { to: wsWidget.urgentGlowOpacity; duration: 700; easing.type: Easing.InOutSine }
                            NumberAnimation { to: wsWidget.urgentGlowOpacity * 0.27; duration: 700; easing.type: Easing.InOutSine }
                        }
                    }

                    // Emoji moon glyph
                    Text {
                        id: moonText
                        anchors.centerIn: parent
                        visible:        !pill.isFile
                        text:           pill.isFile ? "" : pill.glyph
                        font.pixelSize: pill.glyphSize
                        color:          pill.glyphColor
                        Behavior on font.pixelSize { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on color          { ColorAnimation  { duration: 200 } }
                        Behavior on text {
                            SequentialAnimation {
                                NumberAnimation { target: moonText; property: "scale"; to: 1.3;  duration: 80;  easing.type: Easing.OutQuad }
                                NumberAnimation { target: moonText; property: "scale"; to: 1.0;  duration: 130; easing.type: Easing.OutBounce }
                            }
                        }
                    }

                    // Image icon (when glyph is a file path)
                    AnimatedImage {
                        id: moonImage
                        anchors.centerIn: parent
                        visible:  pill.isFile
                        source:   pill.isFile ? ("file://" + pill.glyph) : ""
                        width:    pill.glyphSize
                        height:   pill.glyphSize
                        fillMode: Image.PreserveAspectFit
                        playing:  pill.isFile
                        smooth:   true
                        opacity:  pill.state === 0 ? 1.0
                                : pill.state === 1 ? 0.9
                                : pill.state === 2 ? 0.6 : 0.35

                        Behavior on opacity { NumberAnimation { duration: 200 } }
                        Behavior on width   { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on height  { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

                        Behavior on source {
                            SequentialAnimation {
                                NumberAnimation { target: moonImage; property: "scale"; to: 1.3;  duration: 80;  easing.type: Easing.OutQuad }
                                NumberAnimation { target: moonImage; property: "scale"; to: 1.0;  duration: 130; easing.type: Easing.OutBounce }
                            }
                        }
                    }

                    // Bounce animation triggered on state change — sibling of Image so it's in scope
                    SequentialAnimation {
                        id: imgBounce
                        NumberAnimation { target: moonImage; property: "scale"; to: 1.25; duration: 80;  easing.type: Easing.OutQuad }
                        NumberAnimation { target: moonImage; property: "scale"; to: 1.0;  duration: 130; easing.type: Easing.OutBounce }
                    }

                    Connections {
                        target: pill
                        function onStateChanged() {
                            if (pill.isFile) imgBounce.restart()
                            moonImage.playing = false
                            moonImage.playing = Qt.binding(() => pill.isFile)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked:    CompositorService.switchToWorkspace({ idx: pill.wsIdx, name: String(pill.wsIdx) })
                    }
                }
            }
        }
    }
}
