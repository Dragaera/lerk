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

#### Lerk

| Setting               | Required | Default | Description                                |
| --------------------- | -------- | ------- | ------------------------------------------ |
| `LERK_COMMAND_PREFIX` | n        | !       | Prefix which is used to identify commands. |
| `LERK_ADMIN_USERS`    | n        |         | Comma-separated list of Discord user IDs which to grant admin access to the bot to. |

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

#### Excuse

| Setting                          | Required | Default | Description                                                |
| -------------------------------- | -------- | ------- | ---------------------------------------------------------- |
| `EXCUSE_MAXIMUM_AMOUNT`          | n        | 10      | Maximum number of excuses to request per command execution |
| `EXCUSE_PER_USER_RATE_LIMIT`     | n        | 20      | Number of excuses per time limit which user can request.   |
| `EXCUSE_PER_USER_RATE_TIME_SPAN` | n        | 20      | Per user rate limiting interval in seconds.                |
