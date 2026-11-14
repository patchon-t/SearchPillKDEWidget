/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: compact

    required property PlasmoidItem plasmoidRoot

    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property real pillWidth: Plasmoid.configuration.pillWidth * Kirigami.Units.gridUnit
    // 0 means automatic: use the whole panel thickness minus small margins.
    readonly property real fixedPillHeight: Plasmoid.configuration.pillHeight
    readonly property real currentPillHeight: pill.height
    readonly property string iconName: Plasmoid.configuration.iconName.length > 0
        ? Plasmoid.configuration.iconName : "search"

    implicitWidth: vertical ? Kirigami.Units.iconSizes.medium : pillWidth
    implicitHeight: vertical ? Kirigami.Units.iconSizes.medium
        : (fixedPillHeight > 0 ? fixedPillHeight + Kirigami.Units.smallSpacing * 2 : Kirigami.Units.gridUnit * 2.2)

    Layout.minimumWidth: vertical ? -1 : pillWidth
    Layout.preferredWidth: vertical ? -1 : pillWidth
    Layout.maximumWidth: vertical ? -1 : pillWidth

    activeFocusOnTab: true
    Accessible.role: Accessible.Button
    Accessible.name: plasmoidRoot.placeholder

    function openWith(text) {
        plasmoidRoot.query = text;
        plasmoidRoot.expanded = true;
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Down) {
            openWith(plasmoidRoot.query);
            event.accepted = true;
            return;
        }
        const mods = Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier;
        if (!(event.modifiers & mods) && event.text.length > 0 && !/[\x00-\x1F\x7F]/.test(event.text)) {
            openWith(plasmoidRoot.query + event.text);
            event.accepted = true;
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        property bool wasExpanded: false
        onPressed: wasExpanded = compact.plasmoidRoot.expanded
        onClicked: compact.plasmoidRoot.expanded = !wasExpanded
        // Ctrl+scroll over the pill resizes it; plain scroll is left to the panel.
        onWheel: wheel => {
            if (wheel.modifiers & Qt.ControlModifier && !compact.vertical) {
                compact.plasmoidRoot.adjustPillHeight(wheel.angleDelta.y > 0 ? compact.plasmoidRoot.heightStep : -compact.plasmoidRoot.heightStep, pill.height);
                wheel.accepted = true;
            } else {
                wheel.accepted = false;
            }
        }
    }

    // Vertical panel: just an icon.
    Kirigami.Icon {
        anchors.fill: parent
        visible: compact.vertical
        source: compact.iconName
        active: mouseArea.containsMouse
    }

    Rectangle {
        id: pill
        visible: !compact.vertical

        // Hover, keyboard focus or an open popup all light the pill up.
        readonly property bool hot: mouseArea.containsMouse || compact.activeFocus || compact.plasmoidRoot.expanded
        readonly property bool lightTheme: Kirigami.ColorUtils.brightnessForColor(Kirigami.Theme.backgroundColor)
            === Kirigami.ColorUtils.Light
        readonly property color ink: Kirigami.Theme.textColor

        // Light theme: warm white fading to lavender, flat white when hot.
        // Dark theme: translucent white, brighter when hot.
        readonly property color idleLeft: lightTheme ? "#FDF8F5" : Qt.rgba(1, 1, 1, 0.09)
        readonly property color idleRight: lightTheme ? "#FAF7FB" : Qt.rgba(1, 1, 1, 0.07)
        readonly property color hotColor: lightTheme ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.15)

        property real heat: hot ? 1 : 0
        Behavior on heat {
            NumberAnimation {
                duration: Kirigami.Units.shortDuration
                easing.type: Easing.OutCubic
            }
        }
        function lerp(a, b, t) {
            return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t);
        }

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: compact.fixedPillHeight > 0
            ? Math.min(compact.fixedPillHeight, parent.height)
            : Math.max(Kirigami.Units.gridUnit, parent.height - Kirigami.Units.smallSpacing * 2)
        radius: height / 2

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: pill.lerp(pill.idleLeft, pill.hotColor, pill.heat) }
            GradientStop { position: 1.0; color: pill.lerp(pill.idleRight, pill.hotColor, pill.heat) }
        }
        border.width: 1
        border.color: compact.activeFocus
            ? Kirigami.Theme.highlightColor
            : Qt.rgba(ink.r, ink.g, ink.b, lightTheme ? 0.10 : 0.16)

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: pill.radius * 0.6
            anchors.rightMargin: pill.radius * 0.6
            spacing: Kirigami.Units.smallSpacing * 2

            Item {
                id: iconBox
                visible: Plasmoid.configuration.showIcon
                readonly property bool custom: compact.iconName !== "search"
                Layout.preferredWidth: Math.max(Kirigami.Units.iconSizes.small, Math.min(Kirigami.Units.iconSizes.medium, Math.round(pill.height * 0.5)))
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignVCenter

                // Default icon: the Windows 11 magnifier with the hover gradient.
                MagnifierIcon {
                    anchors.fill: parent
                    visible: !iconBox.custom
                    colorful: pill.hot
                }
                Kirigami.Icon {
                    anchors.fill: parent
                    visible: iconBox.custom
                    source: compact.iconName
                    active: pill.hot
                }
            }

            // Text area: placeholder, or the query with caret and selection
            // mirrored from the popup's real field.
            Item {
                id: textArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                readonly property font textFont: {
                    const f = Qt.font(Kirigami.Theme.defaultFont);
                    f.pointSize = Kirigami.Theme.defaultFont.pointSize * Math.max(1, Math.min(1.5, pill.height / (Kirigami.Units.gridUnit * 2.2)));
                    return f;
                }
                readonly property string query: compact.plasmoidRoot.query
                readonly property bool typing: compact.plasmoidRoot.expanded

                // One metrics object per position, so no binding writes to a shared one.
                readonly property real caretX: caretMetrics.advanceWidth
                readonly property real selX: selStartMetrics.advanceWidth
                readonly property real selW: selEndMetrics.advanceWidth - selStartMetrics.advanceWidth
                // Keep the caret in view when the text is longer than the pill.
                readonly property real scroll: Math.max(0, caretX - (width - 2))

                TextMetrics {
                    id: caretMetrics
                    font: textArea.textFont
                    text: textArea.query.slice(0, compact.plasmoidRoot.cursorPos)
                }
                TextMetrics {
                    id: selStartMetrics
                    font: textArea.textFont
                    text: textArea.query.slice(0, compact.plasmoidRoot.selStart)
                }
                TextMetrics {
                    id: selEndMetrics
                    font: textArea.textFont
                    text: textArea.query.slice(0, compact.plasmoidRoot.selEnd)
                }

                PlasmaComponents3.Label {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    visible: textArea.query.length === 0
                    text: compact.plasmoidRoot.placeholder
                    font: textArea.textFont
                    opacity: pill.hot ? 0.7 : 0.8
                    elide: Text.ElideRight
                    textFormat: Text.PlainText
                    maximumLineCount: 1
                }

                Item {
                    id: queryView
                    visible: textArea.query.length > 0
                    x: -textArea.scroll
                    width: textWidth.advanceWidth + 2
                    height: parent.height

                    TextMetrics {
                        id: textWidth
                        font: textArea.textFont
                        text: textArea.query
                    }

                    // Selection highlight, with the selected text redrawn in the
                    // highlighted-text colour on top.
                    readonly property real selX: textArea.selX
                    readonly property real selW: textArea.selW
                    Rectangle {
                        visible: queryView.selW > 0
                        x: queryView.selX
                        width: queryView.selW
                        height: Math.round(queryLabel.implicitHeight * 1.05)
                        anchors.verticalCenter: parent.verticalCenter
                        color: Kirigami.Theme.highlightColor
                    }
                    PlasmaComponents3.Label {
                        id: queryLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: textArea.query
                        font: textArea.textFont
                        textFormat: Text.PlainText
                    }
                    Item {
                        visible: queryView.selW > 0
                        x: queryView.selX
                        width: queryView.selW
                        height: parent.height
                        clip: true
                        PlasmaComponents3.Label {
                            x: -queryView.selX
                            anchors.verticalCenter: parent.verticalCenter
                            text: textArea.query
                            font: textArea.textFont
                            textFormat: Text.PlainText
                            color: Kirigami.Theme.highlightedTextColor
                        }
                    }
                }

                // Blinking caret while the popup is open.
                Rectangle {
                    id: caret
                    visible: textArea.typing && caretOn
                    property bool caretOn: true
                    x: textArea.caretX - textArea.scroll
                    width: Math.max(1, Math.round(Kirigami.Units.devicePixelRatio))
                    height: Math.round(queryLabel.implicitHeight * 1.05)
                    anchors.verticalCenter: parent.verticalCenter
                    color: Kirigami.Theme.textColor

                    Timer {
                        interval: 530
                        running: textArea.typing
                        repeat: true
                        onTriggered: caret.caretOn = !caret.caretOn
                        onRunningChanged: caret.caretOn = true
                    }
                    // Solid right after typing or moving the caret.
                    Connections {
                        target: compact.plasmoidRoot
                        function onCursorPosChanged() {
                            caret.caretOn = true;
                        }
                    }
                }
            }
        }
    }
}
