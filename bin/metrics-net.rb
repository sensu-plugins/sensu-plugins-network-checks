#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   metrics-net
#
# DESCRIPTION:
#   Simple plugin that fetchs metrics from all interfaces
#   on the box using the /sys/class interface.
#
#   Use the data with graphite's `nonNegativeDerivative()` function
#   to construct per-second graphs for your hosts.
#
#   Loopback iface (`lo`) is ignored.
#
#   Compat
#   ------
#
#   This plugin uses the `/sys/class/net/<iface>/statistics/{rx,tx}_*`
#   files to fetch stats. On older linux boxes without /sys, this same
#   info can be fetched from /proc/net/dev but additional parsing
#   will be required.
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
#   $ ./metrics-packets.rb --scheme servers.web01
#   servers.web01.eth0.tx_packets 982965    1351112745
#   servers.web01.eth0.rx_packets 1180186   1351112745
#   servers.web01.eth1.tx_packets 273936669 1351112745
#   servers.web01.eth1.rx_packets 563787422 1351112745
#
# NOTES:
#   Does it behave differently on specific platforms, specific use cases, etc.
#   Devices can be specifically included or ignored using -i or -I options:
#     e.g. metrics-net.rb -i veth,dummy
#
# LICENSE:
#   Copyright 2012 Joe Miller <https://github.com/joemiller>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

#
# Linux Packet Metrics
#
class LinuxPacketMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.net"

  option :ignore_device,
         description: 'Ignore devices matching pattern(s)',
         short: '-i DEV[,DEV]',
         long: '--ignore-device',
         proc: proc { |a| a.split(',') }

  option :include_device,
         description: 'Include only devices matching pattern(s)',
         short: '-I DEV[,DEV]',
         long: '--include-device',
         proc: proc { |a| a.split(',') }

  option :only_up,
         description: 'Include only devices whose interface status is up',
         short: '-u',
         long: '--only-up'

  def run
    timestamp = Time.now.to_i

    Dir.glob('/sys/class/net/*').each do |iface_path|
      next if File.file?(iface_path)

      iface = File.basename(iface_path)
      next if iface == 'lo'

      next if config[:ignore_device] && config[:ignore_device].find { |x| iface.match(x) }
      next if config[:include_device] && !config[:include_device].find { |x| iface.match(x) }
      next if config[:only_up] && File.open(iface_path + '/operstate').read.strip != 'up'

      tx_pkts = File.open(iface_path + '/statistics/tx_packets').read.strip
      rx_pkts = File.open(iface_path + '/statistics/rx_packets').read.strip
      tx_bytes = File.open(iface_path + '/statistics/tx_bytes').read.strip
      rx_bytes = File.open(iface_path + '/statistics/rx_bytes').read.strip
      tx_errors = File.open(iface_path + '/statistics/tx_errors').read.strip
      rx_errors = File.open(iface_path + '/statistics/rx_errors').read.strip

      begin
        if_speed = File.open(iface_path + '/speed').read.strip
      rescue StandardError
        if_speed = 0
      end

      output "#{config[:scheme]}.#{iface}.tx_packets", tx_pkts, timestamp
      output "#{config[:scheme]}.#{iface}.rx_packets", rx_pkts, timestamp
      output "#{config[:scheme]}.#{iface}.tx_bytes", tx_bytes, timestamp
      output "#{config[:scheme]}.#{iface}.rx_bytes", rx_bytes, timestamp
      output "#{config[:scheme]}.#{iface}.tx_errors", tx_errors, timestamp
      output "#{config[:scheme]}.#{iface}.rx_errors", rx_errors, timestamp
      output "#{config[:scheme]}.#{iface}.if_speed", if_speed, timestamp
    end
    ok
  end
end
