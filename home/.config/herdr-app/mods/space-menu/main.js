// A space's right-click menu in my-spaces, opened as a popup with props
// { tab: "space", target: { id } }: Herdr's items (Rename, the worktree ones, Close)
// plus "Move to": every other section. ↑/↓ move, Enter runs, Esc closes.
//
// Sections: shared "space.sections" { of: { space id: section id } }. The four and
// the one new spaces get are the same as in my-spaces and reorganize. This menu only
// writes that; my-spaces draws the sections and keeps the real order (⌃1–⌃9) in step.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, openOverlay, theme, spaces, panes, exec, shared, setShared } from "herdr";

const SECTIONS = [
  { id: "focus", name: "Focus", icon: "mods/my-spaces/target.svg" },
  { id: "standby", name: "Standby", icon: "clock" },
  { id: "sandbox", name: "Sandbox", icon: "square" },
  { id: "archive", name: "Archive", icon: "archive" },
];
const HOME = "focus";

const icon = (name) => (name.endsWith(".svg") ? name : `mods/workspace-chrome/${name}.svg`);

// Where a space is now: its first terminal's live folder, else where it was made.
function place(s) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return panes().find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}

// A space's checkout: "main" (a repo's own), "linked" (a worktree), or null.
async function checkout(folder, on) {
  const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd: folder, on });
  const common = await exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd: folder, on });
  if (top.code !== 0 || common.code !== 0) return null;
  return common.stdout.trim() === `${top.stdout.trim()}/.git` ? "main" : "linked";
}

function rows(id, git) {
  const of = shared("space.sections")?.of ?? {};
  const mine = SECTIONS.some((s) => s.id === of[id]) ? of[id] : HOME;
  const worktree = (action) => ({ space: id, action });
  return [
    { label: "Rename", icon: "square-pen", cmd: ["space.rename", { id }] },
    ...(git
      ? [
          { label: "New worktree", icon: "git-branch", worktree: worktree("new") },
          { label: "Open worktree", icon: "git-branch", worktree: worktree("open") },
        ]
      : []),
    ...(git === "linked" ? [{ label: "Remove worktree", icon: "git-branch", worktree: worktree("remove") }] : []),
    { header: "Move to" },
    ...SECTIONS.filter((s) => s.id !== mine).map((s) => ({ label: s.name, icon: s.icon, to: s.id })),
    { sep: true },
    { label: "Close", icon: "x", cmd: ["space.close", { id }] },
  ];
}

export default class SpaceMenu extends View {
  init(_props, cx) {
    this.at = 0;
    this.git = null;
    this.handle = cx.focus_handle();
    this.handle.focus();
    const p = props();
    const space = spaces().find((s) => s.id === p?.target?.id);
    const folder = space && place(space);
    if (folder)
      cx.spawn(async (cx) => {
        this.git = await checkout(folder, space.machine).catch(() => null);
        cx.notify();
      });
  }

  choose(item) {
    if (!item) return;
    const { target, overlay } = props();
    closeOverlay(overlay);
    if (item.cmd) return run(...item.cmd);
    if (item.worktree)
      return openOverlay({ mod: "worktree", kind: "dialog", ...(item.worktree.action === "open" ? { width: 560, height: 480 } : { width: 440, height: 260 }), props: item.worktree });
    const of = shared("space.sections")?.of ?? {};
    setShared("space.sections", { of: { ...of, [target.id]: item.to } });
  }

  render() {
    const t = theme();
    const list = rows(props()?.target?.id, this.git);
    const items = list.filter((r) => r.label);
    if (this.at >= items.length) this.at = 0;
    const row = (r) => {
      const i = items.indexOf(r);
      return h_flex().id(`sm-${i}`).h(31).px(8).gap(9).rounded(7).items_center().text_color(t.foreground)
        .when(i === this.at, (el) => el.bg(t.selected))
        .hover((s) => s.bg(t.hover))
        .on_click(() => this.choose(r))
        .child(svg(icon(r.icon)).size(14).flex_none().text_color(t.muted))
        .child(div().flex_1().truncate().child(r.label));
    };
    return v_flex().id("space-menu").track_focus(this.handle).w_full().p(5).bg(t.popover).text_size(12.8)
      .on_key_down((e, cx) => {
        if (e.key === "down") this.at = (this.at + 1) % items.length;
        else if (e.key === "up") this.at = (this.at + items.length - 1) % items.length;
        else if (e.key === "enter") return this.choose(items[this.at]);
        else if (e.key === "escape") return closeOverlay(props().overlay);
        else return;
        cx.notify();
      })
      .children(list.map((r) =>
        r.sep ? div().mx(7).my(4).h(1).bg(t.border)
        : r.header ? div().px(8).pt(6).pb(3).text_size(11).text_color(t.dim).child(r.header)
        : row(r)));
  }
}
