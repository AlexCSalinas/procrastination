# Procrastination

A macOS menu bar app that pops up a "back to work" panel when you've been on YouTube (or any site you list) in Chrome for too long.

- Watches Chrome's active tab only when Chrome is frontmost (never launches Chrome).
- Grace period before the popup, cooldown after it; both configurable.
- Study allowlist: tabs whose title contains e.g. "lecture" or "tutorial" are ignored.
- Floating always-on-top panel that appears over every app, Space, and full-screen window.
- Menu bar icon: enable/disable, test popup, settings, launch at login.

## Install

Requires macOS 13+ and Xcode command line tools.

```sh
./install.sh   # builds, copies to /Applications, launches
```

On first run macOS asks to let Procrastination control Google Chrome; approve it
(System Settings → Privacy & Security → Automation if you missed it).

`./build.sh` builds to `build/` without installing.
