#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## Unreleased
### Added
- Added new metrics-ping.rb plugin
* Added check-whois-domain-expiration-multi.rb plugin to check multiple domains for expiratino using whois records

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
