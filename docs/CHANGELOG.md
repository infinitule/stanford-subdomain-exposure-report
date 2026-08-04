# Method & revision history

Corrections to method and to claims made in earlier revisions of this report. Kept separate
from the report itself: the reader-facing retractions of named third-party hosts are in
[`../README.md` §3](../README.md#3-excluded--false-positives).

## Withdrawn claims

| Claim | Status |
|-------|--------|
| "Active exposure — two AWS-resolving hosts LIVE" | **Withdrawn.** Both resolve but have no listener. An A record was treated as evidence of a running service without probing for one. Residual risk is dangling-DNS re-acquisition, not active serving. |
| "NXDOMAIN = remediated" | **Withdrawn.** Absence of a DNS record is evidence of neither prior existence nor cleanup. Per-host existence is now established via Certificate Transparency and Internet Archive captures. |
| "At least 11–13 affected hosts" | **Withdrawn.** A flat count conflated confirmed hosts with search-index candidates. Replaced by evidence tiers (A/B/C/D). |
| Compromise of `laneblog.stanford.edu`, `www-ssrl.slac.stanford.edu` | **Not corroborated; withheld.** Allegations against live, operating infrastructure were never promoted to findings. |

## Retracted / excluded hosts

| Host | Resolution |
|------|-----------|
| `cs355.stanford.edu` | Retracted — legitimate course site, continuous 1999→2026. GitHub Pages CNAME and certificate are ordinary custom-domain hosting. |
| `platformlab.stanford.edu` | Excluded — probable false positive. Real research-group site; `/.well-known/*` returns 404, the inverse of the Tier-C spam signature. |
| `widescope.stanford.edu` | Excluded — probable false positive. Legitimate project site with `about.html` and `aboutus_files/`, captured 2011–2016. No spam capture. |

## Reclassifications

| Host | Change |
|------|--------|
| `smc-aws-pub.stanford.edu` | **D → A.** An interim revision recorded "no archive response". It has a Feb-2026 spam capture at HTTP 200 — the most recent in the corpus. |

## Method changes

- **Evidence tiering introduced.** Hosts are graded A (archived spam capture at 200), B
  (archived reachability + index evidence), C (index attribution only), D (insufficient).
  Tier C and D are not treated as confirmed findings.
- **Independent corroboration required.** Search-index attribution alone is no longer
  sufficient to list a host as affected; CT logs and archive captures are checked per host.
- **Raw query output published.** Every tier is backed by a runnable command with its
  observed output, so no claim rests on assertion alone. See
  [`evidence/verification-2026-08-03.md`](evidence/verification-2026-08-03.md).
- **Victim-name masking.** Name segments in evidence URLs are masked as `<name>`; timestamps,
  status codes, and path structure are preserved so results stay reproducible.
