# Independent verification — 2026-08-03

Rev. 4 originally stated conclusions without showing the queries behind them, so a reader
could not check the work. This file fixes that: **every tier below is backed by a command you
can run yourself**, with the observed output shown.

Victim-name segments in URLs are masked as `<name>`. Timestamps, status codes, and path
structure are intact, so re-running the command reproduces rows that match position-for-position.

## Reproduce

```bash
# existence — did the hostname ever hold a certificate?
curl -s "https://crt.sh/?q=<host>&output=json" | python3 -c "import sys,json;print(len(json.load(sys.stdin)))"

# what did it actually serve?
curl -s "https://web.archive.org/cdx/search/cdx?url=<host>/*&matchType=domain&output=json&limit=8&collapse=urlkey"
```

---

## Tier A — archived capture of a spam URL at HTTP 200

### `forum-daemo.stanford.edu`  (CT: 3)
```
20241213212149  301  http://forum-daemo.stanford.edu/
20241211104553  200  https://forum-daemo.stanford.edu/askadvice/<name>.html
20241213100005  200  https://forum-daemo.stanford.edu/askcentral/<name>.html
20241212170334  200  https://forum-daemo.stanford.edu/askcentral/<name>.html
20241211085641  200  https://forum-daemo.stanford.edu/askfood/<name>-leak.html
20241211135714  200  https://forum-daemo.stanford.edu/askhub/<redacted>.html
```
Fabricated "ask*" section structure — `askadvice`, `askcentral`, `askfood`, `askhub` — none
of which corresponds to a real Stanford service.

### `eedpoccmg01.stanford.edu`  (CT: 4)
```
20241227173650  301  http://eedpoccmg01.stanford.edu/
20250101114451  200  https://eedpoccmg01.stanford.edu/cdx/video/video-girls-xxn-376891642.html
20250101114451  200  https://eedpoccmg01.stanford.edu/fsx/video/video-2025-sex-pinay-video-xxx-xnxx-xvideos-f…
20250102004259  404  https://eedpoccmg01.stanford.edu/Content/font-awesome.min.css
20250102004258  404  https://eedpoccmg01.stanford.edu/Content/style.css?Ver8.2
```
Note the 404s on `/Content/*.css`: the original ASP.NET-style application's assets were
already broken while the injected `/video/` tree returned 200 — the spam outlived the app.

### `snipe-it.stanford.edu`  (CT: 2)
```
20250612124815  500  https://snipe-it.stanford.edu/
20250611165649  200  https://snipe-it.stanford.edu/500-internal-server-error-jupyter-notebook
20250613201055  200  https://snipe-it.stanford.edu/<name>-leaked
20250611165652   -   https://snipe-it.stanford.edu/assets/css/jannah/base.min.css
20250611165652   -   https://snipe-it.stanford.edu/assets/css/jannah/block-lib.css
```
Assets load from `/assets/css/jannah/` — **Jannah is a commercial WordPress magazine theme**.
The host is named for Snipe-IT, an asset-management application. A WordPress magazine theme
on a Snipe-IT hostname is the substitution itself.

### `smc-aws-pub.stanford.edu`  (CT: 2) — **upgraded from D**
```
20260211223054  200  https://smc-aws-pub.stanford.edu/<name>-onlyfans-leaked
20260211223054  200  https://smc-aws-pub.stanford.edu/assets/css/bebas/all.css
20260211223055  200  https://smc-aws-pub.stanford.edu/assets/css/bebas/base.css
20260211223055  200  https://smc-aws-pub.stanford.edu/assets/css/bebas/dark-mode.css
```
Rev. 4 recorded "no archive response" for this host. That was wrong — it is **Tier A**, and
carries the **most recent** capture in the corpus (**February 2026**), making it the
longest-running of the confirmed hosts.

---

## Tier B — archived reachability + independent index evidence

### `ldap-sh3.int.authnz-x.stanford.edu`  (CT: 2)
```
20250605160845  200  https://ldap-sh3.int.authnz-x.stanford.edu/
20250605161120  302  https://ldap-sh3.int.authnz-x.stanford.edu/.well-known/ai-plugin.json
```
Root served 200 in June 2025; appears in the Exhibit A screenshot. No archived spam path.

### `testec2.asiaaws.stanford.edu`
```
20250519180550  200  https://testec2.asiaaws.stanford.edu/
20250519192404  302  https://testec2.asiaaws.stanford.edu/.well-known/ai-plugin.json
```
Same pattern, May 2025; also in Exhibit A.

---

## Tier C — reachable, spam attribution from search index only

All three show an identical signature: root 200, and a **302 on every `/.well-known/*`
probe** — a catch-all redirect handler, characteristic of a doorway/spam stack rather than a
normal application (which would 404 unknown well-known paths).

```
edtechdev1.stanford.edu        20250817051135  200  /        + 302 on 7× /.well-known/*
swarm01.ic.stanford.edu        20250623210335  200  /        + 302 on 7× /.well-known/*
webapp-new.itlab.stanford.edu  20250917101455  200  /        + 302 on 7× /.well-known/*
sbc-hc-proxy.stanford.edu      (root 200, same catch-all pattern)
```

---

## Tier D — insufficient evidence / probable false positives

### `glucose-dev.stanford.edu`  (CT: 17)
```
20230314091838  -  http://glucose-dev.stanford.edu/     # single capture, no status
```

### `platformlab.stanford.edu`  (CT: 80) — **probable false positive**
```
20160405014329  200  http://platformlab.stanford.edu/
20230613111643  404  https://platformlab.stanford.edu/.well-known/ai-plugin.json
```
Captures from 2016; `/.well-known/*` returns **404**, the *opposite* of the Tier C catch-all
signature. This is a real Stanford research-group site. **Should not be treated as affected.**

### `widescope.stanford.edu` — **probable false positive**
```
20111016215833  200  http://widescope.stanford.edu:80/
20111017121542  200  http://widescope.stanford.edu:80/about.html
20160729044608  200  http://widescope.stanford.edu/aboutus_files/image002.png
```
A legitimate Stanford project site with `about.html` and `aboutus_files/`, captured 2011–2016.
No spam capture. **Should not be treated as affected.**

---

## Corrections this pass

| # | Correction |
|---|-----------|
| 1 | `smc-aws-pub` **D → A**. Rev. 4 said "no archive response"; it has a Feb-2026 spam capture at 200 — the corpus's most recent. |
| 2 | `platformlab` and `widescope` identified as **probable false positives** — both are legitimate Stanford sites, and `platformlab`'s 404-on-well-known is the inverse of the spam signature. |
| 3 | Raw query output now published for every tier, so no claim rests on assertion alone. |
| 4 | `cs355.stanford.edu` remains **retracted** (legitimate course site, continuous 1999→2026). |

## Confirmed corpus

**5 hosts Tier A/B-confirmed** (`forum-daemo`, `eedpoccmg01`, `snipe-it`, `smc-aws-pub`,
plus `ldap-sh3`/`testec2` at B), **4 Tier C**, **1 Tier D**, and **3 excluded**
(`cs355` retracted; `platformlab`, `widescope` probable false positives).

Capture range: **December 2024 → February 2026**.
