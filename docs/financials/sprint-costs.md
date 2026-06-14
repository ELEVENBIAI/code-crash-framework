# Sprint-Kosten — Token-Verbrauch (ccusage, BOO-189)

> Persistierte Snapshots des Token-/Kosten-Verbrauchs. Sub-Agent-Token werden von ccusage evtl. nicht sauber attribuiert (Issues #313/#806/#950).

Diese Datei sammelt **automatisch angehaengte** Token-/Kosten-Snapshots aus
[`ccusage`](https://github.com/ryoppippi/ccusage). Geschrieben wird sie ausschliesslich vom
Capture-Hook `.claude/hooks/ccusage-capture.sh` (BOO-189), der an Sprint-/Story-Grenzen als
Abschluss-Schritt von `/sprint-run`, `/implement` und `/sprint-review` laeuft. Jeder Snapshot
ist die unveraenderte Textausgabe von `ccusage daily` in einem Code-Fence, mit Zeitstempel und
Label als Ueberschrift.

**Was hier landet:** eine Ist-Messung des Token-/Kosten-Verbrauchs aus den lokalen
Claude-Code-Session-Logs — komplementaer zur strukturierten Story-Schaetzung in
`journal/reports/local/.../meta.json` (`token_tracking`, BOO-84). `meta.json` = was die
Pipeline pro Story zu verbrauchen meint; diese Datei = was ccusage in den Logs tatsaechlich
gemessen hat.

> [!warning] Sub-Agent-Limitation
> ccusage attribuiert Token von Sub-Agents (Task-Tool) derzeit nicht zuverlaessig dem
> ausloesenden Lauf zu (ccusage-Issues #313, #806, #950). Snapshots aus Sub-Agent-lastigen
> Laeufen sind eine **Naeherung**, kein Cent-genauer Audit.

---

_Noch keine Snapshots. Der Capture-Hook haengt Eintraege automatisch unterhalb dieser Zeile an —_
_je ein Block pro Sprint-/Story-Abschluss. Nicht von Hand befuellen._
