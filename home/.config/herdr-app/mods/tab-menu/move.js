// Moving a tab to another space, with what Herdr offers. There is no command
// for it, but:
//   - a terminal Herdr hasn't placed is adopted by its labels
//     (herdr.space / herdr.tab), and
//   - ids it has never seen become a new space or tab under exactly those ids.
// So each terminal is parked (its pane goes, it keeps running, its herdr.*
// labels are stripped), then labelled into the destination. Herdr lays the
// destination tab out itself, in pane order; mod panes can't move and stay.

import { run, hc, spaces, panes } from "herdr";

const hex = () => Array.from({ length: 32 }, () => Math.floor(Math.random() * 16).toString(16)).join("");
// Remote ids carry "<machine>/"; labels on that machine use the bare id.
const machineOf = (id) => (id.includes("/") ? id.slice(0, id.lastIndexOf("/") + 1) : "");
const bare = (id) => id.slice(id.lastIndexOf("/") + 1);

async function labels(terminal) {
  const r = await hc(["get", terminal, "--json"]);
  if (r.code !== 0) throw new Error(r.stderr.trim() || `hc get ${terminal} failed`);
  return JSON.parse(r.stdout).labels ?? {};
}

async function until(cx, test, what, ms = 4000) {
  const end = Date.now() + ms;
  while (!(await test())) {
    if (Date.now() > end) throw new Error(`timed out waiting for ${what}`);
    await cx.sleep(40);
  }
}

const place = (terminal, space, tab) =>
  hc(["label", terminal, `herdr.space=${bare(space)}`, `herdr.tab=${bare(tab)}`]);

/** A terminal parked but not yet labelled is invisible: put it back in its old
 *  tab (re-made under the same id if that tab is gone by now). */
export const rescue = (p) => place(p.terminal, p.space, p.tab);

/** Moves `tab` of space `from` to space `to` (null: a new space).
 *  `track.parked` names the terminal between park and label, for rescue(). */
export async function moveTab(cx, { tab, from, to }, track = {}) {
  const src = spaces().find((s) => s.id === from);
  const info = src?.tabs.find((t) => t.id === tab);
  if (!info) throw new Error("that tab is gone");
  const own = panes().filter((p) => p.tab === tab);
  const terms = own.filter((p) => p.terminal).map((p) => p.terminal);
  if (!terms.length) throw new Error("that tab has no terminals");

  const m = machineOf(tab);
  const space = to ?? `${m}sp${hex()}`;
  const dest = `${m}tb${hex()}`;
  const left = own.length - terms.length;

  // One at a time: park must land before the label (park strips labels when
  // the core replies), and the first arrival makes the tab the others join.
  for (const t of terms) {
    track.parked = { terminal: t, space: from, tab };
    run("terminal.park", { terminal: t });
    await until(cx, async () => !(await labels(t))["herdr.space"], `${t} to park`);
    const r = await place(t, space, dest);
    if (r.code !== 0) {
      await rescue(track.parked);
      throw new Error(r.stderr.trim() || `hc label ${t} failed`);
    }
    track.parked = null;
    await until(cx, () => panes().some((p) => p.terminal === t && p.tab === dest), `${t} to arrive`);
  }

  if (info.named) run("tab.rename", { id: dest, name: info.name });
  return { from, space, tab: dest, created: to == null, left, sourceClosed: left === 0 && src.tabs.length === 1 };
}
