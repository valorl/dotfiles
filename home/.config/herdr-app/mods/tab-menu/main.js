// A tab's right-click menu, opened with props { target: { id, space, terminal? } }
// by my-tabs (the tab bar), my-spaces (tab rows) and my-agents (agent rows; terminal:
// that agent). Herdr's tab items plus "Move to", every other space on the tab's
// machine or a new one. With a Claude Code agent there, "Rename session" asks for a
// name and types `/rename <name>` into it: Claude Code renames the session and sets
// its terminal title, which the sidebars show. ↑/↓ move, Enter runs, Esc closes.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, props, closeOverlay, theme, spaces, agents, hc, notify } from "herdr";
import { moveTab, rescue } from "./move.js";

const icon = (name) => `mods/workspace-chrome/${name}.svg`;

// The Claude Code agent to rename: the one asked for, else the tab's most urgent.
// Null: none there (/rename is Claude Code's; other agents don't have it).
const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
function sessionOf(target) {
  const crew = agents().filter((a) => a.tab === target.id && a.app === "claude-code");
  if (target.terminal) return crew.find((a) => a.address === target.terminal) ?? null;
  return crew.reduce((best, a) => (!best || (RANK[a.status] ?? 0) > (RANK[best.status] ?? 0) ? a : best), null);
}

function rows(target) {
  const session = sessionOf(target);
  const all = spaces();
  const src = all.find((s) => s.id === target.space);
  const moves = [
    ...all
      .filter((s) => s.id !== target.space && s.machine === src?.machine)
      .map((s) => ({ label: s.name, icon: "layers", to: s.id })),
    // Alone in its space, a tab moved to a new space would just be its space again.
    ...((src?.tabs.length ?? 0) > 1 ? [{ label: "New space", icon: "folder-plus", to: null }] : []),
  ];
  return [
    ...(session ? [{ label: "Rename session", icon: "square-pen", session }] : []),
    { label: session ? "Rename tab" : "Rename", icon: session ? "file-text" : "square-pen", cmd: ["tab.rename", { id: target.id }] },
    { label: "New tab", icon: "plus", cmd: ["tab.new", { space: target.space }] },
    ...(moves.length ? [{ header: "Move to" }, ...moves] : []),
    { sep: true },
    { label: "Close", icon: "x", cmd: ["tab.close", { id: target.id }] },
  ];
}

