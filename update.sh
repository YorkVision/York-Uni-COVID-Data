#!/bin/bash
set -euo pipefail

REVIEWER="markspolakovs"

git checkout master
git pull

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

    branch="auto-$date"
    # Test if the branch exists
    set +e
    git rev-parse --verify "$branch" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        set -e
        echo "Warning: $branch already exists"
        git checkout "$branch"
    else
        set -e
        git checkout -b "$branch"
    fi

    git add york-uni-covid.csv
    git commit -m "Add data for $date"
    git push origin "$branch"
    gh pr create --head "$branch" --title "Add UoY date for $date" --reviewer $REVIEWER --body "This PR is automatically generated."
fi
