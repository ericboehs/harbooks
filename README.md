## Usage

This script gathers time entries notes from your Harvest account. It will
return 7 days worth of notes from the date specified.

Usage: `harbooks <client> <day of week start>`

Example: `harbooks 'Acme Inc' 'April 12th'`

You will need the following ENV vars set:

```sh
export HARVEST_SUBDOMAIN=acmeinc
export HARVEST_USERNAME=rrunner
export HARVEST_PASSWORD=beepbeep
```

This script can be used by itself or inconjunction with bundler and/or dotenv:
  - If a `Gemfile` is detected, bundler will be used
  - If a `.env` file is detected, dotenv will make the config vars accesible
