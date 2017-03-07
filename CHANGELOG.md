# Change log

This document represents a high-level overview of changes made to this project.
It will not list every miniscule change, but will allow you to view - at a
glance - what to expact from upgrading to a new version.

## [unpublished]

### Added

### Changed

### Fixed

### Security

### Deprecated

### Removed


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
