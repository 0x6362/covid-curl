# requirements
* twilio account
* `jq`

1. Get your location IDs by scraping the schedule request with the Developer
   Tools at https://www.walgreens.com/findcare/vaccination/covid-19/appointment/date-time
2. Add the locationIds and their friendly string you want to scrape into the
   config as KV pairs in `data/config.json`
3. Add the script to crontab: `*/30 * * * * bash -c "cd $repo_folder && ./covid-check.sh"`
