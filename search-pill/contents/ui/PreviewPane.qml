/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Right-hand card: details and actions for the selected result.
Rectangle {
    id: pane

    // The selected ResultItem (or null).
    property Item result: null

    signal openRequested()
    signal actionRequested(int actionIndex)

    function tint(a) {
        const c = Kirigami.Theme.textColor;
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    radius: Kirigami.Units.cornerRadius * 2
    color: tint(0.05)
    border.width: 1
    border.color: tint(0.08)

    component ActionRow: Rectangle {
        id: actionRow
        property alias iconSource: actionIcon.source
        property alias text: actionLabel.text
        signal triggered()

        Layout.fillWidth: true
        implicitHeight: actionLabel.implicitHeight + Kirigami.Units.smallSpacing * 3
        radius: Kirigami.Units.cornerRadius
        color: actionHover.hovered ? pane.tint(0.08) : "transparent"

        HoverHandler {
            id: actionHover
        }
        TapHandler {
            onTapped: actionRow.triggered()
        }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Kirigami.Units.smallSpacing * 2
            anchors.rightMargin: Kirigami.Units.smallSpacing * 2
            spacing: Kirigami.Units.smallSpacing * 2

            Kirigami.Icon {
                id: actionIcon
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: implicitWidth
                color: Kirigami.Theme.highlightColor
                isMask: false
            }
            PlasmaComponents3.Label {
                id: actionLabel
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing
        visible: pane.result !== null

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing * 2
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: implicitWidth
            source: pane.result ? pane.result.icon : ""
        }
        Kirigami.Heading {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            level: 3
            text: pane.result ? pane.result.title : ""
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            text: pane.result ? pane.result.category : ""
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            visible: text.length > 0
            text: pane.result ? pane.result.subtext : ""
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            maximumLineCount: 3
            elide: Text.ElideRight
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
            implicitHeight: 1
            color: pane.tint(0.12)
        }

        ActionRow {
            iconSource: "document-open-symbolic"
            text: i18n("Open")
            onTriggered: pane.openRequested()
        }
        Repeater {
            model: pane.result ? pane.result.actions : []
            ActionRow {
                required property int index
                required property var modelData
                iconSource: modelData.iconSource || "system-run-symbolic"
                text: modelData.text || ""
                onTriggered: pane.actionRequested(index)
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
