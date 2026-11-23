// my-spaces: a clone of Herdr's `spaces` (0.1.12) that nests each space's tabs
// under it as a tree. Agent tabs draw like the Agents list: program icon,
// summary (the tab's name, else the agent's own title), time in its state,
// status. The chevron on a space folds its tabs; the header's layers button
// hides or shows them all (new spaces follow it). Fold state: localStorage.
//
// Sections: every space is in one of Focus, Standby, Sandbox, Archive (shared
// "space.sections"; new spaces start in Focus), each under a header that folds
// (Archive folded at first); the rail draws a line between them. Focus is a tinted
// card pinned above the list. Move a space from its right-click (my `space-menu`), by
// dragging it among a section's spaces, or with Re-organize (the Focus card's list
// button, my `reorganize`). The real order (⌃1–⌃9,
// dragging) is kept the same as the drawn one: a space entering a section lands at
// the edge it crossed.
//
// No worktree nesting: the original moved worktree spaces under the space at their
// repo's main checkout, a second kind of nesting that clashed with the tabs'.
//
// From the original: stable colored avatars, grouped by machine when more than
// one is known. After a space's name, the repo
// its first terminal is in now, only where unusual: branch, ahead/behind. Click to
// switch, right-click for its menu, drag to reorder. Tabs: click to show (an
// agent tab focuses its agent), right-click for my `tab-menu`.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, machines, panes, agents, run, openOverlay, exec, hc, theme, shared, setShared, watchFolder, window, layout } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

// Where a space is now: its first terminal's live folder, else where it was made.
// `ps`: panes(), read once by the caller (each read copies every pane).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}
// two: a git line under the name.
const rowHeight = (two) => (two ? 44 : 30);
const where = (s, ps) => JSON.stringify([s.machine ?? null, place(s, ps)]);
const base = (path) => path.replace(/\/+$/, "").split("/").pop();
// Changes made outside Herdr (an editor's save, a commit in another app): looked
// for this often, in repos the list shows, while the window is in front.
const FALLBACK = 60000;

// What a stored color name looks like on an avatar (the same in every mod
// that draws space avatars): one strong color per hue, light and dark alike.
const MARK = { ansi6: "#22a99a", ansi3: "#e3814f", ansi4: "#5b8def", ansi5: "#8b7cf6", ansi2: "#3fae6a", ansi1: "#d9649a" };

// A space speaks up only when something in it needs you.
export function glyph(status) {
  return status === "blocked" || status === "done" ? "●" : "·";
}

export function tone(t, status) {
  return t[status] ?? t.unknown;
}

// ── From the agents mod: how a tab and its agent read, and how a status draws ──

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();

// A tab's front pane: its agent, else the focused one, else the first (a mod pane last).
function lead(tab, all) {
  const mine = all.filter((p) => p.tab === tab.id);
  const terms = mine.filter((p) => p.terminal);
  return terms.find((p) => p.program?.agent) ?? terms.find((p) => p.focused) ?? terms[0] ?? mine[0];
}

// The program's own title when it says something (an agent's session summary), else null.
function telling(l) {
  const prog = l?.program?.name;
  const live = clean(l?.title);
  // A path says nothing; test before clean() strips its leading "/" (shell tabs show it).
  const path = /^[~/]|^[A-Za-z]:\\/.test((l?.title ?? "").trim());
  return live && live !== prog && !path && !live.includes("@") && live.toLowerCase() !== l?.program?.key ? live : null;
}

// always (agent tabs): the summary even over a name someone gave; else that name wins.
function title(tab, l, always = false) {
  const live = telling(l);
  return live && (always || !tab.named || tab.name === l?.program?.name) ? live : tab.name;
}

function duration(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "<1m";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

// compact: a "!" instead of the "Needs you" pill (on a folded space's row).
function status(t, st, compact = false) {
  if (st === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).mx(1).flex_none().text_color(t.working).spin(900);
  if (st === "blocked" && compact) return div().size(14).flex_none().rounded(4).bg(t.blocked + "26").text_size(10.5).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!");
  if (st === "blocked") return div().flex_none().px(6).h(18).rounded(5).bg(t.blocked + "26").text_size(10.5).font_semibold().text_color(t.blocked).flex().items_center().child("Needs you");
  if (st === "idle") return div().size(7).mx(3).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim);
  return div().size(7).mx(3).flex_none().rounded(4).bg(st === "done" ? t.done : t.dim + "00");
}

// Which of a tab's agents its row stands for: its icon, summary, time and status.
// `crew`: the tab's agents (AgentInfo, at least one), in pane order. The most urgent,
// so the row agrees with the tab's status; between equals, the latest to change.
const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
function pickLead(crew) {
  return crew.reduce((best, a) => ((RANK[a.status] ?? 0) - (RANK[best.status] ?? 0) || a.seq - best.seq) > 0 ? a : best);
}

