/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.milou as Milou

PlasmaExtras.Representation {
    id: full

    required property PlasmoidItem plasmoidRoot

    readonly property real popupW: Plasmoid.configuration.popupWidth * Kirigami.Units.gridUnit
    readonly property real popupH: Plasmoid.configuration.popupHeight * Kirigami.Units.gridUnit

    implicitWidth: popupW
    implicitHeight: popupH

    Layout.minimumWidth: popupW
    Layout.preferredWidth: popupW
    Layout.maximumWidth: popupW
    Layout.minimumHeight: popupH
    Layout.preferredHeight: popupH
    Layout.maximumHeight: popupH

    collapseMarginsHint: true

    function closePopup() {
        plasmoidRoot.query = "";
        plasmoidRoot.expanded = false;
    }

    Keys.onEscapePressed: closePopup()

    Component.onCompleted: plasmoidRoot.queryField = queryField

    header: PlasmaExtras.PlasmoidHeading {
        PlasmaExtras.SearchField {
            id: queryField
            anchors.fill: parent
            placeholderText: full.plasmoidRoot.placeholder
            focus: true
            text: full.plasmoidRoot.query
            onTextChanged: {
                if (full.plasmoidRoot.query !== text) {
                    full.plasmoidRoot.query = text;
                }
            }

            Keys.onPressed: event => {
                switch (event.key) {
                case Qt.Key_Escape:
                    full.closePopup();
                    event.accepted = true;
                    break;
                case Qt.Key_Up:
                    listView.decrementCurrentIndex();
                    event.accepted = true;
                    break;
                case Qt.Key_Down:
                    listView.incrementCurrentIndex();
                    event.accepted = true;
                    break;
                case Qt.Key_Return:
                case Qt.Key_Enter:
                    listView.runCurrentIndex(event);
                    event.accepted = true;
                    break;
                }
            }
        }
    }

    PlasmaComponents3.ScrollView {
        id: scrollView
        anchors.fill: parent
        focus: false

        Milou.ResultsView {
            id: listView
            queryField: queryField
            queryString: full.plasmoidRoot.query
            clip: true

            Keys.onEscapePressed: full.closePopup()

            onActivated: full.closePopup()

            onUpdateQueryString: (text, cursorPosition) => {
                queryField.text = text;
                queryField.cursorPosition = cursorPosition;
            }
        }
    }

    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 4
        visible: full.plasmoidRoot.query.length === 0
        iconName: "search"
        text: i18n("Type to search")
        explanation: i18n("Applications, files, settings, calculations and more")
    }

    PlasmaExtras.PlaceholderMessage {
        anchors.centerIn: parent
        width: parent.width - Kirigami.Units.gridUnit * 4
        visible: full.plasmoidRoot.query.length > 0 && !listView.querying && listView.count === 0
        iconName: "edit-none"
        text: i18n("No results found")
    }
}
