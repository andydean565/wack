# wack

a CLI tool to help connect your git repo to your ticket management system

> the project has been built with some flexibility in mind to extend to different platforms but the default is `JIRA` and `Gitlab`

## Aims

- branch name consistency
- ticket difference between branches
- current branch info

## development plans

- actions within the ticket management system to automate some processes
- data analytics integration (create tickets & branches from issues)
- pipeline release notes
- slack communication of releases

# Getting Started 🚀

## Install

```sh
dart pub global activate --source=path <path to this package>
```

## Config

the doctor command will prompt you for the config and save it as a .env file in the current project directory

```sh
$ wack doctor
```

a few values will be required from jira & Gitlab to complete the setup process

- jira api token
- gitlab api token (not currently used)

# Usage

```sh
# set config for gitlab & jira
$ wack doctor

# current branch ticket info
$ wack current

# get avalible tickets
$ wack tickets -s [status]

# get jira ticket info
$ wack ticket [ticket_id]

# checkout new branch using ticket id
$ wack checkout [ticket_id]

# get commit ticket difference between branches
$ wack difference -t [target] -s [source]

# get repo releases (tags)
# (still in development)
$ wack releases

# Show usage help
$ wack --help
```

[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli
