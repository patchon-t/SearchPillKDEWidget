/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 */
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes

KCM.SimpleKCM {
    id: root
    property alias cfg_pillWidth: pillWidthSpin.value
    property alias cfg_pillHeight: pillHeightSpin.value
    property string cfg_iconName
    property alias cfg_placeholderText: placeholderField.text
    property alias cfg_showIcon: showIconCheck.checked
    property alias cfg_popupWidth: popupWidthSpin.value
    property alias cfg_popupHeight: popupHeightSpin.value
    property alias cfg_floatingPopup: floatingCheck.checked
    property alias cfg_popupGap: popupGapSpin.value

    // Declared so Plasma's config loader finds every key (avoids warnings).
    property int cfg_pillHeightDefault
    property string cfg_iconNameDefault
    property int cfg_pillWidthDefault
    property string cfg_placeholderTextDefault
    property bool cfg_showIconDefault
    property int cfg_popupWidthDefault
    property int cfg_popupHeightDefault
    property alias cfg_inlineSearch: inlineCheck.checked
    property bool cfg_inlineSearchDefault
    property bool cfg_floatingPopupDefault
    property int cfg_popupGapDefault
    property bool cfg_shortcutSuggested
    property bool cfg_shortcutSuggestedDefault

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: pillWidthSpin
            Kirigami.FormData.label: i18n("Pill width (grid units):")
            from: 4
            to: 60
        }
        QQC2.SpinBox {
            id: pillHeightSpin
            Kirigami.FormData.label: i18n("Pill height (pixels):")
            from: 0
            to: 120
            // 0 = follow the panel thickness.
            textFromValue: (value, locale) => value === 0 ? i18n("Automatic") : Number(value).toLocaleString(locale, "f", 0)
            valueFromText: (text, locale) => text === i18n("Automatic") ? 0 : Number.fromLocaleString(locale, text)
            editable: true
        }
        QQC2.TextField {
            id: placeholderField
            Kirigami.FormData.label: i18n("Placeholder text:")
            placeholderText: i18n("Search")
        }
        QQC2.CheckBox {
            id: showIconCheck
            Kirigami.FormData.label: i18n("Icon:")
            text: i18n("Show icon in the pill")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Icon:")
            enabled: showIconCheck.checked
            spacing: Kirigami.Units.smallSpacing

            QQC2.Button {
                id: iconButton
                icon.name: root.cfg_iconName.length > 0 ? root.cfg_iconName : "search"
                text: root.cfg_iconName.length > 0 ? root.cfg_iconName : "search"
                onClicked: iconDialog.open()
            }
            QQC2.Button {
                icon.name: "edit-undo"
                text: i18n("Reset")
                enabled: root.cfg_iconName !== "search"
                onClicked: root.cfg_iconName = "search"
            }
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
        QQC2.CheckBox {
            id: inlineCheck
            Kirigami.FormData.label: i18n("Typing:")
            text: i18n("Type in the pill (no search bar in the popup)")
        }
        QQC2.CheckBox {
            id: floatingCheck
            Kirigami.FormData.label: i18n("Popup position:")
            text: i18n("Float away from the panel and screen edges")
        }
        QQC2.SpinBox {
            id: popupGapSpin
            Kirigami.FormData.label: i18n("Floating gap (pixels):")
            enabled: floatingCheck.checked
            from: 0
            to: 64
        }
    }

    KIconThemes.IconDialog {
        id: iconDialog
        onIconNameChanged: iconName => {
            if (iconName.length > 0) {
                root.cfg_iconName = iconName;
            }
        }
    }
}