export default class TabMenu extends View {
  init(_props, cx) {
    this.at = 0;
    this.moving = null;
    this.track = {};
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  choose(item, cx) {
    if (this.moving || this.renaming) return;
    const { target, overlay } = props();
    if (item.session) return this.startRename(item.session, cx);
    if (item.cmd) {
      closeOverlay(overlay);
      run(...item.cmd);
      return;
    }
    this.moving = item.label;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const move = await moveTab(cx, { tab: target.id, from: target.space, to: item.to }, this.track);
        if (move.left) notify({ title: "Some panes stayed", body: `${move.left} panel pane(s) can't move and stayed in the old tab.`, level: "warning" });
        this.afterMove(move);
      } catch (e) {
        notify({ title: "Couldn't move the tab", body: String(e?.message ?? e), level: "error" });
      }
      closeOverlay(overlay);
    });
  }

  // The menu turns into a one-line prompt, filled with the title it has now.
  startRename(a, cx) {
    const value = (a.title ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();
    const input = InputState.new({ value, placeholder: "Session name" });
    if (value) input.set_selected_range({ start: 0, end: value.length });
    input.on("submit", (_e, cx) => this.rename(cx));
    this.renaming = { address: a.address, input, busy: false, error: null };
    input.focus();
    cx.notify();
  }

  // Types `/rename <name>` + Enter into the agent, only while it waits for a prompt:
  // working, the text would queue as a message; blocked, it could answer the dialog.
  // hc send from the app is plain typing. From inside an agent's terminal
  // (HC_TERMINAL_ID set) it arrives wrapped as a message, and the command doesn't run.
  rename(cx) {
    const r = this.renaming;
    if (r.busy) return;
    const name = r.input.value().replace(/\s+/g, " ").trim();
    if (!name) return closeOverlay(props().overlay);
    const a = agents().find((x) => x.address === r.address);
    r.error = !a ? "That agent is gone."
      : a.status === "working" ? "It's working. Rename it once it's idle."
      : a.status === "blocked" ? "It's waiting on you. Answer it first."
      : null;
    if (r.error) return cx.notify();
    r.busy = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const res = await hc(["send", r.address, `/rename ${name}`]);
        if (res.code !== 0) throw new Error((res.stderr || res.stdout || `hc send exited ${res.code}`).trim());
        closeOverlay(props().overlay);
      } catch (e) {
        r.busy = false;
        r.error = String(e?.message ?? e);
        cx.notify();
      }
    });
  }

  // The tab has landed. move = { from, space, tab, created, sourceClosed, left }:
  // source space id, destination space and tab ids, whether the space is new,
  // whether the source space closed (it was its last tab), mod panes left behind.
  afterMove(move) {
    // Follow the tab to where it went.
    run("space.select", { id: move.space });
    run("tab.select", { id: move.tab });
  }

  // Closed mid-move (a click beside the popup, Esc): don't leave a parked
  // terminal invisible.
  async close() {
    if (this.track.parked) await rescue(this.track.parked);
  }

  render() {
    const t = theme();
    if (this.renaming) {
      const r = this.renaming;
      return v_flex().id("tab-menu").track_focus(this.handle).w_full().p(10).gap(7).bg(t.popover).text_size(12.8)
        .on_key_down((e, cx) => { if (e.key === "escape") { cx.stop_propagation(); closeOverlay(props().overlay); } })
        .child(h_flex().items_center()
          .child(div().flex_1().text_size(11).text_color(t.dim).child("Rename session"))
          .child(div().text_size(10.5).text_color(t.dim).child("Enter · Esc")))
        .child(Input.new(r.input).h(32).px(9).rounded(7).border_1().border_color(t.accent).bg(t.background).text_size(12.8).text_color(t.foreground))
        .child(r.busy
          ? h_flex().gap(7).items_center().text_size(11.5).text_color(t.muted)
              .child(svg(icon("spinner")).size(12).flex_none().text_color(t.working).spin(900)).child("Renaming…")
          : r.error
            ? div().text_size(11.5).text_color(t.blocked).child(r.error)
            : div().text_size(11.5).text_color(t.dim).child("Sends /rename to Claude Code."));
    }
    if (this.moving)
      return v_flex().w_full().p(5).bg(t.popover).text_size(12.8).child(
        h_flex().h(31).px(8).gap(9).items_center().text_color(t.muted)
          .child(svg(icon("spinner")).size(14).flex_none().text_color(t.working).spin(900))
          .child(div().flex_1().truncate().child(`Moving to ${this.moving}…`)));

    const list = rows(props()?.target ?? {});
    const items = list.filter((r) => r.label);
    if (this.at >= items.length) this.at = 0;
    const row = (r) => {
      const i = items.indexOf(r);
      return h_flex().id(`tm-${i}`).h(31).px(8).gap(9).rounded(7).items_center().text_color(t.foreground)
        .when(i === this.at, (el) => el.bg(t.selected))
        .hover((s) => s.bg(t.hover))
        .on_click((_e, cx) => this.choose(r, cx))
        .child(svg(icon(r.icon)).size(14).flex_none().text_color(t.muted))
        .child(div().flex_1().truncate().child(r.label));
    };
    return v_flex().id("tab-menu").track_focus(this.handle).w_full().p(5).bg(t.popover).text_size(12.8)
      .on_key_down((e, cx) => {
        if (e.key === "down") this.at = (this.at + 1) % items.length;
        else if (e.key === "up") this.at = (this.at + items.length - 1) % items.length;
        else if (e.key === "enter") return this.choose(items[this.at], cx);
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