// ── Sections ──
// Every space is in one of these, in this order. Shared "space.sections": { of: { space
// id: section id } }, written by space-menu, reorganize (same ids there) and dragging
// here. A space with none yet (a new one) goes to HOME.
const SECTIONS = [
  { id: "focus", name: "Focus" },
  { id: "standby", name: "Standby" },
  { id: "sandbox", name: "Sandbox" },
  { id: "archive", name: "Archive" },
];
const HOME = "focus";
const KNOWN = new Set(SECTIONS.map((s) => s.id));
const sectionMap = () => shared("space.sections")?.of ?? {};
const sectionOf = (id, of = sectionMap()) => (KNOWN.has(of[id]) ? of[id] : HOME);

// The order of the spaces inside one section. a, b: SpaceInfo; `index` is where each
// is now (⌃N − 1): as you left them, dragging decides. Negative: a goes first.
function within(a, b) {
  return a.index - b.index;
}

// One machine's spaces (SpaceInfo, in their order) as the sidebar groups them: every
// section in its order, empty ones too.
function arrange(list, of) {
  return SECTIONS.map((sec) => ({ sec, spaces: list.filter((s) => sectionOf(s.id, of) === sec.id).sort(within) }));
}

export default class Spaces extends View {
  init(_props, cx) {
    this.git = {}; // where() -> { name, branch, ahead, behind, repo, linked }, null: not a repo
    this.checked = {}; // where() -> when it was last looked at
    this.unsure = new Set(); // where()s git couldn't answer for (a machine away)
    this.pending = new Set(); // where()s to look at next
    this.busy = {}; // pane -> an agent working or a program in front of its shell
    this.ready = {}; // machine -> its layout was readable at the last look
    this.at = {}; // space -> its where() at the last look
    this.watching = new Set(); // local repos' git folders
    // Spaces made while this runs wait (at most a moment) for their git, so the
    // row doesn't grow when its git line arrives.
    this.shown = new Set(spaces().map((s) => s.id));
    this.born = {};
    this.pressed = null;
    this.over = null;
    this.machines = [];
    this.reconnecting = JSON.parse(localStorage.getItem("machines.reconnecting") ?? "{}");
    for (const state of Object.values(this.reconnecting)) state.busy = false;
    this.folded = new Set(JSON.parse(localStorage.getItem("machines.folded") ?? "[]"));
    this.secFolded = new Set(JSON.parse(localStorage.getItem("sections.folded") ?? '["archive"]'));
    this.stuck = null; // an order syncOrder couldn't reach: not tried again until something changes
    // Tabs: shown or hidden by default (`mode`), and the spaces set the other way.
    const fold = JSON.parse(localStorage.getItem("tabs.fold") ?? "{}");
    this.tabMode = fold.mode === "hidden" ? "hidden" : "shown";
    this.flipped = new Set(fold.flipped ?? []);
    // Each agent's last state and since when (ms), kept across restarts, as in agents.
    this.changed = JSON.parse(localStorage.getItem("changed") ?? "{}");
    cx.timer.every(30000, (cx) => cx.notify()); // the runtimes' minutes
    this.refreshMachines(cx);
    cx.timer.every(15000, cx => this.refreshMachines(cx));
    // `git status` walks the whole tree, on another machine a process there:
    // only when its answer could have changed (see `due`).
    cx.timer.every(250, (cx) => this.checkNew(cx));
  }

  checkNew(cx) {
    const now = Date.now();
    const sp = spaces();
    for (const s of sp) if (!this.shown.has(s.id)) this.born[s.id] ??= now;
    const due = this.due(now, sp, panes());
    if (due.size) this.refreshGit(due, cx);
    if (sp.some((s) => !this.shown.has(s.id))) cx.notify();
  }

  // Places whose git could have changed: new ones (a new space, a cd), where a
  // command or an agent's turn just ended (a checkout, a commit, edits), those on
  // a machine that is back, and repos in view whose fallback is due.
  due(now, sp, ps) {
    // Moved there: what it knew of that place may be old.
    const at = {};
    for (const s of sp) at[s.id] = where(s, ps);
    const keys = new Set(Object.values(at).filter((k) => JSON.parse(k)[1]));
    const due = new Set([...keys].filter((k) => !(k in this.git)));
    for (const [id, k] of Object.entries(at)) if (this.at[id] && this.at[id] !== k && keys.has(k)) due.add(k);
    this.at = at;
    const spaceOf = {};
    for (const s of sp) for (const t of s.tabs ?? []) spaceOf[t.id] = s;
    const busy = {};
    for (const p of ps) {
      if (!p.terminal || !spaceOf[p.tab]) continue;
      busy[p.pane] = p.status === "working" || !(p.program?.shell || p.program?.agent);
      if (this.busy[p.pane] && !busy[p.pane]) this.sameRepo(at[spaceOf[p.tab].id], keys).forEach((k) => due.add(k));
    }
    this.busy = busy;
    for (const m of machines()) {
      const ready = m.layout === "ready";
      if (ready && this.ready[m.name] === false) for (const k of keys) if (JSON.parse(k)[0] === m.name) due.add(k);
      this.ready[m.name] = ready;
    }
    if (window().active) {
      for (const k of keys) {
        const asks = this.git[k] || this.unsure.has(k);
        if (asks && !this.folded.has(JSON.parse(k)[0]) && now - (this.checked[k] ?? 0) > FALLBACK) due.add(k);
      }
    }
    return due;
  }

