#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Fixed
- metrics-ping.rb: Fix error when a host can't be pinged. Convert to a proper metrics check.

### Added
- Option for newline character in write string for check-banner

## [0.1.4] - 2016-01-22
### Added
- IPv6 support for check-ping

## [0.1.3] - 2016-01-15
### Added
- Added check-socat.rb

## [0.1.2] - 2016-01-08
### Fixed
- Bugfix for `check-whois-domain-expiration-multi` and `check-jsonwhois-domain-expiration`: return a warning-level response if there were any domains with expiration dates in the warning time period but none in the critical time period.

## [0.1.1] - 2015-12-21
### Added
- activesupport runtime dependency locked to 4.2.5 to ensure that we do not need ruby > 2.2

## [0.1.0] - 2015-12-03
### Added
- Added include and ignore options for devices at `metrics-net.rb`

### Changed
- Updated whois gem to 3.6.3

## [0.0.8] - 2015-11-12
### Added
- Support multiple port ranges for check-ports

### Changed
- Updated net-ping gem to 1.7.8
- Updated whois gem to 3.6.2

## [0.0.7] - 2015-10-27
### Added
- Added `check-jsonwhois-domain-expiration.rb` plugin which uses the API at https://jsonwhois.com to check domain expiry.

## [0.0.6] - 2015-10-01
### Added
- Added new port check

### Changed
- Changed name of check-ports to check-ports-nmap

## [0.0.5] - 2015-08-05
### Added
- Added new metrics-ping.rb plugin
- Added check-whois-domain-expiration-multi.rb plugin to check multiple domains for expiration using whois records

### Changed
- general gem cleanup

## [0.0.4] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.3] - 2015-06-03
### Fixed
- check-rbl.rb had a typo in the require statement for 'dnsbl-client'

### Changed
- cleaned up the gemspec
- cleaned up Rakefile
- updated documentation links

### Refactored
- renamed check-ports.rb to check-ports-nmap.rb
- added check-ports.rb based in TCPSocket instead of nmap

### Refactored
- renamed check-ports.rb to check-ports-nmap.rb
- added check-ports.rb based in TCPSocket instead of nmap

## [0.0.2] - 2015-06-03

### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-05-01

### Added
- initial release

#### 0.0.1.alpha.7

* add gem metadata
* add chef provisioner to Vagrantfile
* fix ruobcop issues
* pin all dependencies

#### 0.0.1.alpha.6

* added check-whois-domain-expiration #7

#### 0.0.1.alpha.5

* updated check-banner to allow checking for no banner

#### 0.0.1.alpha.4

* added check-mtu functionality #7

#### 0.0.1.alpha.3

* additional functionality to check-banner #6

#### 0.0.1.alpha.2

* all tests pass
* initial gem release

#### 0.0.1.alpha.1

* initial release, same as community repo

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.1.4...HEAD
[0.1.4]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.1.3...0.1.4
[0.1.3]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.1.2...0.1.3
[0.1.2]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.1.1...0.1.2
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.1.0...0.Ï.1
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.8...0.1.0
[0.0.7]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.7...0.0.8
[0.0.7]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.6...0.0.7
[0.0.6]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.5...0.0.6
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-network-checks/compare/0.0.1...0.0.2
