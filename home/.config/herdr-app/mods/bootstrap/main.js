// Bootstrap: start a Claude Code session in the right place, from a form or a message.
//   Form   pick (fuzzy) or create a space, a repo or scratch folder, and a worktree; add an
//          optional first message; Start.
//   Prompt type a message; Haiku (~/forge/session-spawner, rules in its CLAUDE.md) pulls the
//          space, repo and worktree out of it and fills the form. Nothing starts before Start.
// Tabs are named after their repo or folder. New repos: `git init` under ~/repos/github.com/<org>.
// New worktrees: <repo>.<branch-slug> beside the repo, from origin's default branch.
// Opened by `mod.open:bootstrap` (my-palette: "Bootstrap").

import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input, TextareaState, Textarea } from "gpui-base";
import { exec, run, notify, props, closeOverlay, theme, spaces, home } from "herdr";

// Orgs under ~/repos/github.com to offer: one per line in `orgs.local` beside this file,
// kept out of the dotfiles (see .gitignore). Without it, only DEFAULT_ORG.
const DEFAULT_ORG = "valorl";
const ORGS_FILE = (h) => `${h}/.config/herdr-app/mods/bootstrap/orgs.local`;
let ORGS = [DEFAULT_ORG];
const REPOS = (h) => `${h}/repos/github.com`;
const SCRATCH = (h) => `${h}/scratch/agents`;
const SPAWNER = (h) => `${h}/forge/session-spawner`;
const SESSION = ["claude"]; // what runs in the new tab
const LIST_MAX = 6;
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

const EXTRACT = JSON.stringify({
  type: "object", additionalProperties: false, required: ["space", "repo", "worktree"],
  properties: { space: { type: "string" }, repo: { type: "string" }, worktree: { type: "string" } },
});

const tail = (r) => (r.stderr || r.stdout).trim().split("\n").slice(-3).join(" ");
const basename = (p) => p.split("/").pop();
const tilde = (p, h) => (p.startsWith(h) ? `~${p.slice(h.length)}` : p);
const message = (e) => String(e?.message ?? e);
const clean = (s) => s.trim().replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^-+|-+$/g, "");
const dirSlug = (branch) => branch.replace(/[^A-Za-z0-9._-]+/g, "-");

async function ls(dir) {
  const r = await exec("/bin/ls", ["-1", dir]).catch(() => null);
  return r?.code === 0 ? r.stdout.split("\n").filter(Boolean) : [];
}
const exists = async (path) => (await exec("/bin/test", ["-e", path])).code === 0;
const must = async (p) => { const r = await p; if (r.code !== 0) throw new Error(tail(r)); return r; };
// git without prompts: a fetch that wants a password fails instead of hanging.
const git = (cwd, args) => exec("/usr/bin/env",
  ["GIT_TERMINAL_PROMPT=0", "GIT_SSH_COMMAND=ssh -o BatchMode=yes", "git", ...args], { cwd });

const localSpaces = () => spaces().filter((s) => !s.machine);
const spaceNamed = (name) => localSpaces().find((s) => s.name === name);

function readMode() { try { return localStorage.getItem("mode") === "prompt" ? "prompt" : "form"; } catch (_e) { return "form"; } }
function saveMode(m) { try { localStorage.setItem("mode", m); } catch (_e) { /* per-viewer nicety only */ } }

// ── Matching ────────────────────────────────────────────────────────────────

// How well `query` matches `text`: a number (higher ranks first), or null for no match.
function fuzzy(query, text) {
  // TODO(human)
  const i = text.toLowerCase().indexOf(query.toLowerCase());
  return i < 0 ? null : -i;
}

function rank(query, options) {
  const q = query.trim();
  if (!q) return options;
  return options.map((o) => ({ o, s: fuzzy(q, o.text) })).filter((x) => x.s !== null)
    .sort((a, b) => b.s - a.s).map((x) => x.o);
}

// ── Options ─────────────────────────────────────────────────────────────────
// Every option: { kind, text (what the field shows once picked), label (list row), hint?, create? }.

