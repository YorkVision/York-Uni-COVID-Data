#!/bin/bash
set -euo pipefail

REVIEWER="markspolakovs"

date=$(date +%Y-%m-%d)
branch="auto-$date"

echo "Starting."
# Check out today's branch if one exists, otherwise master

set +e
git checkout "$branch"
if [ $? -ne 0 ]; then
    git checkout master
fi
set -e
if [ -z "$GITHUB_ACTIONS" ]; then
    git pull
fi

olddata=$(tail -n1 york-uni-covid.csv | cut -d ',' -f 2-)

data=$(
    curl -s https://coronavirus.york.ac.uk \
    | pup ':parent-of(:parent-of(div:contains("Current confirmed cases"))) strong text{}' \
    | head -n2 \
    | tr -s ' ' \
    | sed 's/^ *//g' \
    | sed 's/ *$//g' \
    | paste -sd,
)

if [ "$data" != "$olddata" ]; then
    # we have a new record
    echo "Found new data: $data"
    echo "$date,$data" >> york-uni-covid.csv

    # Test if the branch exists
    set +e
    git checkout "$branch"
    if [ $? -ne 0 ]; then
        git checkout -b "$branch"
    fi
    set -e

    git add york-uni-covid.csv
    git commit -m "Add data for $date"
    git push -u origin "$branch"
    gh pr create --head "$branch" --title "Add UoY data for $date" --reviewer $REVIEWER --body "This PR is automatically generated."
fi

if [ -z "$GITHUB_ACTIONS" ]; then
    git checkout master
fi
