/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    // Shared between the pill and the popup.
    property string query: ""

    readonly property string placeholder: Plasmoid.configuration.placeholderText.length > 0
        ? Plasmoid.configuration.placeholderText : i18n("Search")

    // Set by FullRepresentation so we can focus its field on expand.
    property Item queryField: null

    // Caret and selection of the popup's field, mirrored in the pill.
    property int cursorPos: 0
    property int selStart: 0
    property int selEnd: 0

    preferredRepresentation: compactRepresentation

    // Pill height adjustment from the panel (right-click menu, Ctrl+scroll).
    readonly property int heightStep: 4
    readonly property int minPillHeight: 16
    readonly property int maxPillHeight: 120

    // `current` is the height the pill has right now, which is the starting
    // point when the height is still automatic (0).
    function adjustPillHeight(delta, current) {
        const base = Plasmoid.configuration.pillHeight > 0 ? Plasmoid.configuration.pillHeight : Math.round(current);
        Plasmoid.configuration.pillHeight = Math.max(minPillHeight, Math.min(maxPillHeight, base + delta));
    }

    function currentHeight() {
        return compactRepresentationItem ? compactRepresentationItem.currentPillHeight : 0;
    }

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: i18n("Make Pill Taller")
            icon.name: "go-up"
            onTriggered: root.adjustPillHeight(root.heightStep, root.currentHeight())
        },
        PlasmaCore.Action {
            text: i18n("Make Pill Shorter")
            icon.name: "go-down"
            onTriggered: root.adjustPillHeight(-root.heightStep, root.currentHeight())
        },
        PlasmaCore.Action {
            text: i18n("Reset Pill Height")
            icon.name: "edit-undo"
            enabled: Plasmoid.configuration.pillHeight > 0
            onTriggered: Plasmoid.configuration.pillHeight = 0
        }
    ]

    toolTipMainText: i18n("Search")
    toolTipSubText: Plasmoid.globalShortcut.toString().length > 0
        ? i18n("Search with KRunner (%1)", Plasmoid.globalShortcut.toString())
        : i18n("Search with KRunner")

    compactRepresentation: CompactRepresentation {
        plasmoidRoot: root
    }

    fullRepresentation: FullRepresentation {
        plasmoidRoot: root
    }

    onExpandedChanged: {
        if (root.expanded) {
            Qt.callLater(() => {
                if (root.queryField) {
                    root.queryField.forceActiveFocus();
                    root.queryField.cursorPosition = root.queryField.text.length;
                }
            });
        } else {
            query = "";
            cursorPos = 0;
            selStart = 0;
            selEnd = 0;
        }
    }

    Component.onCompleted: {
        // Offer Meta+S once, only if the user has no shortcut configured.
        // The write silently does nothing when kglobalaccel is unavailable
        // or the key is taken, so only mark it done once it actually stuck.
        if (!Plasmoid.configuration.shortcutSuggested) {
            if (Plasmoid.globalShortcut.toString().length === 0) {
                Plasmoid.globalShortcut = "Meta+S";
            }
            if (Plasmoid.globalShortcut.toString().length > 0) {
                Plasmoid.configuration.shortcutSuggested = true;
            }
        }
    }
}
