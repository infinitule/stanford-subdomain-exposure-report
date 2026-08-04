# Stanford University — Subdomain SEO-Poisoning Exposure Report

**Status:** Post-remediation disclosure — **Rev. 4, independently verified (CT logs + Internet Archive)**
**Classification:** Defensive security finding — publicly observable via search indexes
**Originally observed:** October 2025 · **Independently verified:** 2026-08-03
**Reproduce:** `./tools/sweep.sh` · raw log: `docs/evidence/sweep-2026-08-02.txt`

> **Corrections.** (1) `cs355.stanford.edu`, named in Rev. 3, is **RETRACTED** — it is a
> legitimate, continuously-operating Stanford course site. (2) "NXDOMAIN = remediated" was an
> invalid inference and is withdrawn; prior existence is now evidenced per host via CT logs
> and archive captures. (3) Rev. 2's "active exposure" claim stands withdrawn. Full detail:
> `docs/evidence/verification-2026-08-03.md`.
**Model:** Inspired by the public *HBS MachForm Exposure Report* format (post-remediation, redacted, defensive)

> **Scope note.** This report documents an **infrastructure exposure**: Stanford-owned
> subdomains serving injected SEO-spam pages that public search engines have indexed.
> It deliberately does **not** reproduce the spam content and does **not** compile any
> information about the individuals whose names appear in the spam. Those names are
> attacker-generated bait, not part of the finding, and repeating them would only
> extend the abuse. All evidence below is drawn from public search-engine indexes and
> public DNS/HTTP behavior — no authentication, exploitation, or access to non-public
> data was involved.

---

## 1. Executive summary

At least **13** `*.stanford.edu` subdomains — most bearing names that indicate **test,
development, demo, internal, course, or cloud infrastructure** — were serving
attacker-controlled SEO-spam pages promoting adult "leaked video" content. Google indexed
these pages under the Stanford University brand, so they surfaced in ordinary search results
attributed to Stanford.

**Current state (3 Aug 2026):** the campaign is **no longer being served** — all tested spam
paths return 404 and the AWS-resolving hosts have no listener. Three hosts are confirmed by
archived captures of the spam pages themselves; four rest on search-index evidence alone and
are marked unverified. Residual exposure is **dangling DNS** — records outliving their
backing resources and remaining re-claimable. Search indexes still carry the poisoned
entries, so brand impact persists until de-indexing completes.

The hostname patterns (`testec2.asiaaws`, `edtechdev1`, `ldap-sh3.int.authnz-x`,
`forum-daemo`) are strongly consistent with **orphaned / dangling-DNS subdomains** —
DNS records left pointing at deprovisioned or misconfigured hosting that an attacker was
able to claim and serve content from (a classic *subdomain takeover* → *SEO poisoning*
chain). Several observed hosts no longer resolve in DNS. **No inference of remediation is
drawn from that** — absence of a record is not evidence of prior existence or of cleanup;
per-host existence is evidenced instead via CT logs and archive captures (see
`docs/evidence/verification-2026-08-03.md`).

**Primary impacts:** brand/reputation abuse, search-index poisoning, erosion of trust in
the `stanford.edu` namespace, and a latent foothold that could be repurposed for phishing
or malware distribution using Stanford's domain credibility.

---

## 2. Affected assets (observed)

Observed from public search-engine indexes and the supplied screenshot exhibit. Exact URLs
and spam slugs are **redacted**; only the host and its apparent role are listed.

**13 hosts** carried via a parameterized seed loop (13 `site:stanford.edu` keyword queries)
plus per-host `dig`, HTTP `HEAD`, and TLS metadata. Hostnames only; slugs and the
individuals' names they contain are withheld. State as of **2026-08-02 17:26 UTC**.

