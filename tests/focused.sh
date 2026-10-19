#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
source ./ip.sh
calls=$(mktemp)
trap 'rm -f "$calls"' EXIT
curl(){ echo 'Unexpected network request' >&2; exit 99; }
mode_lite=0; mode_json=1; mode_output=0; fullIP=1; ADLines=0
for provider in maxmind ipinfo scamalytics ipregistry ipapi abuseipdb ip2location ipdata; do
 eval "db_${provider}(){ echo ${provider} >> \"\$calls\"; }"
done
for fn in MediaUnlockTest_TikTok MediaUnlockTest_DisneyPlus MediaUnlockTest_Netflix MediaUnlockTest_YouTube_Premium MediaUnlockTest_PrimeVideo_Region MediaUnlockTest_Reddit OpenAITest; do
 eval "$fn(){ echo $fn >> \"\$calls\"; }"
done
hide_ipv4(){ :; }; hide_ipv6(){ :; }
show_head(){ :; }; show_basic(){ :; }; show_type(){ :; }; show_factor(){ :; }; show_media(){ :; }; show_tail(){ :; }
check_IP 8.8.8.8 4 >/dev/null
[[ $(wc -l < "$calls") -eq 15 ]]
printf '%s' "$ipjson" | jq -e 'keys == ["Factor","Head","Info","Media","Type"] and .Head.IP == "8.8.8.8" and (.Factor.Proxy | has("IPQS") or has("DBIP") or has("IPWHOIS") | not)' >/dev/null
for fn in db_ipqs db_dbip check_mail check_dnsbl check_dnsbl_parallel; do
 if declare -F "$fn" >/dev/null; then echo "Disabled function present: $fn" >&2; exit 1; fi
done
printf 'Focused checks: no disabled queries, mail/DNSBL or score output\n'