  // `key` and the other places in its repo (a commit there moves their ahead/behind).
  sameRepo(key, keys) {
    const repo = this.git[key]?.repo;
    return [key, ...(repo ? [...keys].filter((k) => this.git[k]?.repo === repo) : [])];
  }

  refreshMachines(cx) {
    cx.spawn(async cx => {
      try { const r = await hc(["machine", "ls", "--json"]); if (r.code === 0) this.machines = (JSON.parse(r.stdout).machines ?? []).filter((m) => !m.temporary); } catch {}
      cx.notify();
    });
  }

  rebuilt(machine) {
    return machine?.state === "unreachable" && /^a different core answers there \("[^"]+"\)$/.test(machine.why ?? "");
  }

  reconnect(machine, cx) {
    const name = machine.name;
    if (this.reconnecting[name]?.busy) return;
    const state = this.reconnecting[name] ??= { machine, removed: false };
    state.busy = true;
    state.error = null;
    localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
    cx.notify();
    cx.spawn(async cx => {
      try {
        const ask = async args => {
          const r = await hc([...args, "--json"]);
          if (r.code !== 0) {
            let error;
            try { error = JSON.parse(r.stdout || r.stderr).error?.message; } catch {}
            throw new Error(error || r.stderr || r.stdout || "Couldn't connect.");
          }
        };
        if (!state.removed) {
          await ask(["machine", "rm", name]);
          state.removed = true;
          localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
        }
        const args = ["machine", "add"];
        if (machine.via) args.push("--via", machine.target);
        else args.push(machine.target);
        args.push("--name", name);
        if (machine.session) args.push("--session", machine.session);
        if (machine.temporary) args.push("--temp");
        await ask(args);
        this.folded.delete(name);
        localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
        delete this.reconnecting[name];
      } catch (e) {
        state.error = String(e.message ?? e);
        state.busy = false;
      }
      localStorage.setItem("machines.reconnecting", JSON.stringify(this.reconnecting));
      this.refreshMachines(cx);
      cx.notify();
    });
  }

  // One look at a time, each place once however often it was asked for meanwhile.
  refreshGit(keys, cx) {
    for (const k of keys) this.pending.add(k);
    if (this.refreshing) return;
    this.refreshing = true;
    cx.spawn(async (cx) => {
      while (this.pending.size) {
        const keys = [...this.pending];
        this.pending.clear();
        for (const key of keys) await this.check(key, cx);
      }
      const used = new Set(Object.values(this.git).filter(Boolean).map((g) => JSON.parse(g.repo)).filter(([on]) => !on).map(([, repo]) => repo));
      for (const repo of this.watching) if (!used.has(repo)) this.watching.delete(repo);
      this.refreshing = false;
      cx.notify();
    });
  }