| # | Subdomain (host) | Apparent role | DNS | Service | Residual risk |
|---|------------------|---------------|-----|---------|---------------|
| 2 | `sbc-hc-proxy.stanford.edu` | Proxy host | A `54.185.146.111` (AWS us-west-2) | none | Dangling A → IP re-acquisition |
| 3 | `smc-aws-pub.stanford.edu` | AWS public host | A `54.153.7.154` (AWS us-west-1) | none | Dangling A → IP re-acquisition |
| 4 | `widescope.stanford.edu` | Opaque | A `204.236.161.254` (AWS us-west-1) | none | Dangling A → IP re-acquisition |
| 5 | `webapp-new.itlab.stanford.edu` | IT Lab web-app host | `CNAME → .` (nulled) | — | Malformed record |
| 6 | `ldap-sh3.int.authnz-x.stanford.edu` | Internal auth/LDAP | NXDOMAIN | — | Removed |
| 7 | `testec2.asiaaws.stanford.edu` | AWS EC2 test host | NXDOMAIN | — | Removed |
| 8 | `edtechdev1.stanford.edu` | EdTech development host | NXDOMAIN | — | Removed |
| 9 | `forum-daemo.stanford.edu` | Forum demo host | NXDOMAIN | — | Removed |
| 10 | `eedpoccmg01.stanford.edu` | Opaque / likely POC host | NXDOMAIN | — | Removed |
| 11 | `glucose-dev.stanford.edu` | Development host | NXDOMAIN | — | Removed |
| 12 | `swarm01.ic.stanford.edu` | Instructional-computing node | NXDOMAIN | — | Removed |
| 13 | `snipe-it.stanford.edu` | Snipe-IT asset-management app | NXDOMAIN | — | Removed |
| 14 | `platformlab.stanford.edu` | Platform Lab (research group) | NXDOMAIN | — | Removed |

**RETRACTED — `cs355.stanford.edu`.** Rev. 3 listed this as a compromised production course
host. Archive history shows a legitimate course site running continuously 1999→2026; its
GitHub Pages CNAME and certificate are ordinary custom-domain hosting. Removed from corpus.

### Unverified candidates — not findings

Carried forward from an interim revision and **retained only as open questions**. Rows 5–7
below did not survive the 2026-08-03 verification pass and must not be cited as findings.
(Earlier duplicate rows asserting `sbc-hc-proxy` / `smc-aws-pub` were "**LIVE**" have been
removed: both resolve with **no listener** — see the Corrections block above.)

| # | Subdomain (host) | Apparent role | Status |
|---|------------------|---------------|--------|
| 5 | `shift.stanford.edu` | Program site | ⚠️ **UNVERIFIED** — casino-spam claim not corroborated; DNS NXDOMAIN |
| 6 | `laneblog.stanford.edu` | Stanford Medicine (Lane) blog | ⚠️ **UNVERIFIED** — resolves to WP Engine `141.193.213.10/.11`, HTTP 200. **No evidence of compromise was independently confirmed.** Claim withheld pending verification |
| 7 | `www-ssrl.slac.stanford.edu` | SLAC / SSRL | ⚠️ **UNVERIFIED** — resolves `134.79.138.118`, HTTP 302. **Drupal upload-abuse claim not independently confirmed.** Claim withheld pending verification |

> ### ⚠️ Unverified rows (5–7)
> These rows assert compromise of **live, operating** Stanford/SLAC infrastructure. Those
> assertions were **not** produced by, and have **not** survived, the independent
> verification pass of 2026-08-03 (CT logs + Internet Archive). Given that a similar
> uncorroborated claim about `cs355.stanford.edu` proved false, these rows are marked
> unverified and must not be treated as findings until archive or log evidence is produced.
> Live-host allegations against a medical blog and a national-laboratory site carry real
> institutional harm if wrong.

