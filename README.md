[![Sensu Bonsai Asset](https://img.shields.io/badge/Bonsai-Download%20Me-brightgreen.svg?colorB=89C967&logo=sensu)](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-network-checks)
[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-network-checks)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-network-checks.svg)](http://badge.fury.io/rb/sensu-plugins-network-checks)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-network-checks)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-network-checks)

## Sensu Plugins Network Checks Plugin

- [Overview](#overview)
- [Files](#files)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
  - [Sensu Go](#sensu-go)
    - [Asset registration](#asset-registration)
    - [Asset definition](#asset-definition)
    - [Check definition](#check-definition)
  - [Sensu Core](#sensu-core)
    - [Check definition](#check-definition)
- [Installation from source](#installation-from-source)
- [Additional notes](#additional-notes)
- [Contributing](#contributing)

### Overview

This plugin provides native network instrumentation for monitoring and metrics collection, including hardware, TCP response, RBLs, whois, port status, and more.

### Files
 * bin/check-banner.rb
 * bin/check-jsonwhois-domain-expiration.rb
 * bin/check-mtu.rb
 * bin/check-multicast-groups.rb
 * bin/check-netfilter-conntrack.rb
 * bin/check-netstat-tcp.rb
 * bin/check-ping.rb
 * bin/check-ports-bind.rb
 * bin/check-ports-nmap.rb
 * bin/check-ports.rb
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
 
**check-banner**
Connects to a TCP port on one or more hosts, reads until a char (EOF, EOL, etc), and tests output against a pattern.

**check-jsonwhois-domain-expiration**
Checks domain expiration dates using the https://jsonwhois.com API.

**check-mtu**
Checks maximum transmission unit (MTU) of a network interface. In many setups, MTUs are tuned and MTU mismatches cause issues. Having a check for MTU settings helps catch these mistakes. Also, some instances in Amazon EC2 have a default MTU size of 9,000 bytes, which is undesirable in some environments. This check can catch undesirable setups.

**check-multicast-groups**
Checks whether specific multicast groups are configured on specific interfaces. Requires the `netstat` command.

**check-netfilter-conntrack**
Checks Netfilter connection tracking table condition. 

**check-netstat-tcp**
Alert based on thresholds of discrete TCP socket states reported by netstat.

**check-ping**
Ping check script for Sensu.

**check-ports-bind**
Connects to a TCP/UDP `address:port` to check whether open or closed.

**check-ports-nmap**
Fetches port status using nmap. Catches bad network access control lists (ACLs) and service down events for network resources.

**check-ports**
Connects to a TCP/UDP port on one or more ports check whether ropen or closed. This check now uses a TCPSocket, not nmap (**check-ports-nmap** above uses nmap).

**check-rbl**
Checks whether an IP is blacklisted in the common DNS blacklists or a list you add.

**check-socat**
Inspects sockets, such as checking whether socat can receive particular a UDP multicast packet within a certain number of seconds or whether a UPD multicast packet contains an expected packet.

**check-whois-domain-expiration-multi**
Checks expiration dates for multiple domains using the `whois` gem.

**check-whois-domain-expiration**
Checks a domain's expiration dates using the `whois` gem.

**metrics-interface**
Provides interface metrics.

**metrics-net**
Fetches metrics from all interfaces on the box using the /sys/class interface.

**metrics-netif**
Fetches network interface throughput metrics.

**metrics-netstat-tcp**
Fetches metrics on TCP socket states from netstat. Particularly useful on high-traffic web or proxy servers with large numbers of short-lived TCP connections coming and going.

**metrics-ping**
Pings a host and outputs ping statistics.

**metrics-sockstat**
Parses /proc/net/sockstat and outputs all fields as metrics.

## Usage examples

### Help

**check-banner.rb**
```
Usage: check-banner.rb (options)
    -c, --count NUMBER               Number of successful matches, default(1)
    -C, --critmessage MESSAGE        Custom critical message to send
    -e, --exclude_newline            Exclude newline character at end of write STRING
    -H, --hostnames HOSTNAME(S)      Host(s) to connect to, comma seperated
    -O, --okmessage MESSAGE          Custom ok message to send
    -q, --pattern PAT                Pattern to search for
    -p, --port PORT
    -r, --readtill CHAR              Read till CHAR is reached
    -S, --ssl                        Enable SSL socket for secure connection
    -t, --timeout SECS               Connection timeout
    -w, --write STRING               write STRING to the socket
```

**metrics-interface.rb**
```
Usage: metrics-interface.rb (options)
    -x INTERFACE[,INTERFACE],        List of interfaces to exclude
        --exclude-interface
    -i INTERFACE[,INTERFACE],        List of interfaces to include
        --include-interface
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric
```

## Configuration
### Sensu Go
#### Asset registration

Assets are the best way to make use of this plugin. If you're not using an asset, please consider doing so! If you're using sensuctl 5.13 or later, you can use the following command to add the asset: 

`sensuctl asset add sensu-plugins/sensu-plugins-network-checks`

If you're using an earlier version of sensuctl, you can download the asset definition from [this project's Bonsai asset index page](https://bonsai.sensu.io/assets/sensu-plugins/sensu-plugins-network-checks).

#### Asset definition

```yaml
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-network-checks
spec:
  url: https://assets.bonsai.sensu.io/c90a2b1335ee9cda57046bd4551b303098a98237/sensu-plugins-network-checks_4.1.0_centos_linux_amd64.tar.gz
  sha512: 0fe990e4eb53c308c6245d8ac8cc7268d34e3235d5188ecda3a7308889a09b8b722a77f57169d6d9a7c2f1bf3b523fcdcb618aeb4cd6b83bd74feb3683d721b7
```

#### Check definition

```yaml
---
type: CheckConfig
spec:
  command: "check-banner.rb"
  handlers: []
  high_flap_threshold: 0
  interval: 10
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins/sensu-plugins-network-checks
  - sensu/sensu-ruby-runtime
  subscriptions:
  - linux
```

### Sensu Core

#### Check definition
```json
{
  "checks": {
    "check-banner": {
      "command": "check-banner.rb",
      "subscribers": ["linux"],
      "interval": 10,
      "refresh": 10,
      "handlers": ["influxdb"]
    }
  }
}
```

## Installation from source

### Sensu Go

See the instructions above for [asset registration](#asset-registration).

### Sensu Core

Install and setup plugins on [Sensu Core](https://docs.sensu.io/sensu-core/latest/installation/installing-plugins/).

## Additional notes

### Sensu Go Ruby Runtime Assets

The Sensu assets packaged from this repository are built against the Sensu Ruby runtime environment. When using these assets as part of a Sensu Go resource (check, mutator, or handler), make sure to include the corresponding [Sensu Ruby Runtime Asset](https://bonsai.sensu.io/assets/sensu/sensu-ruby-runtime) in the list of assets needed by the resource.

## Contributing

See [CONTRIBUTING.md](https://github.com/sensu-plugins/sensu-plugins-network-checks/blob/master/CONTRIBUTING.md) for information about contributing to this plugin.
