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
        readonly property color c: Kirigami.Theme.textColor
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: compact.fixedPillHeight > 0
            ? Math.min(compact.fixedPillHeight, parent.height)
            : Math.max(Kirigami.Units.gridUnit, parent.height - Kirigami.Units.smallSpacing * 2)
        radius: height / 2
        color: Qt.rgba(c.r, c.g, c.b, mouseArea.containsMouse ? 0.14 : 0.08)
        border.width: 1
        border.color: compact.plasmoidRoot.expanded || compact.activeFocus
            ? Kirigami.Theme.highlightColor
            : Qt.rgba(c.r, c.g, c.b, 0.18)

        Behavior on color { ColorAnimation { duration: Kirigami.Units.shortDuration } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: pill.radius * 0.6
            anchors.rightMargin: pill.radius * 0.6
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                visible: Plasmoid.configuration.showIcon
                source: compact.iconName
                Layout.preferredWidth: Math.max(Kirigami.Units.iconSizes.small, Math.min(Kirigami.Units.iconSizes.medium, Math.round(pill.height * 0.5)))
                Layout.preferredHeight: Layout.preferredWidth
                Layout.alignment: Qt.AlignVCenter
            }

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: compact.plasmoidRoot.query.length > 0 ? compact.plasmoidRoot.query : compact.plasmoidRoot.placeholder
                opacity: compact.plasmoidRoot.query.length > 0 ? 1 : 0.6
                elide: Text.ElideRight
                textFormat: Text.PlainText
                maximumLineCount: 1
                font.pointSize: Kirigami.Theme.defaultFont.pointSize * Math.max(1, Math.min(1.5, pill.height / (Kirigami.Units.gridUnit * 2.2)))
            }
        }
    }
}