> **Wider sweep (post-initial).** A broader `site:stanford.edu` keyword sweep across adult,
> casino/gambling, and OnlyFans categories expanded the candidate set beyond the original
> four test/dev hosts. **That expansion has since been triaged by evidence tier:** five hosts
> are Tier A/B-confirmed, four are Tier C, one is Tier D, and three are excluded as retracted
> or probable false positives. The interim claim that production and lab infrastructure
> (`slac`, the Stanford Medicine blog) was affected **was not corroborated** and is withheld.
> Live hosts were **not** fetched; evidence is DNS, CT logs, archive captures, and the public
> search index. Slugs and any victim names are withheld.

> **Why the hostnames matter.** `test*`, `*dev1`, `*-daemo` (demo), and
> `int.authnz-x` (internal auth) are names for non-production or internal systems. Their
> presence in the **public** search index means non-production DNS is publicly resolvable
> and, in at least these cases, serving third-party content. Internal auth-adjacent naming
> (`ldap`, `authnz`) makes host #1 the highest-priority item to verify.

---

## 3. Likely mechanism (hypothesis)

Ordered from most to least consistent with the evidence. This is a **hypothesis for
Stanford's team to confirm** with internal DNS/hosting records — not an asserted breach.

1. **Dangling DNS / subdomain takeover.** A DNS record (A/CNAME) points at a
   cloud resource (e.g., an EC2 instance or a SaaS/hosting endpoint) that was
   deprovisioned. An attacker re-provisioned a matching resource and now serves content
   from the Stanford hostname. The `testec2.asiaaws` (AWS) naming and its now-absent DNS
   strongly fit this pattern.
2. **Abandoned/misconfigured dev host compromise.** A real but forgotten dev/test/demo
   server left running and unpatched was compromised and turned into a spam doorway.
3. **Open upload / injectable app (MachForm-style).** As in the HBS case, a web app with
   an unauthenticated file-upload or content-injection path lets an attacker write pages
   the web root then serves. `forum-daemo` (a forum) is the kind of app that can expose
   this.

In all three cases the downstream effect is identical: **SEO poisoning** — the attacker
mass-produces keyword-stuffed pages, gets them crawled, and rides Stanford's domain
authority to rank in search results.

---

## 4. Attack chain

```
Orphaned/misconfigured Stanford subdomain
        │  (attacker gains control or injection foothold)
        ▼
Attacker publishes bulk SEO-spam pages (adult "leaked video" bait)
        │
        ▼
Search-engine crawler indexes pages under *.stanford.edu
        │
        ▼
Pages rank in public search, attributed to "Stanford University"
        │
        ▼
Victims click Stanford-branded results → spam / scam / potential malware / phishing funnel
```

---

## 5. Weakness mapping (CWE)

| CWE | Weakness | Relevance |
|-----|----------|-----------|
| CWE-350 | Reliance on reverse DNS / stale DNS resolution | Dangling records enabling takeover |
| CWE-1327 | Binding to an unrestricted / abandoned resource | Deprovisioned host reclaimed by attacker |
| CWE-16 / CWE-2 | Configuration / environmental weakness | Non-prod and internal hosts publicly exposed |
| CWE-434 | Unrestricted upload of dangerous file type | If injection is via an open upload app |
| CWE-284 | Improper access control | Internal (`authnz`/`ldap`) host publicly reachable |

---

## 6. Risk assessment

