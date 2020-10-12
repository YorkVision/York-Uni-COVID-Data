#!/bin/bash

data=$(\
curl -s https://coronavirus.york.ac.uk \
| pup ':parent-of(:parent-of(div:contains("Current confirmed cases"))) strong text{}' \
| head -n2 \
| paste -sd, \
)
olddata=$(cat york-uni-covid.csv | tail -n1 | cut -d ',' -f 2-)

if [ "$data" != "$olddata" ]; then
    # we have a new record
    date=$(date +%Y-%m-%d)
    echo "$date,$data" >> york-uni-covid.csv
    git checkout -b "auto-$date"
    git add york-uni-covid.csv
    git commit -m "Add data for $date"
    git push origin "auto-$date"
    gh pr create --title "Add UoY date for $date"
fi
