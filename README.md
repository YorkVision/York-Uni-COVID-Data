# York Uni COVID-19 Data

This repository contains the data the COVID-19 graphs on the homepage of the [York Vision website](https://yorkvision.co.uk), as well as the code to semi-automatically update them.

## Methodology

The University doesn't publish historical COVID data anywhere, only a daily summary. So this repo contains a (very bad) Bash script that scrapes the site (using [pup](https://github.com/ericchiang/pup)) and submits a pull request if there's any new data.

## License

The code (all files except `.csv`) is licensed under the [MIT License](https://opensource.org/licenses/MIT). All `.csv` files are licensed under the [Open Database License](https://opendatacommons.org/licenses/odbl/). Any rights in individual contents of the database are licensed under the [Database Contents License](http://opendatacommons.org/licenses/dbcl/1.0/).
