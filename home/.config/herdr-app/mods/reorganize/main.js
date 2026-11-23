// Re-organize: which spaces are in Focus and which in Standby. Lists every space in
// either (Sandbox and Archive stay as they are), the ones in Focus checked. Check what
// you're on: Apply puts the checked ones in Focus and the rest in Standby.
// Or say it: the box sends your words and the list to Haiku, which checks them for
// you; nothing moves before Apply (Enter again in the box applies).
// Opened by `mod.open:reorganize` (my-palette "Re-organize spaces", the list button
// on my-spaces' Focus card).
//
// Sections: shared "space.sections" { of: { space id: section id } }; ids and the one
// new spaces get are the same as in my-spaces and space-menu.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { spaces, agents, shared, setShared, theme, props, closeOverlay, exec, home } from "herdr";

const HOME = "focus";
const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };
const PICK = JSON.stringify({
  type: "object", additionalProperties: false, required: ["focus", "reason"],
  properties: { focus: { type: "array", items: { type: "integer" } }, reason: { type: "string" } },
});

// What Haiku is told before the list and your words. It answers `focus`: the numbers
// of the spaces for Focus (every other listed one goes to Standby), and `reason`.
// TODO(human)
const RULES = [
  "You sort a person's workspaces (\"spaces\") into Focus and Standby from their request.",
  "Focus: the spaces the request says they're working on now. Standby: every other listed space.",
  "Read the request against where each space is now: \"also X\" or \"drop Y\" changes the current Focus; a plain description of their work replaces it.",
  "A space can be meant by its name, its branch or what its tabs are about; match loosely.",
  "focus: the numbers of the spaces for Focus. reason: one short sentence.",
].join("\n");

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();
const sectionOf = (id) => {
  const s = (shared("space.sections")?.of ?? {})[id];
  return s === "focus" || s === "standby" || s === "sandbox" || s === "archive" ? s : HOME;
};

// What a space's tabs are about: each agent's own title where it says something,
// else a name someone gave the tab.
function topics(space, ags) {
  const out = [];
  for (const tab of space.tabs ?? []) {
    const said = [];
    for (const a of ags.filter((x) => x.tab === tab.id)) {
      const raw = (a.title ?? "").trim();
      const t = clean(raw);
      if (t && !/^[~/]/.test(raw) && !t.includes("@") && t !== a.program?.name) said.push(t);
    }
    out.push(...(said.length ? said : tab.named ? [tab.name] : []));
  }
  return [...new Set(out)];
}

async function askHaiku(text, list) {
  const lines = list.map((s, i) =>
    `${i + 1}. ${s.name} (now in ${s.was === "focus" ? "Focus" : "Standby"})` +
    (s.branch ? `, branch ${s.branch}` : "") +
    (s.topics.length ? `, tabs: ${s.topics.map((x) => `"${x}"`).join(", ")}` : ""));
  const prompt = [RULES, "", "<spaces>", ...lines, "</spaces>", "", "<request>", text, "</request>"].join("\n");
  const args = ["-p", prompt, "--model", "haiku", "--effort", "low", "--tools", "", "--strict-mcp-config",
    "--no-session-persistence", "--output-format", "json", "--json-schema", PICK];
  // stdin closed: with an open, empty stdin, `claude -p` waits 3 s for input first.
  const r = await exec("/bin/sh", ["-c", 'exec claude "$@" </dev/null', "sh", ...args], { cwd: home() });
  if (r.code !== 0) throw new Error(`Haiku failed: ${(r.stderr || r.stdout).trim().split("\n").slice(-2).join(" ")}`);
  const d = JSON.parse(r.stdout).structured_output;
  if (!d) throw new Error("Haiku gave no answer");
  return d;
}

