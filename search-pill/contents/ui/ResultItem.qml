/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

// One row of the results list: optional group header ("Best match" or the
// category name), then icon + title + subtitle + chevron.
Item {
    id: item

    required property int index
    required property var model

    property string queryText: ""

    readonly property bool isCurrent: ListView.isCurrentItem
    readonly property bool isBest: index === 0
    readonly property string title: String(model.display ?? "")
    readonly property string category: String(model.category ?? "")
    readonly property string subtext: String(model.subtext ?? "")
    readonly property var icon: model.decoration
    readonly property var actions: model.actions ?? []

    readonly property string headerText: isBest ? i18n("Best match")
        : (index === 1 || ListView.section !== ListView.previousSection) ? category : ""

    signal activated()   // run this result
    signal selected()    // only show it in the preview pane

    function tint(a) {
        const c = Kirigami.Theme.textColor;
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    // Bold the part of the title that matches what was typed.
    function highlighted(text, query) {
        const esc = s => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
        const q = query.trim();
        const at = q.length > 0 ? text.toLowerCase().indexOf(q.toLowerCase()) : -1;
        if (at < 0) {
            return esc(text);
        }
        return esc(text.slice(0, at)) + "<b>" + esc(text.slice(at, at + q.length)) + "</b>"
            + esc(text.slice(at + q.length));
    }

    width: ListView.view ? ListView.view.width : 0
    implicitHeight: column.implicitHeight

    Accessible.role: Accessible.ListItem
    Accessible.name: title
    Accessible.description: subtext.length > 0 ? subtext : category

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        PlasmaComponents3.Label {
            visible: item.headerText.length > 0
            text: item.headerText
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing * 2
            Layout.topMargin: item.index === 0 ? Kirigami.Units.smallSpacing : Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            id: row
            Layout.fillWidth: true
            implicitHeight: rowLayout.implicitHeight + Kirigami.Units.smallSpacing * (item.isBest ? 4 : 2.5)
            radius: Kirigami.Units.cornerRadius
            color: item.isCurrent ? item.tint(0.10) : hover.hovered ? item.tint(0.05) : "transparent"

            // Accent marker on the selected row.
            Rectangle {
                visible: item.isCurrent
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 3
                height: Math.round(parent.height * 0.45)
                radius: width / 2
                color: Kirigami.Theme.highlightColor
            }

            HoverHandler {
                id: hover
            }
            TapHandler {
                onTapped: item.activated()
            }

            RowLayout {
                id: rowLayout
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing * 2.5
                anchors.rightMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing * 2.5

                Kirigami.Icon {
                    source: item.icon
                    implicitWidth: item.isBest ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: implicitWidth
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: item.highlighted(item.title, item.queryText)
                        textFormat: Text.StyledText
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: item.subtext.length > 0 ? item.subtext : item.category
                        visible: text.length > 0
                        font: Kirigami.Theme.smallFont
                        opacity: 0.7
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                // Chevron: select without running, to look at the preview.
                Rectangle {
                    implicitWidth: Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing * 2
                    implicitHeight: implicitWidth
                    radius: Kirigami.Units.cornerRadius
                    color: chevronHover.hovered ? item.tint(0.10) : "transparent"
                    opacity: hover.hovered || item.isCurrent ? 1 : 0

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.small
                        height: width
                        source: "go-next-symbolic"
                    }
                    HoverHandler {
                        id: chevronHover
                    }
                    TapHandler {
                        gesturePolicy: TapHandler.WithinBounds
                        onTapped: item.selected()
                    }
                }
            }
        }
    }
}
