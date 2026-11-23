# herdr — modifying the Herdr app

Sessions here change **Herdr** (the desktop app for terminals and agents): its layouts,
keys, settings, programs and mods. The work happens in `~/.config/herdr-app/`, not in this
folder. This folder is standalone: it only holds this file and its `.claude/` settings,
which keep the parent folder's CLAUDE.md out of these sessions.

## Read first

**Read `~/.config/herdr-app/AGENTS.md` in full before changing anything.** It's the app's
own manual: the files and what each controls, the spaces/tabs/panes model, commands, mods,
and how to check changes. Herdr rewrites it on every start, so read it fresh each session;
don't rely on memory of an earlier copy.

The type files next to it are the truth for mod APIs: `herdr.d.ts` (app data and commands)
and `gpui-kit.d.ts` (UI elements). Grep them rather than guessing a method name.

Also useful: `herdr-app --skill` (driving the window), `hc --skill` (herdr-core: terminals
and agents), `herdr-app commands` (every command and its arguments).

## What's whose

| Mine (edit freely) | Herdr's (clone with `mod.clone` before changing structure) |
|---|---|
| mods `bootstrap`, `my-agents`, `my-palette`, `my-spaces`, `my-tabs`, `popup-test`, `reorganize`, `space-menu`, `tab-menu`; layout `my-main` | everything listed in `installed.json` |

- `bootstrap` is the session launcher (⌘⇧P → Bootstrap); its header comment describes the
  flow. Prompt mode runs Haiku in `~/forge/session-spawner/`, whose `CLAUDE.md` holds the
  extraction rules — a dependency of the mod, nothing more.
- New palette entries go in `my-palette/main.js`, in `NAMED`, tagged `// my-palette`.

## Working rules

- `~/.config/herdr-app/` is a stow link into `~/repos/github.com/valorl/dotfiles`
  (`home/.config/herdr-app/`), and so are this file, its `.claude/settings.json` and
  `~/forge/session-spawner/CLAUDE.md`. Git is the backup: no `.bak` copies; commit only
  when I ask. That folder's `.gitignore` is an allowlist: a new mod of mine is untracked
  until its folder is added there.
- Copy a whole mod folder only to somewhere outside `mods/`: a folder there with a
  `main.js` loads as another mod.
- After every mod change: `herdr-app check ~/.config/herdr-app/mods/<name>` must pass,
  then `herdr-app status` must show no errors. A check only renders the first frame, so
  grep the `.d.ts` files for every method used in later states (lists, dialogs' second
  steps) and say what's still untested in the app.
- `herdr-app shot` captures the window as a PNG when you need to see a layout or mod.
- Don't edit `AGENTS.md` or the `.d.ts` files there; Herdr overwrites them.
- `ctrl-alt-shift-escape` resets the shown layout and `keys.json` if a change locks me out.