export default class Reorganize extends View {
  init(_props, cx) {
    const ags = agents();
    // As it was on opening: what's moved while this is open stays put.
    this.list = spaces()
      .filter((s) => ["focus", "standby"].includes(sectionOf(s.id)))
      .map((s) => ({ id: s.id, name: s.name, branch: s.branch, color: (shared("space.colors") ?? {})[s.id], topics: topics(s, ags), was: sectionOf(s.id) }));
    this.picked = new Set(this.list.filter((s) => s.was === "focus").map((s) => s.id));
    this.at = 0;
    this.asking = false;
    this.answered = null; // the words Haiku's pick is for
    this.note = null;
    this.error = null;
    this.input = InputState.new({ placeholder: "Or say what you're on, and Haiku picks…" });
    this.input.on("submit", (_e, cx) => this.submit(cx));
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  toggle(id) {
    if (this.picked.has(id)) this.picked.delete(id);
    else this.picked.add(id);
  }

  apply() {
    const of = { ...(shared("space.sections")?.of ?? {}) };
    for (const s of this.list) of[s.id] = this.picked.has(s.id) ? "focus" : "standby";
    setShared("space.sections", { of });
    closeOverlay(props()?.overlay);
  }

  // Enter in the box: ask Haiku; again with the same words: apply its pick.
  submit(cx) {
    const text = this.input.value().trim();
    if (!text || this.asking) return;
    if (text === this.answered) return this.apply();
    this.asking = true;
    this.error = null;
    this.note = null;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const d = await askHaiku(text, this.list);
        this.picked = new Set(d.focus.map((n) => this.list[n - 1]?.id).filter(Boolean));
        this.answered = text;
        this.note = d.reason;
      } catch (e) {
        this.error = String(e?.message ?? e);
      }
      this.asking = false;
      cx.notify();
    });
  }

  row(s, i, t) {
    const on = this.picked.has(s.id);
    const moves = (on ? "focus" : "standby") !== s.was;
    const fill = s.color ? (s.color.startsWith("#") ? s.color : (MARK[s.color] ?? t[s.color])) : t.dim;
    return h_flex()
      .id(`re-${i}`)
      .h(42)
      .flex_none()
      .px(8)
      .gap(10)
      .rounded(7)
      .items_center()
      .cursor_pointer()
      .when(i === this.at, (el) => el.bg(t.selected))
      .hover((st) => st.bg(t.hover))
      .on_click((_e, cx) => {
        this.at = i;
        this.toggle(s.id);
        this.handle.focus();
        cx.notify();
      })
      .child(h_flex().size(16).flex_none().rounded(4).border(1.5).items_center().justify_center()
        .border_color(on ? t.accent : t.input).when(on, (el) => el.bg(t.accent))
        .when(on, (el) => el.child(svg("mods/workspace-chrome/check.svg").size(11).text_color(t.accent_foreground))))
      .child(h_flex().size(18).flex_none().rounded(5).bg(fill).items_center().justify_center()
        .text_size(10.5).font_bold().text_color("#ffffff").child([...s.name][0]?.toUpperCase() ?? "?"))
      .child(v_flex().flex_1().min_w(0)
        .child(div().truncate().text_size(13).text_color(t.foreground).child(s.name))
        .when(s.topics.length > 0, (el) => el.child(div().truncate().text_size(11.5).text_color(t.dim).child(s.topics.join(" · ")))))
      .when(moves, (el) => el.child(div().flex_none().text_size(11).text_color(t.accent).child(on ? "→ Focus" : "→ Standby")));
  }

  render() {
    const t = theme();
    const focus = this.list.filter((s) => this.picked.has(s.id)).length;
    const button = (id, label, primary) =>
      div().id(id).h(28).px(12).flex().items_center().rounded(7).text_size(12.5).cursor_pointer()
        .when(primary, (el) => el.bg(t.solid).text_color(t.solid_foreground))
        .when(!primary, (el) => el.border(1).border_color(t.border).text_color(t.muted).hover((s) => s.bg(t.hover)))
        .child(label);
    const status = this.asking
      ? h_flex().gap(7).items_center().text_color(t.muted)
          .child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)).child("Asking Haiku…")
      : this.error
        ? div().text_color(t.blocked).child(this.error)
        : this.note
          ? div().text_color(t.muted).child(`${this.note} Enter again to apply.`)
          : null;

    return v_flex().id("reorganize").w_full().p(18).gap(12).bg(t.popover).text_color(t.foreground)
      .on_key_down((e, cx) => {
        if (e.key === "escape") { cx.stop_propagation(); closeOverlay(props()?.overlay); }
      })
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(14).font_semibold().child("Re-organize"))
        .child(div().text_size(11.5).text_color(t.dim).child(`Focus ${focus} · Standby ${this.list.length - focus}`)))
      .child(Input.new(this.input).h(34).px(10).rounded(8).border_1().border_color(t.input).bg(t.background).text_size(12.8).text_color(t.foreground))
      .when(Boolean(status), (el) => el.child(div().text_size(11.5).child(status)))
      .child(this.list.length
        ? v_flex().id("re-list").track_focus(this.handle).max_h(400).overflow_y_scrollbar()
            .on_key_down((e, cx) => {
              const n = this.list.length;
              if (e.key === "down") this.at = (this.at + 1) % n;
              else if (e.key === "up") this.at = (this.at + n - 1) % n;
              else if (e.key === "space" || e.key_char === " ") this.toggle(this.list[this.at].id);
              else if (e.key === "enter") return this.apply();
              else return;
              cx.stop_propagation();
              cx.notify();
            })
            .children(this.list.map((s, i) => this.row(s, i, t)))
        : div().track_focus(this.handle).py(16).text_size(12.5).text_color(t.dim).child("Nothing in Focus or Standby."))
      .child(h_flex().items_center().gap(8)
        .child(div().flex_1().text_size(11).text_color(t.dim).child("Checked go to Focus, the rest to Standby"))
        .child(button("re-cancel", "Cancel", false).on_click(() => closeOverlay(props()?.overlay)))
        .child(button("re-apply", "Apply", true).on_click(() => this.apply())));
  }
}
