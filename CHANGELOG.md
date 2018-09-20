# Change log

This document represents a high-level overview of changes made to this project.
It will not list every miniscule change, but will allow you to view - at a
glance - what to expact from upgrading to a new version.

## [unpublished]

### Added

- Ignore users' commands if on ignore list.

### Changed

### Fixed

### Security

### Deprecated

### Removed


## [0.23.1] - 2018-09-11

### Fixed

- `!stats` combining output of `!excuse` and `!calendarfact`.


## [0.23.0] - 2018-09-11

### Added

- `!calendarfact` command which provides one with a well-known piece of
  calendar trivia.


## [0.22.1] - 2018-09-09

### Changed

- Update dependencies and base image.

### Fixed

- `!hive` not supporting Steam ID64s outside of usual range.


## [0.22.0] - 2018-09-02

### Added

- `!tags` command which allows to list known hint tags, sorted alphabetically
  or by number of tagged hints.
- `!reloadhints` command which allows reloading hints from the source.

### Fixed

- Log usages of `!tipslist` command.


## [0.21.1] - 2018-08-31

### Fixed

- Placeholder replacement did not prefer longest matches, leading to partial
  replacements of placeholders if one placeholder was a substring of another.


## [0.21.0] - 2018-08-23

### Added

- `!tiplist` command which lists various sources of hints and tips.
- `!tip` command to retrieve hints and tips about NS2.
- Command to automatically import NS2 tips from Google doc.


## [0.20.0] - 2018-07-16

### Added

- Persistence layer using a Postgres database.
- Tracking of command usage per-user.
- `!stats` command to show top x users per command.


## [0.19.2] - 2018-06-26

### Fixed

- Gorge-based accuracy data was shown as fraction rather than percentage.


## [0.19.1] - 2018-06-25

### Fixed

- Exception if Gorge data incomplete, eg no accuracy available.


## [0.19.0] - 2018-05-19

### Changed

- Show no-onos marine accuracy.
- Update to ruby 2.5.1, update dependencies, update Tini.


## [0.18.0] - 2018-04-04

### Added

- Gorge integration, allowing to pull additional per-player statistics from
  Gorge.


## [0.17.0] - 2018-03-20

### Added

- Allow creating invites for servers the bot is in.

### Fixed

- Prevent timeout when listing servers due to counting members in server.


## [0.16.0] - 2018-03-15

### Added

- `!servers` command to list servers the bot is in, available to admin users.
- Server count exposed as Prometheus metric.


## [0.15.2] - 2018-03-09

### Changed

- Disable buffering of stdout.


## [0.15.1] - 2017-12-20

### Fixed

- Adjust to breaking changes in `steam-id2` library.


## [0.15.0] - 2017-12-19

### Added

- Bot will respond with an excuse if an internal exception is encountered while
  processing commands.

### Changed

- Update dependencies and base image.


## [0.14.0] - 2017-12-07

### Changed

- Improve plaintext and embed output formats of Hive queries.
  - Use markdown to improve readability of plaintext format.
  - Add Observatory link to plaintext format.
  - Decrease size of embed format.


## [0.13.0] - 2017-12-03

### Added

- Optional support for Discord-style "embeds" in Hive module.


## [0.12.0] - 2017-11-07

### Added

- Metrics tracking executed commands, as well as Hive API call timings.

### Changed

- Move list of excuses to separate file.


## [0.11.1] - 2017-11-01

### Fixed

- Prevent `!excuse` calls which exceeded the per-message limit from using up
  the rate limit.


## [0.11.0] - 2017-11-01

### Added

- Re-added per-message limit for `!excuse` command.
  Allows keeping message size in check, as well as prevent circumventing the
  rate limit upon the user first issuing the command.


## [0.10.0] - 2017-11-01

### Added

- Rate-limiting for `!excuse` command. Limits the number of excuses per time
  interval a user may request.

### Changed

- Change changelog link to Github.

### Removed

- Configuration setting to limit maximum number of excuses per message in
  favour of proper rate limiting.


## [0.9.0] - 2017-10-03

### Added

- Allow configuring log level.

### Changed

- Extract various commands into thematically distinct modules.


## [0.8.1] - 2017-09-17

### Fixed

- Flush STDOUT after logging, to facilitate reliable logging in containers.


## [0.8.0] - 2017-09-17

### Added

- Add basic logging of command usage.

### Changed

- Update ruby and dependencies.


## [0.7.0] - 2017-05-30

### Changed

- Update to Ruby 2.4.1.
- Update dependencies.


## [0.6.0] - 2017-03-07

### Changed

- Update to Ruby 2.4.0.
- Update dependencies.


## [0.5.0] - 2017-01-29

### Added

- Return SteamID help message if resolving of Steam ID was successful, but API
  returned no data, hinting at incorrect supplied ID.


## [0.4.1] - 2017-01-16

### Fixed

- Fixes `!excuse` command.


## [0.4.0] - 2017-01-16

### Added

- `!excuse` command. Picks a random BOFH-style excuse.


## [0.3.0] - 2017-01-16

### Added

- `!version` command.
- Link to SteamID.io if provided Steam ID could not be resolved.

### Changed

- Updates dependencies to fix handling of account IDs starting with 765.


## [0.2.1] - 2017-01-06

### Added

- User alias to `!hive` output.

### Fixed

- Updates Silvverball to 0.1.3, fixing fraction of seconds showing up in
  hours-only playtime.


## [0.2.0] - 2017-01-03

### Added

- Per-user and global rate limits.
- `!hive` as alias to `!hive2`
- Description of bot commands to help output.

### Changed

- Improved formatting of Hive 2 player data.
- `!hive` command defaults to Discord username if not specified otherwise.


## [0.1.0] - 2017-01-02

### Added

- Discord bot to query Hive 2 player data.
