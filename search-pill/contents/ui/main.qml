/*
 * SPDX-License-Identifier: GPL-2.0-or-later
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

    preferredRepresentation: compactRepresentation

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
