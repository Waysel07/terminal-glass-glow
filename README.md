# Terminal Glass Glow

A glass theme for Windows Terminal: a blurred, see-through background, a faint glow around text, and the [Obel Mono](https://typographic.systems/obel-mono) font.

## Install

You need Windows Terminal, opened at least once. Admin rights aren't required.

```powershell
gh repo clone Waysel07/terminal-glass-glow
cd terminal-glass-glow
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

Then close all Terminal windows and reopen them.

The installer:

- downloads Obel Mono from typographic.systems and installs it for your user account
- backs up `settings.json` next to the original as `settings.json.glass-backup-<timestamp>`
- adds the theme to your existing settings and keeps your keybindings and profiles

Comments in `settings.json` are lost when the installer rewrites it; the backup keeps them. Settings on an individual profile, such as its own font or opacity, override the theme for that profile.

## Secret masking

The config turns on Obel Mono's `ss01` feature, which shows API keys and similar strings as dots on screen. The real characters stay in the file and your clipboard, so what you see won't always match what you copy. To turn this off, remove `features` from the font settings.

## Adjust it

| What | Where | Setting |
| --- | --- | --- |
| Transparency (lower is clearer) | `settings.json` | `opacity` |
| Glow brightness | `glass-glow.hlsl` | `GLOW_STRENGTH` |
| Glow spread | `glass-glow.hlsl` | `GLOW_RADIUS` |

The shader file is copied into Terminal's settings folder, so edit that copy. To remove just the glow, delete `experimental.pixelShaderPath` from `settings.json`.

To undo everything, restore the backup over `settings.json`.

## Credits

Obel Mono is by Typographic Systems, under the SIL Open Font License 1.1. It's downloaded during install and isn't included in this repo.
