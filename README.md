
[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-network-checks.svg)](http://badge.fury.io/rb/sensu-plugins-network-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks)
[![Codeship Status for sensu-plugins/sensu-plugins-network-checks](https://codeship.com/projects/d8090610-d234-0132-faa9-267aebe4cf02/status?branch=master)](https://codeship.com/projects/77474)

## Functionality

## Files
 * bin/check-banner.rb
 * bin/check-multicast-groups.rb
 * bin/check-netstat-tcp.rb
 * bin/check-ping.rb
 * bin/check-ports.rb
 * bin/check-rbl.rb
 * bin/check-whois-domain-expiration.rb
 * bin/metrics-interface.rb
 * bin/metrics-net.rb
 * bin/metrics-netif.rb
 * bin/metrics-netstat-tcp.rb

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

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)


## Notes
