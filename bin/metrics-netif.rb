#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   netif-metrics
#
# DESCRIPTION:
#   Network interface throughput
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

#
# Netif Metrics
#
class NetIFMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: Socket.gethostname.to_s

  option :interval,
         description: 'Interval to collect metrics over',
         long: '--interval INTERVAL',
         default: 1

  option :average_key,
         description: 'This key is used to `grep` for a key that corresponds to average. useful for different locales',
         long: '--average-key AVERAGE_KEY',
         default: 'Average'

  def run
    sar = `sar -n DEV #{config[:interval]} 1 | grep #{config[:average_key]} | grep -v IFACE`
    if sar.nil? || sar.empty?
      unknown 'sar is not installed or in $PATH'
    end
    sar.each_line do |line|
      stats = line.split(/\s+/)
      unless stats.empty?
        stats.shift
        nic = stats.shift
        output "#{config[:scheme]}.#{nic}.rx_kB_per_sec", stats[2].to_f if stats[3]
        output "#{config[:scheme]}.#{nic}.tx_kB_per_sec", stats[3].to_f if stats[3]
      end
    end

    ok
  end
end
