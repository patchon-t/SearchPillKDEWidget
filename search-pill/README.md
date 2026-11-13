# Search Pill

A Windows 11 style search box for the KDE Plasma 6 panel. It shows a rounded pill with a search icon and a "Search" placeholder. Clicking the pill, or pressing the widget's global shortcut, opens a Windows 11 style search popup: a search bar, filter tabs (All, Apps, Files, Settings), a results list with a "Best match" on top, and a preview card with actions for the selected result. The results (apps, files, settings, calculator and so on) come from KRunner through `org.kde.milou`; the popup UI itself is custom.

## Requirements

- KDE Plasma 6.0 or newer (Qt 6, KDE Frameworks 6)
- `milou`, which is installed with Plasma on most distributions
- `kpackagetool6`, needed only for `install.sh`

## Install

```bash
./install.sh              # install or upgrade, then restart plasmashell
./install.sh --no-restart # install or upgrade only
```

To uninstall: `kpackagetool6 -t Plasma/Applet --remove com.techbypatch.searchpill`

## Add it to the panel

Right-click the panel, choose **Add or Manage Widgets…**, search for **Search Pill** and drag it onto the panel. On a vertical panel the widget shows only a search icon.

## Keyboard shortcut

The first time the widget loads, it tries to set **Meta+S** as its global shortcut, but only if no shortcut is set yet and Meta+S is free. To change or remove it, right-click the widget, choose **Configure Search Pill…** and open the **Keyboard Shortcuts** page.

Keys in the popup:

| Key | Action |
| --- | --- |
| Up / Down | Move the selection |
| Enter | Run the selected result |
| Shift+Enter | Run the first extra action of the selected result |
| Tab / Shift+Tab | Switch filter tab |
| Esc | Clear the query and close the popup |

When the pill has keyboard focus (Tab to it), typing a letter opens the popup with that letter already in the field. Enter or Down opens the popup without typing anything.

Clicking a result runs it. Clicking the arrow at the end of a row only selects it, so you can look at its preview and actions.

## Configuration (General page)

| Option | Default | Meaning |
| --- | --- | --- |
| Pill width | 12 grid units | Width of the pill on a horizontal panel |
| Placeholder text | *(empty)* | Text shown in the empty pill. If empty, the translated word "Search" is used |
| Show search icon | on | Shows the magnifier icon inside the pill |
| Popup width / height | 44 × 32 grid units | Size of the search popup. Below 32 units wide the preview card is hidden |
| Float popup | on, 12 px gap | Detaches the popup from the panel and screen edges, like the Windows 11 search flyout |

## Troubleshooting

Watch the plasmashell log for errors from the widget:

```bash
journalctl --user -b -f | grep -i -E 'searchpill|qml'
```

If **no results** appear, check that KRunner itself returns results (Alt+Space), and look at which search plugins are enabled in **System Settings → Search → Plasma Search**.

To test the widget without restarting the panel, run `plasmawindowed com.techbypatch.searchpill` (included in `plasma-sdk`).
