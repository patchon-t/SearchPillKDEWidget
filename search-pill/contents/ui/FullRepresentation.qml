/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.milou as Milou

// Windows 11 style search flyout: search bar, filter tabs, results list on the
// left and a preview card on the right. Results come from KRunner through
// Milou.ResultsModel; all of the UI is our own.
PlasmaExtras.Representation {
    id: full

    required property PlasmoidItem plasmoidRoot

    readonly property real popupW: Plasmoid.configuration.popupWidth * Kirigami.Units.gridUnit
    readonly property real popupH: Plasmoid.configuration.popupHeight * Kirigami.Units.gridUnit

    // Filter tabs. `runner` is a KRunner plugin id; empty means all runners.
    readonly property var filters: [
        { label: i18n("All"), runner: "" },
        { label: i18n("Apps"), runner: "krunner_services" },
        { label: i18n("Files"), runner: "baloosearch" },
        { label: i18n("Settings"), runner: "krunner_systemsettings" }
    ]
    property int filterIndex: 0

    // Enter pressed before the first results arrived.
    property bool runPending: false
    // The user moved the selection, so don't snap it back to the first row.
    property bool userNavigated: false

    implicitWidth: popupW
    implicitHeight: popupH

    Layout.minimumWidth: popupW
    Layout.preferredWidth: popupW
    Layout.maximumWidth: popupW
    Layout.minimumHeight: popupH
    Layout.preferredHeight: popupH
    Layout.maximumHeight: popupH

    collapseMarginsHint: false

    // The popup window Plasma created for us (a PlasmaCore.AppletPopup).
    readonly property var popupWindow: Window.window
    readonly property bool floatingPopup: Plasmoid.configuration.floatingPopup
    readonly property int popupGap: Plasmoid.configuration.popupGap

    // Detach the popup from the panel and screen edges, Windows 11 style.
    // Plasma only does this itself for floating panels, so set the popup's
    // margin directly. Does nothing where there is no such popup window.
    function applyFloating() {
        const w = popupWindow;
        if (!w || w.margin === undefined) {
            return;
        }
        if (floatingPopup) {
            w.margin = popupGap;
        } else {
            w.margin = (Plasmoid.containmentDisplayHints & PlasmaCore.Types.ContainmentPrefersFloatingApplets)
                ? Kirigami.Units.largeSpacing : 0;
        }
    }

    onPopupWindowChanged: applyFloating()
    onFloatingPopupChanged: applyFloating()
    onPopupGapChanged: applyFloating()

    function tint(a) {
        const c = Kirigami.Theme.textColor;
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function closePopup() {
        plasmoidRoot.query = "";
        plasmoidRoot.expanded = false;
    }

    function runIndex(row) {
        if (row < 0 || row >= listView.count) {
            // Results still loading: run the first one when it shows up.
            runPending = resultModel.querying || plasmoidRoot.query.length > 0;
            return;
        }
        if (resultModel.run(resultModel.index(row, 0))) {
            closePopup();
        }
    }

    function runAction(row, actionIndex) {
        if (row >= 0 && row < listView.count
                && resultModel.runAction(resultModel.index(row, 0), actionIndex)) {
            closePopup();
        }
    }

    function move(delta) {
        if (listView.count === 0) {
            return;
        }
        userNavigated = true;
        listView.currentIndex = Math.max(0, Math.min(listView.count - 1, listView.currentIndex + delta));
    }

    function cycleFilter(delta) {
        filterIndex = (filterIndex + delta + filters.length) % filters.length;
    }

    Keys.onEscapePressed: closePopup()

    Component.onCompleted: {
        plasmoidRoot.queryField = queryField;
        resultModel.queryString = plasmoidRoot.query;
        applyFloating();
    }

    // A new filter only applies to the next query, so re-run the current one.
    onFilterIndexChanged: {
        resultModel.singleRunner = filters[filterIndex].runner;
        resultModel.queryString = "";
        resultModel.queryString = plasmoidRoot.query;
    }

    Connections {
        target: full.plasmoidRoot
        function onQueryChanged() {
            resultModel.queryString = full.plasmoidRoot.query;
        }
        function onExpandedChanged() {
            full.applyFloating();
            if (!full.plasmoidRoot.expanded) {
                full.filterIndex = 0;
            }
        }
    }

    Milou.ResultsModel {
        id: resultModel
        limit: 20

        function settle() {
            if (!full.userNavigated) {
                listView.currentIndex = 0;
            }
            if (full.runPending && listView.count > 0) {
                full.runPending = false;
                // Delayed: running may close the popup and reset the model.
                Qt.callLater(() => full.runIndex(0));
            }
        }

        onQueryStringChanged: {
            full.runPending = false;
            full.userNavigated = false;
            listView.currentIndex = 0;
        }
        onQueryStringChangeRequested: (queryString, pos) => {
            queryField.text = queryString;
            queryField.cursorPosition = pos;
        }
        onModelReset: Qt.callLater(settle)
        onRowsInserted: Qt.callLater(settle)
        onQueryingChanged: {
            if (!querying && listView.count === 0) {
                full.runPending = false;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.smallSpacing * 2

        // ---- Search bar -------------------------------------------------
        Rectangle {
            id: searchBar
            Layout.fillWidth: true
            implicitHeight: Math.round(Kirigami.Units.gridUnit * 2.2)
            radius: Kirigami.Units.cornerRadius
            color: full.tint(0.06)
            border.width: 1
            border.color: full.tint(0.10)

            // Accent underline, clipped to the rounded bottom edge.
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 2
                clip: true
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: searchBar.radius * 2
                    radius: searchBar.radius
                    color: Kirigami.Theme.highlightColor
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing * 3
                anchors.rightMargin: Kirigami.Units.smallSpacing
                spacing: Kirigami.Units.smallSpacing * 2

                Kirigami.Icon {
                    source: Plasmoid.configuration.iconName.length > 0 ? Plasmoid.configuration.iconName : "search"
                    implicitWidth: Kirigami.Units.iconSizes.small
                    implicitHeight: implicitWidth
                }

                TextInput {
                    id: queryField
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    verticalAlignment: TextInput.AlignVCenter
                    clip: true
                    focus: true
                    selectByMouse: true
                    color: Kirigami.Theme.textColor
                    selectionColor: Kirigami.Theme.highlightColor
                    selectedTextColor: Kirigami.Theme.highlightedTextColor
                    font: Kirigami.Theme.defaultFont
                    text: full.plasmoidRoot.query
                    Accessible.name: full.plasmoidRoot.placeholder
                    Accessible.searchEdit: true

                    onTextChanged: {
                        if (full.plasmoidRoot.query !== text) {
                            full.plasmoidRoot.query = text;
                        }
                    }

                    PlasmaComponents3.Label {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: queryField.text.length === 0 && queryField.preeditText.length === 0
                        text: full.plasmoidRoot.placeholder
                        opacity: 0.6
                        elide: Text.ElideRight
                    }

                    Keys.onPressed: event => {
                        switch (event.key) {
                        case Qt.Key_Escape:
                            full.closePopup();
                            break;
                        case Qt.Key_Up:
                            full.move(-1);
                            break;
                        case Qt.Key_Down:
                            full.move(1);
                            break;
                        case Qt.Key_PageUp:
                            full.move(-5);
                            break;
                        case Qt.Key_PageDown:
                            full.move(5);
                            break;
                        case Qt.Key_Tab:
                            full.cycleFilter(1);
                            break;
                        case Qt.Key_Backtab:
                            full.cycleFilter(-1);
                            break;
                        case Qt.Key_Return:
                        case Qt.Key_Enter:
                            if ((event.modifiers & Qt.ShiftModifier) && listView.currentItem
                                    && listView.currentItem.actions.length > 0) {
                                full.runAction(listView.currentIndex, 0);
                            } else {
                                full.runIndex(listView.count > 0 ? listView.currentIndex : -1);
                            }
                            break;
                        default:
                            return;
                        }
                        event.accepted = true;
                    }
                }

                PlasmaComponents3.ToolButton {
                    visible: queryField.text.length > 0
                    icon.name: "edit-clear"
                    focusPolicy: Qt.NoFocus
                    Accessible.name: i18n("Clear")
                    onClicked: {
                        queryField.text = "";
                        queryField.forceActiveFocus();
                    }
                }
            }
        }

        // ---- Filter tabs ------------------------------------------------
        Row {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Repeater {
                model: full.filters

                Item {
                    id: tab
                    required property int index
                    required property var modelData
                    readonly property bool active: index === full.filterIndex

                    implicitWidth: tabLabel.implicitWidth + Kirigami.Units.smallSpacing * 4
                    implicitHeight: tabLabel.implicitHeight + Kirigami.Units.smallSpacing * 3
                    width: implicitWidth
                    height: implicitHeight

                    Accessible.role: Accessible.PageTab
                    Accessible.name: modelData.label

                    Rectangle {
                        anchors.fill: parent
                        radius: Kirigami.Units.cornerRadius
                        color: tabHover.hovered ? full.tint(0.06) : "transparent"
                    }
                    PlasmaComponents3.Label {
                        id: tabLabel
                        anchors.centerIn: parent
                        text: tab.modelData.label
                        font.weight: tab.active ? Font.DemiBold : Font.Normal
                        opacity: tab.active ? 1 : 0.75
                    }
                    Rectangle {
                        visible: tab.active
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: Math.round(tabLabel.implicitWidth * 0.6)
                        height: 3
                        radius: 1.5
                        color: Kirigami.Theme.highlightColor
                    }
                    HoverHandler {
                        id: tabHover
                    }
                    TapHandler {
                        onTapped: {
                            full.filterIndex = tab.index;
                            queryField.forceActiveFocus();
                        }
                    }
                }
            }
        }

        // ---- Results + preview -------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.largeSpacing

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1

                PlasmaComponents3.ScrollView {
                    anchors.fill: parent
                    focus: false

                    ListView {
                        id: listView
                        model: resultModel
                        clip: true
                        focus: false
                        boundsBehavior: Flickable.StopAtBounds
                        highlightMoveDuration: 0
                        // No section delegate: sections are only used so rows
                        // can tell when their category differs from the row above.
                        section.property: "category"
                        section.criteria: ViewSection.FullString
                        Accessible.role: Accessible.List

                        delegate: ResultItem {
                            queryText: full.plasmoidRoot.query
                            onActivated: {
                                listView.currentIndex = index;
                                full.runIndex(index);
                            }
                            onSelected: {
                                full.userNavigated = true;
                                listView.currentIndex = index;
                                queryField.forceActiveFocus();
                            }
                        }
                    }
                }

                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.gridUnit * 2
                    visible: full.plasmoidRoot.query.length === 0
                    iconName: "search"
                    text: i18n("Type to search")
                    explanation: i18n("Applications, files, settings, calculations and more")
                }

                PlasmaExtras.PlaceholderMessage {
                    anchors.centerIn: parent
                    width: parent.width - Kirigami.Units.gridUnit * 2
                    visible: full.plasmoidRoot.query.length > 0 && !resultModel.querying && listView.count === 0
                    iconName: "edit-none"
                    text: i18n("No results found")
                }
            }

            PreviewPane {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                // Hide on narrow popups; the list alone still works.
                visible: full.popupW >= Kirigami.Units.gridUnit * 32
                result: listView.count > 0 ? listView.currentItem : null
                onOpenRequested: full.runIndex(listView.currentIndex)
                onActionRequested: actionIndex => full.runAction(listView.currentIndex, actionIndex)
            }
        }
    }
}