async function loadOrgs(h) {
  const r = await exec("/bin/cat", [ORGS_FILE(h)]).catch(() => null);
  const orgs = r?.code === 0 ? r.stdout.split("\n").map((s) => s.trim()).filter((s) => s && !s.startsWith("#")) : [];
  return orgs.length ? orgs : [DEFAULT_ORG];
}

// Repos (not their <repo>.<branch> worktree siblings) and scratch folders.
async function loadTargets(h) {
  ORGS = await loadOrgs(h);
  const out = [];
  for (const org of ORGS) {
    const names = await ls(`${REPOS(h)}/${org}`);
    for (const n of names) {
      if (n.includes(".") && names.includes(n.split(".")[0])) continue;
      out.push({ kind: "repo", text: `${org}/${n}`, label: `${org}/${n}`, path: `${REPOS(h)}/${org}/${n}` });
    }
  }
  for (const n of await ls(SCRATCH(h))) {
    out.push({ kind: "scratch", text: `scratch/${n}`, label: `scratch/${n}`, hint: "folder", path: `${SCRATCH(h)}/${n}` });
  }
  // A bare name ("infra") stands for its entry when only one entry has it.
  const names = out.map((o) => basename(o.path).toLowerCase());
  out.forEach((o, i) => { if (names.indexOf(names[i]) === names.lastIndexOf(names[i])) o.aliases = [names[i]]; });
  return out;
}

const repoCreate = (h, org, name) => ({ kind: "new-repo", create: true, text: `${org}/${name}`,
  label: `+ Create ${org}/${name}`, hint: "git init", path: `${REPOS(h)}/${org}/${name}` });
const scratchCreate = (h, name) => ({ kind: "new-scratch", create: true, text: `scratch/${name}`,
  label: `+ Create scratch/${name}`, hint: "new folder", path: `${SCRATCH(h)}/${name}` });

// `org/name` → that org; `scratch/name` → a scratch folder; a bare name → either.
function repoCreates(h, t) {
  const slash = t.indexOf("/");
  const org = slash < 0 ? null : t.slice(0, slash);
  const name = clean(slash < 0 ? t : t.slice(slash + 1));
  if (!name) return [];
  if (org === "scratch") return [scratchCreate(h, name)];
  if (org) return ORGS.includes(org) ? [repoCreate(h, org, name)] : [];
  return [repoCreate(h, DEFAULT_ORG, name), scratchCreate(h, name)];
}

