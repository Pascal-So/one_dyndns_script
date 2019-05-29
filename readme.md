# Hacky DynDNS script for One.com

Perform [DynDNS](https://en.wikipedia.org/wiki/Dynamic_DNS) updates on A or AAAA records on your [One.com](https://www.one.com) account.

One.com doesn't have an API to set the IP of a DNS record. We can still however just send the requests that get sent when you update a record in the One.com control panel.

## Initial Setup

You already need to have a DNS record on your One.com account that can then be updated by the script. Every record in there has an id, which you can find out for example by looking at the request that is sent by your browser when you update the record.

Make sure the script can read/write in the directory it is plaed in. The script stores your last public IP in the file `last_ip.log` and reads variables from `.env`.

Copy the file `.env.example` to `.env` and adjust your One.com credentials and other settings.

Add a cron job to run the script every 5 minutes.

```
*/5 * * * * cd /path/to/script && ./one_dyndns.sh > /dev/null
```

## Caveats

The minimum TTL on One.com is 600 = 10 minutes, so you might face some downtime when your IP changes.

This script sets the record to your current public IP, this might not be what you want, but it shouldn't be too hard to change in `one_dyndns.sh`
