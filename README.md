
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-network-checks.svg)](http://badge.fury.io/rb/sensu-plugins-network-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks)

## Functionality

## Files
 * bin/check-banner
 * bin/check-multicast-groups
 * bin/check-netstat-tcp
 * bin/check-ping
 * bin/check-ports
 * bin/check-rbl
 * bin/metrics-interface
 * bin/metrics-net
 * bin/metrics-netif
 * bin/metrics-netstat-tcp

## Usage

**check-multicast-groups**
```
{
  "check-multicast-groups": [
    ["eth0", "224.2.2.4"]
  ]
}
```
## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-network-checks -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-network`

#### Bundler

Add *sensu-plugins-network* to your Gemfile and run `bundle install` or `bundle update`

`gem install sensu-plugins-network-checks`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-network-checks' do
  options('--prerelease')
  version '0.0.1.alpha.2'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-network-checks' do
  options('--prerelease')
  version '0.0.1.alpha.2'
end
```

## Notes
