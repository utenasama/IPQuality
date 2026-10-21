# Utenasama focused IP checks

Derived from xykt/IPQuality commit 87397e2c3196ec796f5477c83343c2354df601ea (2026-09-16), under the original AGPL-3.0 license. Modified 2026-10-21.

This fork retains basic IP metadata, type attributes, six separate risk indicators, risk flags and media/AI availability checks. IPQS and DB-IP queries are enabled. The unused IPWHOIS fields remain removed because upstream has no corresponding query. SMTP and DNSBL are not part of this profile. Available providers: IP2Location, Scamalytics, ipapi, AbuseIPDB, IPinfo, ipregistry, ipdata, IPQS, DB-IP. A provider may omit fields it does not supply.

JSON contains Head, Info, Type, Score, Factor and Media. Score exports IP2LOCATION, SCAMALYTICS, ipapi, AbuseIPDB, IPQS and DBIP. IPQS exports `ipqs[score]` (upstream incorrectly reads `ipapi[ipqs]`). DB-IP maps low/medium/high threat levels to 0/50/100; these are not probability scores. Both DB-IP requests use the report address family, including IPv6. Empty, failed or malformed responses remain unknown and never reuse a previous result. Scores have different meanings and must not be averaged. Privacy mode is on by default (no public report upload), advertisements/counters are disabled, supporting data uses the audited upstream commit, curl defaults to a 5-second connection timeout, 20-second total timeout and 8 MiB response limit. IPv4-only completion is fixed. The deployment wrapper separately enforces resource and runtime limits.

Usage: `bash ip.sh -n -p -j -f -E -o result.json`. Use Bash 4.3+ and preinstall the upstream dependencies. No credentials, node inventory or private deployment data are stored here.

Run `bash tests/focused.sh` and `bash tests/providers.sh` on Linux with Bash 4.3+ and jq. The test mocks all network queries and rejects any unexpected curl call.

Historical DNSBL counts from the original script were not proof that every list answered: it mapped empty dig output and 127.255.255.* responses to Clean, only an exact 127.0.0.2 to Blacklisted, and everything else to Other/Marked. This fork removes that test rather than exposing those counts as trustworthy reputation evidence.
