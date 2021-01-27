This tool was created to text my family when a new appointment opens up for a
COVID vaccination at the pharmacies nearest my grandmother. It is hacky and not
production-ready. Use at your own risk!

# Requirements
* twilio account, sms number, token
* `jq`
* bsd `date` - GNU `date` users change the calls to `date` like so:
```
+    today=$(date '+%Y-%m-%d')
+    endDate=$(date '+%Y-%m-%d' -d "$today + ${dateWindow} days")
```


# Usage

1. clone this repo
1. Get your location IDs by tracing the schedule request with your browser's Developer
   Tools at https://www.walgreens.com/findcare/vaccination/covid-19/appointment/date-time
2. Add the locationIds and their friendly string you want to scrape into the
   config as KV pairs, along with the other values listed in `data/config.json`
   (see `data/config.json.example`), 
3. Add the script to crontab: `*/30 * * * * cd $repo && bash -c "./covid-check.sh >> run.log"

n.b. make sure your `crontab` `PATH` is configured appropriately if you install
`jq` etc. through homebrew or macports. You may need to add
`PATH=/usr/local/bin:/usr/bin:/bin` to the beginning of your `crontab` if you've
not done so previously.
