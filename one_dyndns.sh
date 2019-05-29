#!/usr/bin/env bash
set -eu

last_ip_file="last_ip.log"
ip_changes_logfile="ip_changes.log"

if [[ ! -f "$last_ip_file" ]]; then
    touch "$last_ip_file"
fi

ip=$(curl --max-time 5 -s http://whatismyip.akamai.com/)
# If we're offline, the script stops here because of -e
# and returns curl's error code, probably 28: timeout.

last_ip=$(cat "$last_ip_file")

# Only update the record if the IP has changed
if [[ "$ip" != "$last_ip" ]]; then
    ./update_onedotcom_dns_record.sh $ip
    echo $ip > "$last_ip_file"

    if [[ -v ip_changes_logfile && "$ip_changes_logfile" != "" ]]; then
        echo "[$(date --rfc-3339 seconds)] $ip" >> "$logfile"
    fi
fi
