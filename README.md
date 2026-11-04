# Terminal Glass Glow

A glass theme for Windows Terminal: a blurred, see-through background, a faint glow around text, and the [Obel Mono](https://typographic.systems/obel-mono) font.

Setup is manual and takes about five minutes. It runs no scripts and doesn't need admin rights.

## 1. Install the font

1. Download [the Obel Mono TTF zip](https://typographic.systems/download/ObelMono-1.000-ttf.zip) and extract it.
2. Open the `variable` folder and select both `.ttf` files.
3. Right-click them and choose **Install**, not "Install for all users".

## 2. Add the glow shader

1. Open [`glass-glow.hlsl`](glass-glow.hlsl) and copy its contents.
2. Paste into Notepad and choose **Save as**.
3. Set "Save as type" to **All files** and save it as `C:\Users\YOUR_USERNAME\glass-glow.hlsl`.

## 3. Update Terminal's settings

In Windows Terminal, press `Ctrl+Shift+,` to open `settings.json`. Save a copy of it somewhere first, so you can undo this.

**Replace** the `"defaults": {},` line under `"profiles"` with the block below, and change `YOUR_USERNAME` to your Windows username. If your `defaults` already has settings, keep them alongside these.

```json
"defaults": {
    "colorScheme": "Glass Glow",
    "cursorShape": "filledBox",
    "experimental.pixelShaderPath": "C:\\Users\\YOUR_USERNAME\\glass-glow.hlsl",
    "opacity": 40,
    "padding": "14",
    "useAcrylic": true,
    "font": {
        "face": "Obel Mono",
        "size": 12,
        "features": { "ss01": 1 }
    }
},
```

**Replace** the `"schemes": []` and `"themes": []` lines at the bottom of the file with this block. If you already have your own schemes or themes, add these entries to those lists instead, and add the `"theme"` line separately.

```json
"schemes": [
    {
        "name": "Glass Glow",
        "background": "#080C18",
        "foreground": "#DDE8FF",
        "cursorColor": "#7DF9FF",
        "selectionBackground": "#3A5A8C",
        "black": "#1B2233",
        "red": "#FF5C8A",
        "green": "#5CFFB1",
        "yellow": "#FFD76B",
        "blue": "#5CA8FF",
        "purple": "#B98CFF",
        "cyan": "#5CF2FF",
        "white": "#C9D6F0",
        "brightBlack": "#5E6C8C",
        "brightRed": "#FF8FB0",
        "brightGreen": "#8CFFCB",
        "brightYellow": "#FFE699",
        "brightBlue": "#8CC4FF",
        "brightPurple": "#D2B3FF",
        "brightCyan": "#9CF8FF",
        "brightWhite": "#FFFFFF"
    }
],
"theme": "Glass",
"themes": [
    {
        "name": "Glass",
        "window": { "applicationTheme": "dark", "useMica": false },
        "tabRow": { "background": "#080C1899", "unfocusedBackground": "#080C1899" },
        "tab": {
            "background": "#080C1866",
            "unfocusedBackground": "#00000000",
            "showCloseButton": "hover"
        }
    }
]
```

Save the file, then close all Terminal windows and reopen them. If Terminal shows a settings error, it's usually a missing comma around the pasted blocks.

## If something is blocked

- **Font won't install:** change `"face"` to `"Cascadia Mono"`, which comes with Terminal. You'll lose secret masking and Obel Mono's look.
- **No transparency:** turn on Settings > Personalization > Colors > Transparency effects. Some companies lock this setting.
- **Shader error or no glow:** delete the `experimental.pixelShaderPath` line. Everything else still works.

## Secret masking

The config turns on Obel Mono's `ss01` feature, which shows API keys and similar strings as dots on screen. The real characters stay in the file and your clipboard, so what you see won't always match what you copy. To turn this off, remove `features` from the font settings.

## Adjust it

| What | Where | Setting |
| --- | --- | --- |
| Transparency (lower is clearer) | `settings.json` | `opacity` |
| Glow brightness | `glass-glow.hlsl` | `GLOW_STRENGTH` |
| Glow spread | `glass-glow.hlsl` | `GLOW_RADIUS` |

To undo everything, restore your copy of `settings.json`.

## Credits

Obel Mono is by Typographic Systems, under the SIL Open Font License 1.1. It isn't included in this repo.
