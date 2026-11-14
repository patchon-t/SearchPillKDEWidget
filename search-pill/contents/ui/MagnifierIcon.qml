/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Shapes
import org.kde.kirigami as Kirigami

// The Windows 11 search magnifier, drawn as a vector so it can fade from a
// plain monochrome glyph to the blue-to-green gradient on hover / focus.
Item {
    id: root

    property bool colorful: false
    property color baseColor: Kirigami.Theme.textColor

    // 0 = monochrome, 1 = full gradient. Animated.
    property real mix: colorful ? 1 : 0
    Behavior on mix {
        NumberAnimation {
            duration: Kirigami.Units.shortDuration
            easing.type: Easing.OutCubic
        }
    }

    readonly property real s: Math.min(width, height)
    readonly property real stroke: s * 0.115
    readonly property real ringR: s * 0.31
    readonly property real cx: s * 0.42
    readonly property real cy: s * 0.42

    // Gradient colours sampled from the Windows 11 icon, bottom-left to top-right.
    function tinted(hex) {
        const c = Qt.color(hex);
        return Qt.rgba(baseColor.r + (c.r - baseColor.r) * mix,
                       baseColor.g + (c.g - baseColor.g) * mix,
                       baseColor.b + (c.b - baseColor.b) * mix,
                       1);
    }

    implicitWidth: Kirigami.Units.iconSizes.small
    implicitHeight: Kirigami.Units.iconSizes.small

    layer.enabled: true
    layer.samples: 4

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        // Ring: two circles filled with the odd-even rule.
        ShapePath {
            fillRule: ShapePath.OddEvenFill
            strokeColor: "transparent"
            fillGradient: LinearGradient {
                x1: root.cx - root.ringR
                y1: root.cy + root.ringR
                x2: root.cx + root.ringR
                y2: root.cy - root.ringR
                GradientStop { position: 0.0; color: root.tinted("#0378D2") }
                GradientStop { position: 0.35; color: root.tinted("#1982D0") }
                GradientStop { position: 0.6; color: root.tinted("#42AF96") }
                GradientStop { position: 0.8; color: root.tinted("#69CA95") }
                GradientStop { position: 1.0; color: root.tinted("#66D28E") }
            }
            PathAngleArc {
                centerX: root.cx; centerY: root.cy
                radiusX: root.ringR + root.stroke / 2; radiusY: root.ringR + root.stroke / 2
                startAngle: 0; sweepAngle: 360
            }
            PathAngleArc {
                centerX: root.cx; centerY: root.cy
                radiusX: root.ringR - root.stroke / 2; radiusY: root.ringR - root.stroke / 2
                startAngle: 0; sweepAngle: 360
            }
        }

        // Handle: solid blue.
        ShapePath {
            strokeColor: root.tinted("#0378D2")
            strokeWidth: root.stroke * 1.05
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            startX: root.cx + root.ringR * 0.72 + root.stroke * 0.3
            startY: root.cy + root.ringR * 0.72 + root.stroke * 0.3
            PathLine {
                x: root.s * 0.9
                y: root.s * 0.9
            }
        }
    }
}
