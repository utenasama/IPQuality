#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
source ./ip.sh
show_progress_bar(){ :; }
kill_progress_bar(){ :; }
sinfo[ldatabase]=10
IP=47.180.0.149
fixture='{"fraud_score":0,"country_code":"US","proxy":false,"tor":false,"vpn":false,"recent_abuse":false,"bot_status":false}'
curl(){ printf '%s' "$fixture"; }
db_ipqs 4
[[ ${ipqs[score]} == 0 && ${ipqs[proxy]} == false && ${ipqs[countrycode]} == US ]]
# Missing, malformed and failed requests must never inherit the previous score.
for fixture in '{}' 'null' '<html>unavailable</html>' '' '{"success":false,"fraud_score":0}' '{"fraud_score":"invalid","proxy":"invalid"}'; do
 db_ipqs 4
 [[ -z ${ipqs[score]} || ${ipqs[score]} == null ]]
 [[ -z ${ipqs[proxy]} || ${ipqs[proxy]} == null ]]
done
curl(){ return 28; }
db_ipqs 4
[[ -z ${ipqs[score]} ]]
# Force the report address family for both DB-IP requests to /self.
calls=$(mktemp);trap 'rm -f "$calls"' EXIT
fixture='{"countryCode":"US","isProxy":false,"isCrawler":false,"threatLevel":"low"}'
curl(){
 printf '%s\n' "$*" >> "$calls"
 case "${*: -1}" in
  https://db-ip.com/api/core/) printf '%s' '<div data-api-key="test-key"></div>' ;;
  https://api.db-ip.com/v2/test-key/self?convertCurrencies) printf '%s' "$fixture" ;;
  *) return 99 ;;
 esac
}
for family in 4 6; do
 : > "$calls"
 [[ $family == 4 ]] && IP=47.180.0.149 || IP=2606:4700:4700::1111
 db_dbip "$family"
 [[ ${dbip[score]} == 0 && ${dbip[proxy]} == false ]]
 [[ $(grep -c -- "-$family" "$calls") -eq 2 ]]
done
fixture='{"threatLevel":"medium"}';db_dbip 4;[[ ${dbip[score]} == 50 ]]
fixture='{"threatLevel":"high"}';db_dbip 4;[[ ${dbip[score]} == 100 ]]
fixture='{}';db_dbip 4;[[ -z ${dbip[score]} && ${dbip[proxy]} == null ]]
fixture='<html>unavailable</html>';db_dbip 4;[[ -z ${dbip[score]} && -z ${dbip[proxy]} ]]
curl(){ return 28; };db_dbip 4;[[ -z ${dbip[score]} ]]
printf 'Provider checks: zero/false preserved, missing/errors cleared, DB-IP family matches\n'