  // One place's git: branch, ahead/behind, its repo.
  async check(key, cx) {
    const [on, cwd] = JSON.parse(key);
    this.checked[key] = Date.now();
    this.unsure.delete(key);
    try {
      // No optional locks: a status that touched the index would wake the watch again.
      // Writes nothing under .git (index lock, fsmonitor cookie): watch() would wake on it.
      const r = await exec("git", ["--no-optional-locks", "-c", "core.fsmonitor=false", "status", "--porcelain=v2", "--branch"], { cwd, on });
      if (r.code !== 0) {
        // Only git's own "no" is remembered as no repo; anything else is asked again.
        if (!/not a git repository/i.test(r.stderr)) this.unsure.add(key);
        this.git[key] = null;
        return;
      }
      // The repo's own .git folder names it; a worktree's top differs from it.
      const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on });
      const common = await exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd, on });
      const repo = common.stdout.trim();
      const name = repo.endsWith("/.git") ? base(repo.slice(0, -5)) : base(repo).replace(/\.git$/, "");
      const info = { name, branch: null, ahead: 0, behind: 0, repo: JSON.stringify([on, repo]), linked: repo !== `${top.stdout.trim()}/.git` };
      for (const line of r.stdout.split("\n")) {
        if (line.startsWith("# branch.head ")) info.branch = line.slice(14);
        else if (line.startsWith("# branch.ab ")) {
          const [a, b] = line.slice(12).split(" ");
          info.ahead = Math.abs(parseInt(a, 10)) || 0;
          info.behind = Math.abs(parseInt(b, 10)) || 0;
        }
      }
      this.git[key] = info;
      if (!on) this.watch(repo, cx);
    } catch {
      // Couldn't ask (the machine is away): keep what it showed, look again later.
      this.git[key] ??= null;
      this.unsure.add(key);
    }
  }

  watch(repo, cx) {
    if (this.watching.has(repo)) return;
    this.watching.add(repo);
    cx.spawn(async (cx) => {
      try {
        while (this.watching.has(repo)) {
          await watchFolder(repo);
          const mine = JSON.stringify([null, repo]);
          if (this.watching.has(repo)) this.refreshGit(Object.keys(this.git).filter((k) => this.git[k]?.repo === mine), cx);
        }
      } catch { this.watching.delete(repo); }
    });
  }

  menu(w) {
    // A popup is as tall as its items; height is only the most.
    openOverlay({ mod: "space-menu", kind: "popup", width: 230, height: 440, props: { tab: "space", target: { id: w.id } } });
  }

  // The real order (⌃1–⌃9, dragging, space.move) follows the drawn one: each machine's
  // spaces by section. Moves what's out of place; space.move applies at once.
  syncOrder() {
    if (this.pressed !== null) return;
    const of = sectionMap();
    let now = spaces();
    const want = [];
    for (const m of new Set(now.map((s) => s.machine ?? null)))
      for (const g of arrange(now.filter((s) => (s.machine ?? null) === m), of)) want.push(...g.spaces.map((s) => s.id));
    const sig = `${want.join()}|${now.map((s) => s.id).join()}`;
    if (sig === this.stuck) return;
    for (let k = 0; k < want.length; k++) {
      if (now[k]?.id === want[k]) continue;
      run("space.move", { id: want[k], index: k + 1 });
      now = spaces();
      // Didn't move (its machine's layout is away): wait for a change.
      if (now[k]?.id !== want[k]) return void (this.stuck = sig);
    }
    this.stuck = null;
  }

  // Dropped next to `near`, a space joins near's section.
  joinSection(id, near) {
    const of = sectionMap();
    const to = sectionOf(near, of);
    if (to !== sectionOf(id, of)) setShared("space.sections", { of: { ...of, [id]: to } });
  }

  // Keeps "space.sections" whole: every space in a known section (a new one: HOME; one
  // from the earlier free-form sections: the one with its name). Closed spaces leave,
  // once their machine's layout can be trusted.
  tidySections(sp) {
    const raw = shared("space.sections") ?? {};
    const old = raw.of ?? {};
    const ids = new Set(sp.map((s) => s.id));
    const ready = (id) => {
      const m = id.includes("/") ? id.slice(0, id.indexOf("/")) : null;
      return machines().find((k) => (k.name ?? null) === m)?.layout === "ready";
    };
    const of = {};
    for (const [id, sec] of Object.entries(old)) if (ids.has(id) || !ready(id)) of[id] = sec;
    for (const s of sp) {
      if (KNOWN.has(of[s.id])) continue;
      const was = (raw.list ?? []).find((x) => x.id === of[s.id])?.name?.toLowerCase();
      of[s.id] = SECTIONS.find((x) => x.name.toLowerCase() === was)?.id ?? HOME;
    }
    if (raw.list || JSON.stringify(of) !== JSON.stringify(old)) setShared("space.sections", { of });
  }

  // A machine's rows under their sections' headers, Focus aside (its card). Empty
  // sections show on this computer only. The rail draws a line between sections instead.
  bySection(rows, m, draw, t, collapsed) {
    const byId = new Map(rows.map((r) => [r.w.id, r]));
    const mine = spaces().filter((s) => (s.machine ?? null) === m);
    let first = true;
    return arrange(mine, sectionMap()).filter(({ sec }) => sec.id !== "focus").flatMap(({ sec, spaces: list }) => {
      const shown = list.map((s) => byId.get(s.id)).filter(Boolean);
      if (!shown.length && m !== null) return [];
      const folded = !collapsed && this.secFolded.has(sec.id);
      const head = this.sectionHead(sec, shown, folded, collapsed, first, t);
      first = false;
      return [...(head ? [head] : []), ...(folded ? [] : shown.flatMap(draw))];
    });
  }

  // Click folds it; folded, it says how many spaces and what needs you.
  sectionHead(sec, rows, folded, collapsed, first, t) {
    if (collapsed) return first ? null : div().id(`sec-${sec.id}`).flex_none().mx(6).my(5).h(1).bg(t.border);
    const st = rows.map((r) => r.w.status).reduce((a, b) => ((RANK[b] ?? 0) > (RANK[a] ?? 0) ? b : a), null);
    return h_flex()
      .id(`sec-${sec.id}`)
      .h(26)
      .flex_none()
      .when(!first, (el) => el.mt(8))
      .px(8)
      .gap(6)
      .items_center()
      .rounded(6)
      .text_size(11.5)
      .text_color(t.dim)
      .cursor_pointer()
      .hover((s) => s.bg(t.hover).text_color(t.muted))
      .on_click((_e, cx) => {
        folded ? this.secFolded.delete(sec.id) : this.secFolded.add(sec.id);
        localStorage.setItem("sections.folded", JSON.stringify([...this.secFolded]));
        cx.notify();
      })
      .child(div().flex_1().min_w(0).truncate().font_semibold().child(sec.name))
      .when(folded && st && st !== "idle", (el) => el.child(status(t, st, true)))
      .when(folded || !rows.length, (el) => el.child(div().flex_none().text_size(11).child(rows.length ? String(rows.length) : "empty")))
      .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none());
  }

  // Spaces in their order, each with its git (null: not a repo, or not known yet).
  ordered() {
    const sp = spaces(), ps = panes();
    const ready = (w) => this.shown.has(w.id) || where(w, ps) in this.git || Date.now() - (this.born[w.id] ??= Date.now()) > 1500;
    for (const w of sp) if (!this.shown.has(w.id) && ready(w)) this.shown.add(w.id);
    return sp.map((w, i) => ({ w, i, g: this.git[where(w, ps)] ?? null })).filter((r) => this.shown.has(r.w.id));
  }

  // A space as the list draws it: its row and its tabs, or one cell on the rail.
  drawRow(r, t, collapsed) {
    return collapsed ? [this.compact(r, t)] : [this.row(r, t), ...this.tabRows(r, t)];
  }

  // How tall drawRow(r) is, from the fixed heights it uses (row, tabRow, compact).
  heightOf(r, t, collapsed) {
    if (collapsed) return 26;
    const tabs = this.isOpen(r.w.id) ? (r.w.tabs?.length ?? 0) : 0;
    return rowHeight(Boolean(this.gitLine(r.g, r.w.name, t))) + tabs * 28 + (tabs ? 4 : 0);
  }

  // Focus: a card pinned above the list, in the accent's tint, with every machine's
  // Focus spaces (machine folding doesn't hide them). Past 60% of the sidebar it
  // scrolls inside: a scroll area needs a set height, so it gets its content's (known
  // from heightOf) only when that's too much. Its list button opens Re-organize.
  focusCard(rows, t, collapsed) {
    if (collapsed && !rows.length) return null;
    const reorganize = () => run("mod.open", { name: "reorganize" });
    const head = h_flex().h(30).flex_none().pl(8).pr(3).gap(7).items_center()
      .child(svg("mods/my-spaces/target.svg").size(13).flex_none().text_color(t.accent))
      .child(div().flex_1().text_size(11.5).font_semibold().text_color(t.accent).child("Focus"))
      .when(rows.length > 0, (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child(String(rows.length))))
      .child(div().id("reorganize").size(22).flex_none().flex().items_center().justify_center().rounded(5).text_color(t.dim)
        .hover((s) => s.bg(t.hover).text_color(t.foreground))
        .tooltip("Re-organize Focus and Standby")
        .on_click(reorganize)
        .child(svg("mods/my-spaces/list-checks.svg").size(13)));
    const items = rows.length
      ? rows.flatMap((r) => this.drawRow(r, t, collapsed))
      : [div().id("focus-empty").px(8).pb(8).text_size(12).text_color(t.dim).cursor_pointer()
          .hover((s) => s.text_color(t.muted)).on_click(reorganize).child("Nothing in focus. Re-organize…")];
    const tall = rows.reduce((n, r) => n + this.heightOf(r, t, collapsed), 0);
    const cap = Math.max(120, (this.size?.height ?? Infinity) * 0.6 - (collapsed ? 6 : 40));
    const body = tall > cap ? v_flex().id("focus-body").h(cap).overflow_y_scrollbar().children(items) : v_flex().children(items);
    return v_flex().id("focus-card").flex_none().mx(collapsed ? 4 : 8).mb(8).p(collapsed ? 2 : 4)
      .rounded(10).border(1).border_color(t.accent + "4d").bg(t.accent + "12")
      .on_mouse_up("left", (_e, cx) => { this.pressed = null; cx.notify(); })
      .when(!collapsed, (el) => el.child(head))
      .child(body);
  }

  grouped(t, collapsed) {
    const rows = this.ordered();
    const draw = (r) => this.drawRow(r, t, collapsed);
    const remote = [...new Set([...rows.map(r => r.w.machine).filter(Boolean), ...this.machines.map(m => m.name), ...Object.keys(this.reconnecting)])].sort();
    const loading = m => {
      const layout = machines().find(k => k.name === m)?.layout;
      return layout === "loading" || (!layout && this.machines.some(k => k.name === m && k.state === "connected"))
        || spaces().some(s => (s.machine ?? null) === m && !this.shown.has(s.id));
    };
    const loadingRow = m => div().id(`machine-loading-${m ?? "local"}`).h(28).flex_none().px(8).text_size(12).text_color(t.dim).child(collapsed ? "…" : "Loading…");
    if (!remote.length) return loading(null) && !rows.length ? [loadingRow(null)] : this.bySection(rows, null, draw, t, collapsed);
    const machineNames = [null, ...remote];
    return machineNames.flatMap((m) => {
      const mine = rows.filter((r) => (r.w.machine ?? null) === m);
      const repair = this.reconnecting[m];
      const machine = this.machines.find(k => k.name === m) ?? repair?.machine;
      const connected = !m || machine?.state === "connected";
      const rebuilt = this.rebuilt(machine) || !!repair;
      const folded = this.folded.has(m);
      const head = h_flex().id(`machine-${m ?? "local"}`).h(26).flex_none().px(collapsed ? 2 : 8).gap(7).items_center().text_size(11).text_color(t.dim)
        .cursor_pointer().hover(s => s.bg(t.hover))
        .on_click((_e, cx) => {
          folded ? this.folded.delete(m) : this.folded.add(m);
          localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
          cx.notify();
        })
        .child(svg(`mods/workspace-chrome/${m ? "server" : "monitor"}.svg`).size(13).flex_none())
        .when(!collapsed, el => el.child(div().flex_1().truncate().child(m ?? "This computer"))
          .when(!connected && !rebuilt, el => el.child(div().flex_none().child((machine?.state ?? "asleep").replace(/_/g, " "))))
          .when(rebuilt, el => el.child(h_flex().flex_none().gap(3).items_center()
            .child(div().max_w(140).truncate().child(repair?.error || "rebuilt ·"))
            .child(div().id(`machine-connect-${m}`).text_color(repair?.error ? t.blocked : t.muted)
              .hover(s => s.text_color(t.foreground))
              .tooltip(repair?.error || "This machine was rebuilt or replaced. Click to connect to the new one.")
              .on_click((_e, cx) => { cx.stop_propagation(); this.reconnect(machine, cx); })
              .child(repair?.busy ? "Connecting…" : "Connect"))))
          .when(connected, el => el.child(div().id(`machine-add-${m ?? "local"}`).flex_none().px(4).rounded(4).hover(s => s.bg(t.hover).text_color(t.foreground))
            .on_click((_e, cx) => { cx.stop_propagation(); run("space.new", { machine: m ?? "" }); }).child("+")))
          .child(div().size(6).rounded(3).flex_none().bg(connected ? t.ansi2 : t.dim))
          .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none()));
      const empty = h_flex().id(`machine-new-${m ?? "local"}`).h(28).flex_none().px(8).gap(7).items_center().rounded(7)
        .text_size(12).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
        .on_click(() => run("space.new", { machine: m ?? "" }))
        .child(svg("mods/workspace-chrome/plus.svg").size(12)).when(!collapsed, el => el.child("New space there"));
      if (!collapsed && rebuilt) return [head];
      return [head, ...(folded ? [] : mine.length ? this.bySection(mine, m, draw, t, collapsed) : [loading(m) ? loadingRow(m) : empty])];
    });
  }

  // Only what's unusual, on a line under the name: "herdr \u00b7 spike \u21912 \u21931". The repo
  // or branch goes when the name already says it (a worktree is named after its branch),
  // and master/main go: nearly every space is on one. Null: nothing to say.
  gitLine(g, name, t) {
    if (!g) return null;
    const raw = g.branch ?? "detached";
    const same = (a) => a.toLowerCase() === name.toLowerCase();
    const branch = same(raw) || raw === "master" || raw === "main" ? "" : raw;
    const repo = same(g.name) ? "" : g.name;
    const where = [repo, branch].filter(Boolean).join(" \u00b7 ");
    if (!where && !g.ahead && !g.behind) return null;
    return h_flex()
      .min_w(0)
      .gap(5)
      .items_center()
      .text_size(11.5)
      .text_color(t.dim)
      .child(svg("mods/workspace-chrome/git-branch.svg").size(11).flex_none())
      .when(Boolean(where), (el) => el.child(div().min_w(0).truncate().child(where)))
      .when(g.ahead > 0, (el) => el.child(div().flex_none().text_color(t.ansi2).child(`\u2191${g.ahead}`)))
      .when(g.behind > 0, (el) => el.child(div().flex_none().text_color(t.ansi1).child(`\u2193${g.behind}`)));
  }

  row({ w, i, g }, t) {
    // With its tabs out, the shown tab carries the highlight instead.
    const on = w.active && !(this.isOpen(w.id) && w.tabs?.length);
    const colors = shared("space.colors") ?? {};
    const color = colors[w.id] ?? "ansi6";
    const fill = color.startsWith("#") ? color : (MARK[color] ?? t[color]);
    const git = this.gitLine(g, w.name, t);
    return v_flex()
      .relative()
      .id(`space-${w.id}`)
      .px(8)
      .h(rowHeight(Boolean(git)))
      .flex_none()
      .justify_center()
      .rounded(8)
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .when(this.pressed === i && this.over !== i, (el) => el.opacity(0.5))
      .when(this.pressed !== null && this.over === i && this.pressed !== i, (el) => el.child(
        div().absolute().left(0).right(0).h(2).bg(t.accent)
          .when(this.pressed < i, line => line.bottom(0))
          .when(this.pressed > i, line => line.top(0)),
      ))
      .on_mouse_down("left", () => {
        this.pressed = i;
        this.over = i;
      })
      .on_mouse_move((_e, cx) => {
        const source = spaces()[this.pressed];
        const over = source && (source.machine ?? null) === (w.machine ?? null) ? i : null;
        if (this.pressed !== null && this.over !== over) {
          this.over = over;
          cx.notify();
        }
      })
      .on_mouse_up("left", (_e, cx) => {
        const from = this.pressed;
        const over = this.over;
        this.pressed = null;
        this.over = null;
        if (from !== null && over === i && from !== i) {
          const id = spaces()[from].id;
          this.joinSection(id, w.id);
          run("space.move", { id, index: i + 1 });
        }
        else if (from === i) run("space.select", { id: w.id });
        cx.notify();
      })
      .on_mouse_down("right", () => this.menu(w))
      .child(
        h_flex()
          .gap(9)
          .items_center()
          .child(h_flex().size(18).flex_none().rounded(5).bg(fill).items_center().justify_center().text_size(10.5).font_bold().text_color("#ffffff").child([...w.name][0]?.toUpperCase() ?? "?"))
          .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(w.name))
          .child(this.fold(w, t)),
      )
      // The space's own line (one checkout: its first terminal's), from under its avatar.
      .when(Boolean(git), (el) => el.child(git.mt(1)));
  }

  // ── Tabs under their space ──

  isOpen(id) {
    return (this.tabMode === "shown") !== this.flipped.has(id);
  }

  setOpen(id, open) {
    if (open === (this.tabMode === "shown")) this.flipped.delete(id);
    else this.flipped.add(id);
    this.saveFold();
  }

  // Any space showing its tabs: hide them all; none: show them all.
  toggleAll() {
    this.tabMode = spaces().some((s) => this.isOpen(s.id)) ? "hidden" : "shown";
    this.flipped.clear();
    this.saveFold();
  }

  saveFold() {
    const ids = new Set(spaces().map((s) => s.id));
    for (const id of this.flipped) if (!ids.has(id)) this.flipped.delete(id);
    localStorage.setItem("tabs.fold", JSON.stringify({ mode: this.tabMode, flipped: [...this.flipped] }));
  }

  // The space row's fold control. Folded, it says how many tabs and what needs you.
  fold(w, t) {
    const open = this.isOpen(w.id);
    const urgent = !open && w.status && w.status !== "idle";
    return h_flex()
      .id(`fold-${w.id}`)
      .flex_none()
      .h(18)
      .px(3)
      .gap(4)
      .items_center()
      .rounded(4)
      .text_size(11)
      .text_color(t.dim)
      .cursor_pointer()
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .tooltip(open ? "Hide tabs" : "Show tabs")
      // Not a press on the row: no drag, no select.
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click((_e, cx) => {
        cx.stop_propagation();
        this.setOpen(w.id, !open);
        cx.notify();
      })
      .when(urgent, (el) => el.child(status(t, w.status, true)))
      .when(!open, (el) => el.child(String(w.tabs?.length ?? 0)))
      .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(11).flex_none());
  }

  // Stamps agents whose state changed; done and idle count as one (looking turns
  // done into idle). A first sight starts at its tab's last change, if known.
  track(list, now) {
    let dirty = false;
    const tabAt = {};
    for (const s of spaces()) for (const c of s.tabs ?? []) tabAt[c.id] = c.changed_at;
    for (const a of list) {
      const s = a.status === "done" ? "idle" : a.status;
      if (this.changed[a.address]?.s === s) continue;
      const first = !this.changed[a.address];
      this.changed[a.address] = { s, at: (first && tabAt[a.tab]) || now };
      dirty = true;
    }
    if (!dirty) return;
    const listed = new Set(list.map((a) => a.address));
    for (const [k, c] of Object.entries(this.changed)) if (!listed.has(k) && now - c.at > 30 * 86400000) delete this.changed[k];
    localStorage.setItem("changed", JSON.stringify(this.changed));
  }

  tabRows({ w }, t) {
    if (!this.isOpen(w.id)) return [];
    const tabs = w.tabs ?? [];
    // Under the space's name; the rail runs under its avatar.
    const indent = 35;
    const rail = 16.5;
    // The number tab.select (⌘1–⌘9) uses: settled tabs don't count, so they get none.
    let k = 0;
    const keys = tabs.map((tab) => (tab.settled ? null : ++k));
    return tabs.map((tab, n) => this.tabRow(w, tab, { indent, rail, last: n === tabs.length - 1, key: keys[n] }, t));
  }

  tabRow(w, tab, { indent, rail, last, key }, t) {
    const crew = this.ags.filter((a) => a.tab === tab.id);
    const a = crew.length ? pickLead(crew) : null;
    const l = lead(tab, this.ps);
    const rep = a ?? l;
    let summary = title(tab, rep, Boolean(a));
    // An unnamed tab with nothing telling in its title: what runs there.
    if (/^\d+$/.test(summary)) {
      const dir = l?.cwd ? base(l.cwd) : "";
      summary = rep?.program?.shell && dir && dir.toLowerCase() !== w.name.toLowerCase() ? dir : rep?.program?.name || rep?.title || `Tab ${summary}`;
    }
    const on = w.active && tab.active;
    const quiet = !a || (a.status === "idle" && !on);
    const pic = icon(rep?.program, a ? 16 : 14, a ? t.foreground : t.dim) ?? svg("mods/workspace-chrome/terminal.svg").size(13).flex_none().text_color(t.dim);
    const since = a ? this.changed[a.address]?.at : null;
    // A name someone gave that the summary covers: still there on hover.
    const hidden = tab.named && tab.name !== summary ? tab.name : null;
    const badge = h_flex()
      .size(16)
      .flex_none()
      .rounded(4)
      .border(1)
      .border_color(on ? t.input : t.border)
      .items_center()
      .justify_center()
      .text_size(10)
      .font_semibold()
      .text_color(on ? t.foreground : t.dim)
      .child(key == null ? "·" : String(key));
    return h_flex()
      .relative()
      .id(`tab-${tab.id}`)
      .when(Boolean(hidden), (el) => el.tooltip(`Tab: ${hidden}`))
      .h(28)
      .flex_none()
      .pl(indent)
      .pr(8)
      .gap(8)
      .items_center()
      .rounded(8)
      .text_size(12.5)
      .when(last, (el) => el.mb(4))
      .when(on, (el) => el.bg(t.selected))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .when(tab.settled, (el) => el.opacity(0.55))
      .on_click(() => {
        if (a) run("pane.focus", { pane: a.pane });
        else {
          run("space.select", { id: w.id });
          run("tab.select", { id: tab.id });
        }
      })
      .on_mouse_down("right", (_e, cx) => {
        cx.stop_propagation();
        openOverlay({ mod: "tab-menu", kind: "popup", width: 240, props: { tab: "tab", target: { id: tab.id, space: w.id, terminal: a?.address } } });
      })
      .child(div().absolute().left(rail).top(0).bottom(last ? 6 : 0).w(1).bg(t.border))
      .child(h_flex().flex_none().gap(6).items_center().child(badge).child(h_flex().w(16).flex_none().justify_center().child(pic)))
      .child(div().flex_1().min_w(0).truncate().text_color(quiet ? t.muted : t.foreground).child(summary))
      .when(Boolean(since), (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child(duration(Date.now() - since))))
      .when(Boolean(a), (el) => el.child(status(t, a.status)));
  }

  compact({ w, i }, t) {
    return h_flex()
      .id(`space-${w.id}`)
      .h(26)
      .flex_none()
      .justify_center()
      .gap(4)
      .when(w.active, (el) => el.bg(t.raised))
      .hover((s) => s.bg(t.hover))
      .on_click(() => run("space.select", { id: w.id }))
      .child(div().text_color(w.active ? t.foreground : t.muted).child(String(i + 1)))
      .child(div().text_color(tone(t, w.status)).child(glyph(w.status)));
  }

  render() {
    const t = theme();
    const collapsed = narrow();
    const palette = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];
    const sp = spaces();
    const ids = new Set(sp.map(p => p.id));
    const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
    let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
    for (const p of sp) {
      if (kept[p.id] || p.name === "~") continue;
      const uses = c => Object.values(kept).filter(v => v === c).length;
      kept[p.id] = palette.reduce((best, c) => uses(c) < uses(best) ? c : best);
      changed = true;
    }
    if (changed) setShared("space.colors", kept);
    this.tidySections(sp);
    this.syncOrder();
    // Read once per render for every tab row (each read copies the list).
    this.ps = panes();
    this.ags = agents();
    this.track(this.ags, Date.now());
    const anyOpen = sp.some((s) => this.isOpen(s.id));
    const of = sectionMap();
    const focus = this.focusCard(this.ordered().filter((r) => sectionOf(r.w.id, of) === "focus"), t, collapsed);
    const headButton = (id) => div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(6).hover(s => s.bg(t.hover).text_color(t.foreground));
    return v_flex().id("spaces-root").size_full().min_h(0).bg(t.chrome).text_size(13)
      .on_size_change((size, cx) => { this.size = size; cx.notify(); })
      .child(h_flex().h(31).pl(16).pr(10).items_center().justify_between().text_size(11.5).text_color(t.dim)
        .when(!collapsed, el => el.child("Spaces"))
        .child(h_flex().gap(2).items_center()
          .when(!collapsed, el => el.child(headButton("tabs-toggle")
            .when(anyOpen, b => b.bg(t.raised).text_color(t.muted))
            .tooltip(anyOpen ? "Hide all tabs" : "Show all tabs")
            .on_click((_e, cx) => { this.toggleAll(); cx.notify(); })
            .child(svg("mods/workspace-chrome/layers.svg").size(14))))
          .child(headButton("space-new").on_click(() => run("space.new")).child(svg("mods/workspace-chrome/plus.svg").size(14)))))
      .when(Boolean(focus), (el) => el.child(focus))
      .child(v_flex().flex_1().min_h(0).px(8).pb(14).overflow_y_scrollbar().mode("always")
        .on_mouse_up("left", (_e, cx) => { this.pressed = null; cx.notify(); })
        .children(this.grouped(t, collapsed)));
  }
}
