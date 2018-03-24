#!/bin/bash

# get the disk usage output, and format it to get only filesystem, percentage used and mountpoint
usageList=`df -h | grep ^/dev | tr -s " " | cut -d" " -f1,5,6`

# get hostname
host=`hostname`

# iterate through each line
while read item; do
    # extract the values from the line in variables
    device=`echo $item | cut -d" " -f1`
    percentage=`echo $item | cut -d" " -f2 | tr -d "%"`
    mountedOn=`echo $item | cut -d" " -f3`

    # for the filesystems with more than 80% disk usage
    if [[ "$percentage" -ge "80" ]]; then
        # if it's a rbd device
        if [[ "$device" =~ rbd ]]; then

            # parse data by what it's used
            usedBy=`echo $mountedOn | awk -F/ '{print $NF}'`

            # post the request to the slack integration
            curl -X POST \
            -H 'Content-type: application/json' \
            --data '{"attachments": [{"fallback": "High disk usage found on one or more devices", "color": "#e01563", "title": "High disk usage on *'"$host"'*!", "fields": [{"title": "Host", "value": "'"$host"'"}, {"title": "Device", "value": "'"$device"'"}, {"title": "Used by", "value": "'"$usedBy"'"}, {"title": "Percentage used", "value": "'"$percentage"'%"}, {"title": "Mount","value": "'"$mountedOn"'"}]}], "channel": "'"$ENV_SLACK_CHANNEL"'", "link_names": 1, "username": "disk-usage-bot", "icon_emoji": ":floppy_disk:"}' \
            $ENV_SLACK_HOOK
        # else if it's other device
        else
            # post the request to the slack integration
            curl -X POST \
            -H 'Content-type: application/json' \
            --data '{"attachments": [{"fallback": "High disk usage found on one or more devices", "color": "#e01563", "title": "High disk usage on *'"$host"'*!", "fields": [{"title": "Host", "value": "'"$host"'"}, {"title": "Device", "value": "'"$device"'"}, {"title": "Percentage used","value": "'"$percentage"'%"}, {"title": "Mount","value": "'"$mountedOn"'"}]}], "channel": "'"$ENV_SLACK_CHANNEL"'", "link_names": 1, "username": "disk-usage-bot", "icon_emoji": ":floppy_disk:"}' \
            $ENV_SLACK_HOOK
        fi
    fi

# feed the while with usageList
done << EOF
    $usageList
EOF