// A repo's checkouts, main first.
async function loadWorktrees(repo) {
  const r = await git(repo, ["worktree", "list", "--porcelain"]);
  if (r.code !== 0) return [];
  return r.stdout.trim().split("\n\n").map((block, i) => {
    const lines = block.split("\n");
    const path = lines.find((l) => l.startsWith("worktree "))?.slice(9) ?? "";
    const branch = lines.find((l) => l.startsWith("branch "))?.slice(7).replace(/^refs\/heads\//, "") ?? "detached";
    return { kind: "worktree", main: i === 0, path, text: branch, label: branch,
      aliases: [basename(path).toLowerCase()], hint: i === 0 ? "main checkout" : basename(path) };
  }).filter((w) => w.path);
}

// ── Router ──────────────────────────────────────────────────────────────────

async function extract(text, spaceNames, targets, h) {
  const prompt = ["<options>",
    `Spaces: ${spaceNames.join(", ") || "(none)"}`,
    "Repos and scratch folders:", ...targets.map((t) => `- ${t}`),
    "</options>", "", "<message>", text, "</message>"].join("\n");
  const args = ["-p", prompt, "--model", "haiku", "--effort", "low", "--tools", "", "--strict-mcp-config",
    "--no-session-persistence", "--output-format", "json", "--json-schema", EXTRACT];
  // stdin closed: with an open, empty stdin, `claude -p` waits 3 s for input first.
  const r = await exec("/bin/sh", ["-c", 'exec claude "$@" </dev/null', "sh", ...args], { cwd: SPAWNER(h) });
  if (r.code !== 0) throw new Error(`Haiku failed: ${tail(r)}`);
  const d = JSON.parse(r.stdout).structured_output;
  if (!d) throw new Error("Haiku gave no answer");
  return d;
}

// ── Launch ──────────────────────────────────────────────────────────────────

// New worktree beside the repo; an existing branch is checked out, a new one starts from origin.
async function addWorktree(repo, name) {
  const branch = name.trim().replace(/[^A-Za-z0-9._/-]+/g, "-");
  const base = (await git(repo, ["symbolic-ref", "--short", "refs/remotes/origin/HEAD"])).stdout.trim();
  if (base) await git(repo, ["fetch", "--quiet", "origin", base.replace(/^origin\//, "")]).catch(() => null);
  let path = `${repo}.${dirSlug(branch)}`;
  for (let n = 2; n < 20 && await exists(path); n++) path = `${repo}.${dirSlug(branch)}-${n}`;
  const has = (await git(repo, ["show-ref", "--verify", "--quiet", `refs/heads/${branch}`])).code === 0;
  await must(git(repo, has ? ["worktree", "add", path, branch] : ["worktree", "add", "-b", branch, path, base || "HEAD"]));
  return path;
}

// A tab name the space doesn't use yet: `preferred`, else `fallback`, else numbered.
function freeTab(space, preferred, fallback) {
  const used = new Set((space?.tabs ?? []).map((t) => t.name));
  for (const name of [preferred, fallback].filter(Boolean)) if (!used.has(name)) return name;
  let n = 2;
  while (used.has(`${preferred} ${n}`)) n++;
  return `${preferred} ${n}`;
}

// Make what the form asks for, then start the session there. Herdr shows the new tab at once.
async function launch({ space, target, wt, task }, stage) {
  let folder = target.path;
  if (target.kind === "new-repo") {
    stage(`git init ${target.text}…`);
    await must(exec("/bin/mkdir", ["-p", folder]));
    await must(git(folder, ["init", "--quiet"]));
  } else if (target.kind === "new-scratch") {
    await must(exec("/bin/mkdir", ["-p", folder]));
  } else if (wt?.kind === "worktree") {
    folder = wt.path;
  } else if (wt?.kind === "new-worktree") {
    stage(`Creating worktree ${wt.text}…`);
    folder = await addWorktree(target.path, wt.text);
  }
  const existing = spaceNamed(space.text); // by name again: it may have opened or closed meanwhile
  const tab = freeTab(existing, basename(target.path), basename(folder));
  const session = { folder, argv: SESSION, ...(task ? { task } : {}) };
  if (existing) {
    run("space.select", { id: existing.id });
    run("tab.new", { space: existing.id, name: tab, ...session });
  } else {
    run("space.new", { name: space.text, tab, ...session });
  }
  return `${space.text} / ${tab}`;
}

// ── Field ───────────────────────────────────────────────────────────────────

// A text field with a fuzzy list under it: pick an option, or create one from the text.
class Combo {
  constructor(owner, key, placeholder, { options, creates, empty }) {
    Object.assign(this, { owner, key, options, creates, empty, text: "", value: null, at: 0, open: false });
    this.input = InputState.new({ placeholder });
    this.input.on("change", (_e, cx) => {
      this.text = this.input.value();
      if (this.value && this.text !== this.value.text) this.value = null;
      this.at = 0;
      this.open = true;
      cx.notify();
    });
    this.input.on("focus", (_e, cx) => owner.focused(this, cx));
    this.input.on("submit", (_e, cx) => owner.enter(this, cx));
  }

  exact() {
    const t = this.text.trim().toLowerCase();
    return t ? this.options().find((o) => o.text.toLowerCase() === t || o.aliases?.includes(t)) : undefined;
  }

  // Best matches, then the ways to create the text when nothing matches it exactly.
  shown() {
    const t = this.text.trim();
    const matches = rank(t, this.options()).slice(0, LIST_MAX);
    return t && !this.exact() ? [...matches, ...this.creates(t)] : matches;
  }

  // What the field stands for now: the picked option, an exact match, else the first way to create it.
  resolve() {
    const t = this.text.trim();
    return this.value ?? this.exact() ?? (t ? this.creates(t)[0] ?? null : this.empty?.() ?? null);
  }

  set(text) {
    this.text = text;
    this.input.set_value(text);
    this.open = false;
    this.at = 0;
  }

  pick(o) {
    this.set(o.text);
    this.value = o;
  }
}

// ── Dialog ──────────────────────────────────────────────────────────────────

export default class Bootstrap extends View {
  init(_props, cx) {
    const h = (this.home = home());
    this.mode = readMode();
    this.state = "idle"; // idle | parsing | starting
    this.stage = null;
    this.error = null;
    this.active = null; // the field whose list shows
    this.targets = null; // Repo options, once read
    this.worktrees = null; // the resolved repo's checkouts, once read
    this.worktreesOf = null;
    this.taskText = "";

    this.space = new Combo(this, "space", "pick or name a space", {
      options: () => localSpaces().map((s) => ({ kind: "space", text: s.name, label: s.name,
        hint: s.tabs.filter((t) => t.named).map((t) => t.name).join(", ") })),
      creates: (t) => [{ kind: "new-space", create: true, text: t, label: `+ New space "${t}"` }],
    });
    this.repo = new Combo(this, "repo", "pick or create a repo or scratch folder", {
      options: () => this.targets ?? [],
      creates: (t) => repoCreates(h, t),
    });
    this.worktree = new Combo(this, "worktree", "main checkout, a worktree, or a new branch", {
      options: () => this.worktrees ?? [],
      creates: (t) => [{ kind: "new-worktree", create: true, text: t, label: `+ New worktree "${t}"`, hint: "from origin" }],
      empty: () => this.worktrees?.find((w) => w.main) ?? null,
    });
    this.task = TextareaState.new({ placeholder: "What should the session work on?", rows: 5 });
    this.task.on("change", (_e, cx) => { this.taskText = this.task.value(); cx.notify(); });
    this.task.on("focus", (_e, cx) => { this.active = null; cx.notify(); });
    this.task.on("submit", (_e, cx) => this.primary(cx));
    this.handle = cx.focus_handle();

    cx.spawn(async (cx) => { this.targets = await loadTargets(h); cx.notify(); });
    this.focusMode();
    cx.timer.after(600, () => { if (!this.active && !this.taskText) this.focusMode(); });
  }

  close() {
    closeOverlay(props().overlay);
  }

  focusMode() {
    (this.mode === "prompt" ? this.task : this.space.input).focus();
  }

  setMode(mode, cx) {
    Object.assign(this, { mode, error: null, active: null });
    saveMode(mode);
    this.focusMode();
    cx.notify();
  }

  // ── fields

  focused(combo, cx) {
    this.active = combo;
    combo.open = true;
    this.syncWorktrees(cx);
    cx.notify();
  }

  next(combo) {
    if (combo === this.space) return this.repo.input;
    if (combo === this.repo && this.repo.resolve()?.kind === "repo") return this.worktree.input;
    return this.task;
  }

  pick(combo, o, cx) {
    if (o) combo.pick(o);
    this.syncWorktrees(cx);
    this.next(combo).focus();
    cx.notify();
  }

  // Enter in a field: take the highlighted option and move on.
  enter(combo, cx) {
    this.pick(combo, combo.shown()[combo.at], cx);
  }

  // The resolved repo's path when its checkouts need reading again, else null.
  staleWorktrees() {
    const r = this.repo.resolve();
    const path = r?.kind === "repo" ? r.path : null;
    if (path === this.worktreesOf) return null;
    Object.assign(this, { worktreesOf: path, worktrees: null });
    this.worktree.value = null;
    return path;
  }

  async fillWorktrees(path, cx) {
    const list = await loadWorktrees(path);
    if (this.worktreesOf === path) { this.worktrees = list; cx.notify(); }
  }

  syncWorktrees(cx) {
    const path = this.staleWorktrees();
    if (path) cx.spawn((cx) => this.fillWorktrees(path, cx));
  }

  // ── actions

  primary(cx) {
    if (this.state !== "idle") return;
    if (this.mode === "prompt") this.parse(cx);
    else this.start(cx);
  }

  busy(state, stage, cx) {
    Object.assign(this, { state, stage, error: null, active: null });
    this.handle.focus();
    cx.notify();
  }

  parse(cx) {
    const text = this.task.value().trim();
    if (!text) return;
    this.busy("parsing", "Haiku is reading your message…", cx);
    cx.spawn(async (cx) => {
      try {
        const targets = this.targets ?? (this.targets = await loadTargets(this.home));
        const d = await extract(text, localSpaces().map((s) => s.name), targets.map((o) => o.text), this.home);
        this.space.set(d.space.trim());
        this.repo.set(d.repo.trim());
        this.worktree.set(d.worktree.trim());
        const path = this.staleWorktrees();
        if (path) await this.fillWorktrees(path, cx);
        Object.assign(this, { state: "idle", mode: "form" });
      } catch (e) {
        Object.assign(this, { state: "idle", error: message(e) });
      }
      cx.notify();
    });
  }

  start(cx) {
    this.syncWorktrees(cx);
    const space = this.space.resolve();
    const target = this.repo.resolve();
    const wt = target?.kind === "repo" ? this.worktree.resolve() : null;
    this.error = !space ? "Pick or name a space."
      : !target ? "Pick or create a repo or scratch folder."
      : target.kind === "repo" && !wt ? (this.worktrees ? "Pick a worktree." : "Still reading worktrees, try again.")
      : null;
    if (this.error) return cx.notify();
    const task = this.task.value().trim();
    this.busy("starting", "Starting…", cx);
    cx.spawn(async (cx) => {
      try {
        const where = await launch({ space, target, wt, task }, (s) => { this.stage = s; cx.notify(); });
        this.close();
        notify({ title: "Bootstrap", body: `→ ${where}`, level: "success", timeout: 4000 });
      } catch (e) {
        Object.assign(this, { state: "idle", error: message(e) });
        cx.notify();
      }
    });
  }

  key(e, cx) {
    const c = this.active;
    if (e.keystroke === "escape") {
      if (c?.open) c.open = false;
      else if (this.state !== "starting") this.close(); // mid-start, finish rather than half-create
    } else if (e.keystroke === "cmd-enter") {
      this.primary(cx);
    } else if (c?.open && (e.key === "up" || e.key === "down")) {
      const n = c.shown().length;
      if (n) c.at = (c.at + (e.key === "down" ? 1 : n - 1)) % n;
    } else {
      return;
    }
    cx.stop_propagation();
    cx.notify();
  }

  // ── view

  // Under each field, what it resolves to: the confirmation before Start.
  notes() {
    const h = this.home;
    const s = this.space.resolve();
    const r = this.repo.resolve();
    const w = r?.kind === "repo" ? this.worktree.resolve() : null;
    const off = !r ? "pick a repo first" : r.kind === "new-repo" ? "main checkout of the new repo"
      : r.kind === "repo" ? null : "not a git repo";
    return {
      space: !s ? null : s.kind === "space" ? "existing space" : "new space",
      repo: !r ? (this.targets ? null : "reading repos…") : {
        repo: tilde(r.path, h), scratch: `folder ${tilde(r.path, h)}`,
        "new-repo": `new repo: git init ${tilde(r.path, h)}`, "new-scratch": `new folder ${tilde(r.path, h)}`,
      }[r.kind],
      off,
      worktree: off ? null : !this.worktrees ? "reading worktrees…" : !w ? null
        : w.kind === "new-worktree" ? `new worktree ${basename(r.path)}.${dirSlug(w.text)}, from origin's default branch`
        : w.main ? `main checkout · ${tilde(w.path, h)}` : tilde(w.path, h),
    };
  }

  comboView(c, t, note) {
    const listed = this.active === c && c.open ? c.shown() : [];
    const option = (o, i) => h_flex().id(`${c.key}-${i}`).h(28).px(8).gap(8).items_center().rounded(6).cursor_pointer()
      .when(i === c.at, (r) => r.bg(t.selected))
      .when(i !== c.at, (r) => r.hover((s) => s.bg(t.hover)))
      .on_click((_e, cx) => this.pick(c, o, cx))
      .child(div().flex_1().min_w(0).truncate().text_color(o.create ? t.accent : t.foreground).child(o.label))
      .when(!!o.hint, (r) => r.child(div().flex_none().text_size(11).text_color(t.dim).child(o.hint)));
    return v_flex().gap(4)
      .child(Input.new(c.input).h(32).px(10).items_center().rounded(7).border_1()
        .border_color(this.active === c ? t.accent : t.input).bg(t.background).text_color(t.foreground))
      .when(listed.length > 0, (el) => el.child(v_flex().p(4).gap(1).rounded(8).border_1()
        .border_color(t.border).bg(t.raised).text_size(12.5).children(listed.map(option))))
      .when(!listed.length && !!note, (el) => el.child(div().px(2).truncate().text_size(11.5).text_color(t.dim).child(note)));
  }

  render() {
    const t = theme();
    const form = this.mode === "form";
    const busy = this.state !== "idle";
    const n = this.notes();
    const button = (id, text, primary, disabled, action) => h_flex().id(id).h(32).px(14).items_center().rounded(8)
      .border_1().border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
      .text_color(primary ? t.solid_foreground : t.foreground).text_size(12.5).font_medium().cursor_pointer()
      .when(disabled, (el) => el.opacity(0.5))
      .hover((s) => s.opacity(0.88)).on_click(action).child(text);
    const segment = (mode, label) => h_flex().id(`mode-${mode}`).h(24).px(10).items_center().rounded(6)
      .text_size(12).cursor_pointer()
      .when(this.mode === mode, (el) => el.bg(t.selected).text_color(t.foreground))
      .when(this.mode !== mode, (el) => el.text_color(t.muted).hover((s) => s.bg(t.hover)))
      .on_click((_e, cx) => { if (!busy) this.setMode(mode, cx); }).child(label);
    const field = (label, body) => h_flex().gap(10).items_start()
      .child(div().w(66).flex_shrink_0().pt(8).text_size(12).text_color(t.dim).child(label))
      .child(v_flex().flex_1().min_w(0).child(body));
    const taskView = Textarea.new(this.task).px(10).py(8).rounded(9).border_1()
      .border_color(form ? t.input : t.accent).bg(t.background).text_size(12.8).text_color(t.foreground);
    const status = busy
      ? h_flex().gap(6).items_center().text_color(t.muted)
          .child(div().text_color(t.accent).frames(SPINNER, 90)).child(this.stage)
      : this.error ? div().text_color(t.blocked).child(this.error)
      : div().text_color(t.dim).child(form ? "↑↓ ↩ pick · ⌘↩ start" : "⌘↩ fill the form");

    const body = form
      ? v_flex().gap(10)
          .child(field("Space", this.comboView(this.space, t, n.space)))
          .child(field("Repo", this.comboView(this.repo, t, n.repo)))
          .child(field("Worktree", n.off
            ? div().pt(8).text_size(12).text_color(t.dim).child(n.off)
            : this.comboView(this.worktree, t, n.worktree)))
          .child(field("Message", taskView))
      : v_flex().gap(8).child(taskView)
          .child(div().text_size(11.5).text_color(t.dim)
            .child("Haiku pulls the space, repo and worktree out of this and fills the form. Nothing starts before Start."));

    return v_flex().id("bootstrap").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .w_full().min_h(0).p(18).gap(14).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center().gap(10)
        .child(div().flex_1().text_size(15).font_semibold().child("Bootstrap"))
        .child(h_flex().p(2).gap(2).rounded(8).border_1().border_color(t.input)
          .child(segment("form", "Form")).child(segment("prompt", "Prompt")))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(body)
      .child(h_flex().gap(8).items_center()
        .child(div().flex_1().min_w(0).text_size(11).child(status))
        .child(button("bs-cancel", "Cancel", false, false, () => this.close()))
        .child(form
          ? button("bs-start", "Start", true, busy, (_e, cx) => this.primary(cx))
          : button("bs-parse", "Fill form", true, busy || !this.taskText.trim(), (_e, cx) => this.primary(cx))));
  }
}
