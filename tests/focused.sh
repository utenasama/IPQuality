#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
source ./ip.sh
calls=$(mktemp)
trap 'rm -f "$calls"' EXIT
curl(){ echo 'Unexpected network request' >&2; exit 99; }
mode_lite=0; mode_json=1; mode_output=0; fullIP=1; ADLines=0
for provider in maxmind ipinfo scamalytics ipregistry ipapi abuseipdb ip2location ipdata ipqs dbip; do
 eval "db_${provider}(){ echo ${provider} >> \"\$calls\"; }"
done
for fn in MediaUnlockTest_TikTok MediaUnlockTest_DisneyPlus MediaUnlockTest_Netflix MediaUnlockTest_YouTube_Premium MediaUnlockTest_PrimeVideo_Region MediaUnlockTest_Reddit OpenAITest; do
 eval "$fn(){ echo $fn >> \"\$calls\"; }"
done
hide_ipv4(){ :; }; hide_ipv6(){ :; }
show_head(){ :; }; show_basic(){ :; }; show_type(){ :; }; show_factor(){ :; }; show_score(){ :; }; show_media(){ :; }; show_tail(){ :; }
ip2location[score]=3; scamalytics[score]=4; ipapi[score]="0.05%"; abuseipdb[score]=0; ipqs[score]=0; ipapi[ipqs]=99; dbip[score]=50
ipqs[proxy]=false; dbip[proxy]=true
check_IP 8.8.8.8 4 >/dev/null
[[ $(wc -l < "$calls") -eq 17 ]]
printf '%s' "$ipjson" | jq -e 'keys == ["Factor","Head","Info","Media","Score","Type"] and (.Score | keys == ["AbuseIPDB","DBIP","IP2LOCATION","IPQS","SCAMALYTICS","ipapi"]) and .Score.ipapi == "0.05%" and .Score.AbuseIPDB == "0" and .Head.IP == "8.8.8.8" and (.Score.IPQS == "0" and .Score.DBIP == "50" and .Factor.Proxy.IPQS == false and .Factor.Proxy.DBIP == true and .Factor.VPN.DBIP == null) and (.Factor.Proxy | has("IPWHOIS") | not)' >/dev/null
for fn in check_mail check_dnsbl check_dnsbl_parallel; do
 if declare -F "$fn" >/dev/null; then echo "Disabled function present: $fn" >&2; exit 1; fi
done
printf 'Focused checks: restored IPQS/DB-IP, six scores, no mail/DNSBL\n'
