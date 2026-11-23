// Popup Test: a native dialog with a text box. Cmd+Enter (or Send) pastes the
// text into a Claude Code session, framed as feedback it must not act on.
// Esc / Cancel closes without sending. Opened by `mod.open:popup-test`
// (the my-palette entry "Popup Test").

import { View, div } from "gpui-kit";
import { v_flex, h_flex, TextareaState, Textarea } from "gpui-base";
import { hc, notify, props, closeOverlay, theme, focused } from "herdr";

const HEADLINE = "[Popup Test — FEEDBACK ONLY. Do not act on this: no tool calls, no file changes. Acknowledge in one line.]";

// Which terminal receives the text. `openedFrom` is focused() captured when
// the dialog opened: { space, tab, pane, terminal, cwd, ... }.
// Return a terminal address ("t1p") or null.
// For now: the forge Claude Code session it was built from. Breaks when that
// session ends; swap for a label lookup (terminals()[i].labels) to keep it.
function resolveTarget(_openedFrom) {
  return "t1p";
}

function frame(text) {
  return `${HEADLINE}\n\n${text.trim()}`;
}

export default class PopupTest extends View {
  init(_props, cx) {
    // Snapshot before anything else can move focus.
    this.openedFrom = focused();
    this.text = "";
    this.sent = false;
    this.area = TextareaState.new({ placeholder: "Write something…", rows: 5 });
    this.area.on("change", (_e, cx) => { this.text = this.area.value(); cx.notify(); });
    this.area.on("submit", () => this.submit());
    this.area.focus();
    cx.timer.after(600, () => this.area.focus());
    this.handle = cx.focus_handle();
  }

  close() {
    closeOverlay(props().overlay);
  }

  submit() {
    if (this.sent || !this.text.trim()) return;
    this.sent = true;
    const target = resolveTarget(this.openedFrom);
    const message = frame(this.text);
    this.close();
    if (!target) {
      notify({ title: "Popup Test", body: "No target session, nothing sent.", level: "warning" });
      return;
    }
    // A detached task: the overlay is gone, the send still finishes.
    hc(["send", target, message])
      .then((r) => notify(r.code === 0
        ? { title: "Popup Test", body: `Sent to ${target}`, level: "success", timeout: 2500 }
        : { title: "Popup Test", body: `hc send failed: ${(r.stderr || r.stdout).trim()}`, level: "error" }))
      .catch((e) => notify({ title: "Popup Test", body: `hc send failed: ${e}`, level: "error" }));
  }

  key(e, cx) {
    if (e.keystroke === "escape") { this.close(); cx.stop_propagation(); }
    else if (e.keystroke === "cmd-enter") { this.submit(); cx.stop_propagation(); }
  }

  render() {
    const t = theme();
    const empty = !this.text.trim();
    const button = (id, text, primary, action) => h_flex().id(id).h(32).px(14).items_center().rounded(8)
      .border_1().border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
      .text_color(primary ? t.solid_foreground : t.foreground).text_size(12.5).font_medium().cursor_pointer()
      .when(primary && empty, (el) => el.opacity(0.5))
      .hover((s) => s.opacity(0.88)).on_click(action).child(text);
    return v_flex().id("popup-test").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .w_full().min_h(0).p(18).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center()
        .child(div().flex_1().text_size(15).font_semibold().child("Popup Test"))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(div().pt(6).pb(10).text_size(11.5).text_color(t.dim).child("Sent as feedback: the session is told not to act on it."))
      .child(Textarea.new(this.area).px(10).py(8).rounded(9).border_1().border_color(t.accent)
        .bg(t.background).text_size(12.8).text_color(t.foreground))
      .child(h_flex().pt(16).gap(8).items_center()
        .child(div().flex_1().text_size(11).text_color(t.dim).child("⌘↩ send"))
        .child(button("pt-cancel", "Cancel", false, () => this.close()))
        .child(button("pt-send", "Send", true, () => this.submit())));
  }
}
