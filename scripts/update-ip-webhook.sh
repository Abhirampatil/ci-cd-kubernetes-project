#!/usr/bin/env bash
# Runs at every boot. Detects the new public IP, then updates
# (1) the Jenkins URL and (2) the GitHub webhook.
set -u
source /etc/cicd/webhook.env   # GITHUB_REPO, GITHUB_TOKEN, optional AUTO_SHUTDOWN_MINUTES

log() { echo "[$(date '+%F %T')] $*"; }

# ---- 1. Get this instance's public IP (IMDSv2) ----
IP=""
for i in $(seq 1 30); do
  T=$(curl -s -m 3 -X PUT http://169.254.169.254/latest/api/token \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
  IP=$(curl -s -m 3 -H "X-aws-ec2-metadata-token: $T" \
        http://169.254.169.254/latest/meta-data/public-ipv4)
  if [[ "$IP" =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}$ ]]; then break; fi
  IP=""; sleep 5
done
if [[ -z "$IP" ]]; then log "ERROR: could not get public IP"; exit 1; fi
log "Public IP: $IP"

# ---- 2. Update the Jenkins URL (runs before Jenkins starts) ----
CFG=/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml
if [[ -f "$CFG" ]]; then
  sed -i "s|<jenkinsUrl>.*</jenkinsUrl>|<jenkinsUrl>http://$IP:8080/</jenkinsUrl>|" "$CFG"
  log "Jenkins URL set to http://$IP:8080/"
fi

# ---- 3. Update (or create) the GitHub webhook ----
URL="http://$IP:8080/github-webhook/"
API="https://api.github.com/repos/$GITHUB_REPO/hooks"
H=(-H "Authorization: Bearer $GITHUB_TOKEN"
   -H "Accept: application/vnd.github+json"
   -H "X-GitHub-Api-Version: 2022-11-28")
UPDATE=$(jq -n --arg u "$URL" '{config:{url:$u,content_type:"json"},active:true}')
CREATE=$(jq -n --arg u "$URL" '{name:"web",active:true,events:["push"],config:{url:$u,content_type:"json"}}')

for i in $(seq 1 10); do
  RESP=$(curl -s -m 15 "${H[@]}" "$API")
  if echo "$RESP" | jq -e 'type=="array"' >/dev/null 2>&1; then
    ID=$(echo "$RESP" | jq -r '[.[] | select(.config.url | test("github-webhook"))][0].id // empty')
    if [[ -n "$ID" ]]; then
      CODE=$(curl -s -m 15 -o /dev/null -w '%{http_code}' -X PATCH "${H[@]}" "$API/$ID" -d "$UPDATE")
    else
      CODE=$(curl -s -m 15 -o /dev/null -w '%{http_code}' -X POST "${H[@]}" "$API" -d "$CREATE")
    fi
    if [[ "$CODE" == "200" || "$CODE" == "201" ]]; then
      log "Webhook now points to $URL (HTTP $CODE)"; break
    fi
    log "GitHub returned HTTP $CODE, retrying..."
  else
    log "GitHub API problem (bad token or no internet): $(echo "$RESP" | head -c 200)"
  fi
  sleep 10
done

# ---- 4. Optional safety: auto power-off to save credits ----
if [[ -n "${AUTO_SHUTDOWN_MINUTES:-}" ]]; then
  shutdown -h +"$AUTO_SHUTDOWN_MINUTES" "Auto shutdown to save credits"
  log "Auto shutdown scheduled in $AUTO_SHUTDOWN_MINUTES minutes (cancel: sudo shutdown -c)"
fi
exit 0