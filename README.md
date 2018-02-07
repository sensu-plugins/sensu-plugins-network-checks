
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-network-checks.svg)](http://badge.fury.io/rb/sensu-plugins-network-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks)

## Functionality

## Files
 * bin/check-banner.rb
 * bin/check-netfilter-conntrack.rb
 * bin/check-jsonwhois-domain-expiration.rb
 * bin/check-mtu.rb
 * bin/check-multicast-groups.rb
 * bin/check-netstat-tcp.rb
 * bin/check-ping.rb
 * bin/check-ports-nmap.rb
 * bin/check-ports.rb
 * bin/check-ports-bind.rb
 * bin/check-rbl.rb
 * bin/check-socat.rb
 * bin/check-whois-domain-expiration-multi.rb
 * bin/check-whois-domain-expiration.rb
 * bin/metrics-interface.rb
 * bin/metrics-net.rb
 * bin/metrics-netif.rb
 * bin/metrics-netstat-tcp.rb
 * bin/metrics-ping.rb
 * bin/metrics-sockstat.rb

## Usage

**check-ports**
This check now uses a TCPSocket, not nmap (see next below)
```
check-ports.rb -h 0.0.0.0,1.2.3.4 -p 22,25,3030 -t 30

Usage: bin/check-ports.rb (options)
    -H, --hostnames HOSTNAME         Hosts to connect to
    -p, --ports PORTS                Ports to check, comma separated
    -t, --timeout SECS               Connection timeout
```

**check-ports-nmap**
```
Usage: bin/check-ports-nmap.rb (options)
    -h, --host HOST                  Resolving name or IP address of target host
    -l, --level crit|warn            Alert level crit(critical) or warn(warning)
    -t, --ports PORT,PORT...         TCP port(s) you wish to get status for
```

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