| Scenario | Likelihood | Impact | Priority |
|----------|-----------|--------|----------|
| Brand/reputation damage (already occurring — indexed under Stanford) | **Certain** | Medium–High | **P1** |
| Namespace repurposed for phishing using stanford.edu trust | Medium | **High** | **P1** |
| Malware / drive-by distribution from a controlled subdomain | Low–Medium | High | P2 |
| Internal/auth host (#1) exposes further internal surface | Unknown — verify | **High** | **P1 (verify first)** |
| Continued/expanding index poisoning across more subdomains | High | Medium | P2 |

---

## 7. Recommended remediation

**Immediate (0–7 days)**
- **Delete the three dangling A records** — `sbc-hc-proxy` (54.185.146.111), `smc-aws-pub`
  (54.153.7.154), `widescope` (204.236.161.254). Nothing listens behind them today, but cloud
  IPs are recycled and the records stay re-claimable until removed.
- Enumerate DNS for `stanford.edu` and flag any remaining records pointing to deprovisioned or
  third-party-controlled endpoints (dangling A/CNAME). Re-verify the auth-related host
  (`ldap-sh3.int.authnz-x`) stays removed given its naming.
- Complete **search-index removal** — the hosts are clean but the index is not.
- Take down / null-route the affected subdomains; remove or correct the dangling DNS
  records so the hostnames can no longer be claimed.
- Submit removal / de-index requests to Google Search Console (and Bing Webmaster Tools)
  for the poisoned URLs; use URL removal + "site moved/removed" as appropriate.

**Short term (1–4 weeks)**
- Inventory all non-production (`test*`, `*dev*`, `demo`, `staging`) and internal
  (`int.*`, `authnz*`, `ldap*`) subdomains; confirm which should be public at all, and
  restrict the rest to VPN/allowlist.
- If any host ran an injectable app (upload/forum), preserve logs, image the host, and
  determine the injection vector before rebuilding.

**Structural (1–3 months)**
- Adopt a DNS lifecycle process: decommission DNS records **before** tearing down the
  backing resource; periodic dangling-DNS scanning (e.g., automated subdomain-takeover
  checks) in CI/monitoring.
- Central registry of subdomains with an owner, purpose, and expiry for each.
- Continuous search-index monitoring for `site:stanford.edu` spam keywords to catch
  recurrence early.

---

## 8. Privacy / policy notes

- **No student/PII exposure is claimed here.** Unlike a form-data leak, this finding is
  primarily **brand and namespace abuse plus search poisoning**. If investigation reveals
  an injectable app that also handled real submissions, revisit under FERPA/GDPR.
- The individuals named in the spam titles are **not** part of this report. The spam
  fabricates or exploits their names as clickbait; documenting or repeating those details
  would extend harm to those people and adds nothing to the security finding.

---

## 9. Disclosure

Recommended path: report to **Stanford University Information Security** —
`security@stanford.edu` (and/or the Stanford abuse/security contact) with this document
and the redacted exhibit. Because at least one host already appears cleaned up
(`testec2` DNS absent), align on **post-remediation** publication if any public writeup is
intended, following the HBS report's practice of publishing only after access is blocked
and with all payloads/PII redacted.

---

## 10. Evidence log (redacted)

| Exhibit | Description | Source | Redaction |
|---------|-------------|--------|-----------|
| A | Search-results screenshot showing spam entries attributed to Stanford subdomains — hostnames + "Stanford University" attribution visible | `assets/exhibit-a-search-results.redacted.png` | Title/description bands (victim names + spam titles) blacked out |
| B | Full 14-host corpus sweep, 2026-08-02: DNS + HTTP + note per host; apex control `171.67.215.200` | `tools/sweep.sh` → `docs/evidence/sweep-2026-08-02.txt` | — (reproducible) |
| C | CT-log existence + Internet Archive captures per host; evidence tiers A–D | `crt.sh`, Wayback CDX API | — (reproducible) |
| D | Spam-path liveness: indexed path `404`, root `200`, control `404` | `curl -I` (status codes only) | Spam URL withheld |

**Withheld by design:** full spam URLs/slugs and titles, the individuals' names they contain,
and **any screenshot or capture of the spam pages themselves**. These attach real, identifiable
people to fabricated sexual content; republishing them — even framed as evidence — would
constitute re-publication of non-consensual sexual claims about private individuals and
re-amplify the campaign in search. The redacted exhibit plus reproducible DNS/HTTP/TLS
evidence establishes the finding without them, and is stronger forensically. As of Rev. 3 the
pages return 404 regardless, so no live capture exists.

*Prepared as a defensive, disclosure-oriented summary. Findings are hypotheses where
noted and should be confirmed against Stanford's internal DNS, hosting, and application
records before any external publication.*
