#!/usr/bin/env bash
set -eu

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 new_ip" >&2
    exit 1
fi
new_ip="$1"

# regex borrowed from https://stackoverflow.com/a/5284410
ipv4_regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$'
if [[ $new_ip =~ $ipv4_regex ]]; then
    dns_record_type="A"
fi

# regex borrowed from https://stackoverflow.com/a/45566010
ipv6_regex='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
if [[ $new_ip =~ $ipv6_regex ]]; then
    dns_record_type="AAAA"
fi

if [[ ! -v dns_record_type ]]; then
    echo "The IP '$new_ip' is not in a valid IPv4/v6 format" >&2
    exit 1
fi

if [[ ! -f ".env" ]]; then
    echo "Could not find .env file" >&2
    exit 1
fi
source ".env"

cookie_file=$(mktemp)

# Password is now stored in .env
# Uncomment the following lines to read password from console.
# read -s -p "Password: " password
# echo ""

echo "Sending requests.."

# login to control panel
curl 'https://www.one.com/admin/login.do' \
    --cookie-jar "$cookie_file" \
    -H 'Referer: https://login.one.com/' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    --data "loginDomain=true&displayUsername=${url_escaped_username}&username=${url_escaped_username}&targetDomain=&password1=${password}&loginTarget="

# update record
curl "https://www.one.com/admin/api/domains/${domain_name}/dns/custom_records/${record_id}" \
    --cookie "$cookie_file" \
    -X PATCH \
    -H 'Referer: https://www.one.com/admin/dns.do?route=dnsrecords' \
    -H 'Origin: https://www.one.com' \
    -H 'Content-Type: application/json' \
    --data "{\"type\":\"dns_service_records\",\"id\":\"${record_id}\",\"attributes\":{\"type\":\"${dns_record_type}\",\"prefix\":\"${prefix}\",\"content\":\"${new_ip}\",\"ttl\":${ttl}}}"

echo

rm "$cookie_file"
