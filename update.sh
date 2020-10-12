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

    branch="auto-$date"
    # Test if the branch exists
    git rev-parse --verify "$branch" > /dev/null 2>&1
    if $?; then
        echo "Warning: $branch already exists"
        git checkout "$branch"
    else
        git checkoug -b "$branch"
    fi
    
    git checkout -b "$branch"
    git add york-uni-covid.csv
    git commit -m "Add data for $date"
    git push origin "$branch"
    gh pr create --head --title "Add UoY date for $date" --reviewers markspolakovs --body "This PR is automatically generated."
fi
