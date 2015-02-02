## Sensu-Plugins-network

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-network.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-network)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-network.svg)](http://badge.fury.io/rb/sensu-plugins-network)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network)

## Functionality

**check-banner.rb**

**check-multicast-groups.rb**

**check-netstat-tcp.rb**

**check-rbl.rb**

**metrics-net.rb**

**metrics-netstat-tcp.rb**

**netif-metrics.rb**

## Files

* /bin/check-banner.rb
* /bin/check-multicast-groups.rb
* /bin/check-netstat-tcp.rb
* /bin/check-rbl.rb
* /bin/metrics-net.rb
* /bin/metrics-netstat-tcp.rb
* /bin/netif-metrics.rb

## Usage

This is a sample input file used by check-smart-status, see the script for further details.
```json
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
gem install <gem> -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

`gem install sensu-plugins-network`

Add *sensu-plugins-network* to your Gemfile, manifest, cookbook, etc

## Notes
