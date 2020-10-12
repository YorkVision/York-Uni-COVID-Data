#!/bin/bash
set -euo pipefail

REVIEWER="markspolakovs"

date=$(date +%Y-%m-%d)
branch="auto-$date"

# Check out today's branch if one exists, otherwise master
if git rev-parse --verify "$branch" > /dev/null 2>&1; then
    git checkout "$branch"
else
    git checkout master
fi
git pull

data=$(\
curl -s https://coronavirus.york.ac.uk \
| pup ':parent-of(:parent-of(div:contains("Current confirmed cases"))) strong text{}' \
| head -n2 \
| paste -sd, \
)
olddata=$(tail -n1 york-uni-covid.csv | cut -d ',' -f 2-)

if [ "$data" != "$olddata" ]; then
    # we have a new record
    echo "$date,$data" >> york-uni-covid.csv

    # Test if the branch exists
    if git rev-parse --verify "$branch" > /dev/null 2>&1; then
        echo "Warning: $branch already exists"
        git checkout "$branch"
    else
        git checkout -b "$branch"
    fi

    git add york-uni-covid.csv
    git commit -m "Add data for $date"
    git push -u origin "$branch"
    gh pr create --head "$branch" --title "Add UoY data for $date" --reviewer $REVIEWER --body "This PR is automatically generated."
fi

git checkout master
