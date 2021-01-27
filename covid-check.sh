#!/bin/bash

SLOTS_PATH="data/slots.json"
EARLIEST_PATH="data/earliest"
CONFIG_PATH="data/config.json"

log() {
    if [[ $DEBUG -gt 0 ]]; then
        echo "$@"
    fi
}

if [[ -f "$EARLIEST_PATH" ]]; then
    startEarliest="$(cat "$EARLIEST_PATH")"
else
    startEarliest=2099-01-01
fi

fetch() {
    dateWindow="25"
    today=$(date -v '+0d' +'%Y-%m-%d')
    endDate=$(date -v "+${dateWindow}d" +'%Y-%m-%d')
    locationId="$1"
    URL="https://www.walgreens.com/hcschedulersvc/svc/v1/slots?locationId=${locationId}&serviceId=99&startDateTime=${today}&endDateTime=${endDate}"
    log "$URL"
    curl -s "$URL" > "$SLOTS_PATH"
}

checkEarliestDate() {
    newEarliest=$(jq -r '.schedules | map(select(.slots != [])) | .[0].date' < $EARLIEST_PATH)
    #log "Last Earliest: $startEarliest || New Earliest: $newEarliest"
    if [[ "$startEarliest" > "$newEarliest" ]]; then
        echo "$newEarliest" | tee "$EARLIEST_PATH"
    else
        [[ "$startEarliest" > "$newEarliest" ]]
    fi
}

recipients() {
    jq -r ".recipients | .[]" < "$CONFIG_PATH"
}

config_value() {
    jq -r ".$1" < "$CONFIG_PATH"
}

locations() {
    jq -r '.locations | to_entries[] | [.key, .value] | @tsv' < "$CONFIG_PATH"
}

alertNewDate() {

    message=$(cat <<EOF
New Earlier Appointment at $1, $(cat "$EARLIEST_PATH")

Last Earliest was $startEarliest

Schedule At: https://bit.ly/3onC5Kb
EOF
           )
    log "$message"

    from="$(config_value from)"
    sid="$(config_value sid)"
    token="$(config_value secret)"
    while IFS= read -r recipient; do
        log "Sending to $recipient"
        curl -s -X POST -d "Body=${message}" \
             -d "secret=${token}" -d "From=${from}" -d "To=${recipient}" \
             "https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages" \
             -u "${sid}:${token}" && log "Sent to $recipient"
    done <<< "$(recipients)"
    exit 0
}

while IFS= read -r line; do
    name="$(echo "$line" | cut -f1)"
    locationId=$(echo "$line" | cut -f2)
    log "$name @ $locationId"
    fetch "$locationId"
    checkEarliestDate && alertNewDate "$name" || echo "No new appointments found at $name"
done <<< "$(locations)"
