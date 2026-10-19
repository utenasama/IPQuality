# Utenasama focused IP checks

Derived from xykt/IPQuality commit 87397e2c3196ec796f5477c83343c2354df601ea (2026-09-16), under the original AGPL-3.0 license. Modified 2026-10-19.

This fork runs only type/risk flags and media/AI availability checks, with basic IP identity metadata. IPQS, DB-IP and the unused IPWHOIS fields are removed. SMTP, DNSBL, risk-score output and score charts are not part of this profile. Available providers: IP2Location, Scamalytics, ipapi, AbuseIPDB, IPinfo, ipregistry, ipdata. A provider may omit fields it does not supply.

JSON contains Head, Info, Type, Factor and Media. The remaining provider queries are shared with upstream; unused scores may be computed internally but are not exported. Privacy mode is on by default (no public report upload), advertisements/counters are disabled, supporting data uses the audited upstream commit, curl defaults to a 5-second connection timeout, 20-second total timeout and 8 MiB response limit. IPv4-only completion is fixed. The deployment wrapper separately enforces resource and runtime limits.

Usage: `bash ip.sh -n -p -j -f -E -o result.json`. Use Bash 4.3+ and preinstall the upstream dependencies. No credentials, node inventory or private deployment data are stored here.

Run `bash tests/focused.sh` on Linux with Bash 4.3+ and jq. The test mocks all network queries and rejects any unexpected curl call.

Historical DNSBL counts from the original script were not proof that every list answered: it mapped empty dig output and 127.255.255.* responses to Clean, only an exact 127.0.0.2 to Blacklisted, and everything else to Other/Marked. This fork removes that test rather than exposing those counts as trustworthy reputation evidence.
