# Lerk

A Discord bot, whose main purpose is to allow quering Hive - Natural Selection
2's ELO system.

Live versions of this bot can be found in the NS2 official Discord server, as
well as servers of independent NS2 communities.

## Running

The public [Docker container](https://hub.docker.com/r/lavode/lerk/) is the preferred way of running this application.

### Configuration

Configuration is done exclusively via environment variables. Wherever possible,
sane defaults have been used.

In the table below, `Required` indicates values you have to define, ie settings
which have no default, but are required for operation.

#### General

| Setting               | Required | Default | Description                                |
| --------------------- | -------- | ------- | ------------------------------------------ |
| `DISCORD_CLIENT_ID`   | y        |         | OAuth Client ID.                           |
| `DISCORD_TOKEN`       | y        |         | OAuth Token.                               |
| `LOG_LEVEL`           | n        | normal  | Logging verbosity. Valid values are 'debug', 'verbose', 'normal', 'quiet', 'silent' |

#### Database

| Setting       | Required | Default   | Description                                                          |
| ------------- | -------- | --------- | -------------------------------------------------------------------- |
| `DB_HOST`     | n        |           | Address of database server. Default is adapter-specific.             |
| `DB_PORT`     | n        |           | Port of database server. Default is adapter-specific.                |
| `DB_DATABASE` | y        |           | Name of database which to use.                                       |
| `DB_USER`     |          |           | User which to authenticate as. Default is adapter-specific.          |
| `DB_PASS`     |          |           | Password with which to authenticate as. Default is adapter-specific. |

#### Lerk

| Setting                  | Required | Default | Description                                |
| ------------------------ | -------- | ------- | ------------------------------------------ |
| `LERK_COMMAND_PREFIX`    | n        | !       | Prefix which is used to identify commands. |
| `LERK_ADMIN_USERS`       | n        |         | Comma-separated list of Discord user IDs which to grant admin access to the bot to. |
| `LERK_HINTS_ADMIN_USERS` | n        |         | Comma-separated list of Discord user IDs which to grant admin access to the ingame hints part of the bot to. |

#### Prometheus

| Setting                | Required | Default | Description                                                 |
| ---------------------- | -------- | ------- | ----------------------------------------------------------- |
| `PROMETHEUS_LISTEN_IP` | n        | 0.0.0.0 | IP which Prometheus exporter will bind to. Might need changing if running outside a Docker container. |
| `PROMETHEUS_PORT`      | n        | 5000    | Port which Prometheus exporter will bind to.                |
| `PROMETHEUS_ENABLED`   | n        | true    | `true` to enable exporter, any other value else to disable. |

#### Hive Interface

| Setting                              | Required | Default | Description                                                 |
| ------------------------------------ | -------- | ------- | ----------------------------------------------------------- |
| `STEAM_WEB_API_KEY`                  | n        |         | API key to use for authentication against Steam web API. Required for resolving of Steam custom URLs. |
| `HIVE_GLOBAL_RATE_LIMIT`             | n        | 2       | Global number of queries to allow in interval.   |
| `HIVE_GLOBAL_RATE_LIMIT_TIME_SPAN`   | n        | 1       | Global rate limiting interval in seconds.        |
| `HIVE_PER_USER_RATE_LIMIT`           | n        | 1       | Per user number of queries to allow in interval. |
| `HIVE_PER_USER_RATE_LIMIT_TIME_SPAN` | n        | 1       | Per user rate limiting interval in seconds.      |
| `HIVE_HELP_MESSAGE_RATE_LIMIT`       | n        | 1       | Per user number of help messages to send in interval. |
| `HELP_MESSAGE_RATE_LIMIT_TIME_SPAN`  | n        | 300     | Per user rate limiting interval in seconds.      |
| `HIVE_ENABLE_EMBEDS`                 | n        | true    | Set to `false` to use plain-text rather than embed-style output. |

#### Observatory

| Setting                | Required | Default                         | Description                       |
| -----------------------| -------- | ------------------------------- | --------------------------------- |
| `OBSERVATORY_BASE_URL` | n        | https://observatory.morrolan.ch | Base URL of observatory instance. |

#### Gorge

| Variable                     | Default value | Required | Description                                               |
| ---------------------------- | ------------- | -------- | --------------------------------------------------------- |
| `GORGE_BASE_URL`             |               | n        | Base URL of Gorge. Empty to disable Gorge integration.    |
| `GORGE_HTTP_BASIC_USER`      |               | n        | User for HTTP basic authentication. Empty to disable.     |
| `GORGE_HTTP_BASIC_PASSWORD ` |               | n        | Password for HTTP basic authentication. Empty to disable. |
| `GORGE_CONNECT_TIMEOUT`      | 1             | y        | HTTP connect timeout towards Gorge API.                   |
| `GORGE_TIMEOUT`              | 2             | y        | HTTP timeout towards Gorge API.                           |
| `STATISTICS_CLASS`           | n_30          | y        | Statistics class of Gorge which to query                  |

#### Excuse

| Setting                          | Required | Default | Description                                                |
| -------------------------------- | -------- | ------- | ---------------------------------------------------------- |
| `EXCUSE_MAXIMUM_AMOUNT`          | n        | 10      | Maximum number of excuses to request per command execution |
| `EXCUSE_PER_USER_RATE_LIMIT`     | n        | 20      | Number of excuses per time limit which user can request.   |
| `EXCUSE_PER_USER_RATE_TIME_SPAN` | n        | 20      | Per user rate limiting interval in seconds.                |

#### Calendar Facts

| Setting                                  | Required | Default | Description                                                       |
| ---------------------------------------- | -------- | ------- | ----------------------------------------------------------------- |
| `CALENDAR_FACTS_PER_USER_RATE_LIMIT`     | n        | 20      | Number of calendar facts per time limit which user can request.   |
| `CALENDAR_FACTS_PER_USER_RATE_TIME_SPAN` | n        | 20      | Per user rate limiting interval in seconds.                       |

#### Statistics

| Setting                          | Required | Default | Description                                            |
| -------------------------------- | -------- | ------- | ------------------------------------------------------ |
| `STATISTICS_SHOW_TOPMOST_N`      | n        | 5       | Number of users to show per command in `!stats` output |

#### Hints

| Setting                       | Required | Default | Description                                            |
| ----------------------------- | -------- | ------- | ------------------------------------------------------ |
| `HINTS_SNARKY_COMMENT_CHANCE` | n        | 100     | Reciprocal of chance of a snarky comment, rather than a helpful hint, being returned. Set to `0` to disable snarky comments. |

#### Emerald

| Setting                        | Required | Default | Description                                               |
| ------------------------------ | -------- | ------- | --------------------------------------------------------- |
| `EMERALD_BASE_URL`             | n        |         | Base URL of Emerald. Set to empty to disable integration. |
| `EMERALD_MAXIMUM_INPUT_LENGTH` | n        | 500     | Maximum size of input which to accept.                    |

#### Puma

| Variable            | Default value | Required | Description                                                                                                                                   |
| ------------------- | ------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `PUMA_LISTEN_IP`    | 0.0.0.0       | y        | IP which the application server will bind to. If you run this application outside of a Docker container, you will likely want to change this! |
| `PUMA_LISTEN_PORT`  | 8080          | y        | Port which the application server will bind to.                                                                                               |
| `PUMA_THREADS_MIN`  | 0             | y        | Initial number of threads to spawn per worker.                                                                                                |
| `PUMA_THREADS_MAX`  | 16            | y        | Maximum number of threads to spawn per worker.                                                                                                |
| `PUMA_WORKERS`      | 2             | y        | Number of worker processes to spawn.                                                                                                          |

#### Discord OAuth

| Setting                       | Required | Default                               | Description                                               |
| ----------------------------- | -------- | ------------------------------------- | --------------------------------------------------------- |
| `DISCORD_OAUTH_BASE_URL`      | n        | https://discordapp.com                | Base URL of Discord API                                   |
| `DISCORD_OAUTH_CLIENT_ID`     | n        |                                       | OAuth client ID                                           |
| `DISCORD_OAUTH_CLIENT_SECRET` | n        |                                       | OAuth client secret                                       |
| `DISCORD_OAUTH_CALLBACK_URL`  | n        | https://hivestalker.morrolan.ch/oauth | OAuth callback URL                                        |
