/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_pillWidth: pillWidthSpin.value
    property alias cfg_placeholderText: placeholderField.text
    property alias cfg_showIcon: showIconCheck.checked
    property alias cfg_popupWidth: popupWidthSpin.value
    property alias cfg_popupHeight: popupHeightSpin.value

    // Declared so Plasma's config loader finds every key (avoids warnings).
    property int cfg_pillWidthDefault
    property string cfg_placeholderTextDefault
    property bool cfg_showIconDefault
    property int cfg_popupWidthDefault
    property int cfg_popupHeightDefault
    property bool cfg_shortcutSuggested
    property bool cfg_shortcutSuggestedDefault

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: pillWidthSpin
            Kirigami.FormData.label: i18n("Pill width (grid units):")
            from: 4
            to: 60
        }
        QQC2.TextField {
            id: placeholderField
            Kirigami.FormData.label: i18n("Placeholder text:")
            placeholderText: i18n("Search")
        }
        QQC2.CheckBox {
            id: showIconCheck
            Kirigami.FormData.label: i18n("Icon:")
            text: i18n("Show search icon in the pill")
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: popupWidthSpin
            Kirigami.FormData.label: i18n("Popup width (grid units):")
            from: 14
            to: 80
        }
        QQC2.SpinBox {
            id: popupHeightSpin
            Kirigami.FormData.label: i18n("Popup height (grid units):")
            from: 10
            to: 80
        }
    }
}
