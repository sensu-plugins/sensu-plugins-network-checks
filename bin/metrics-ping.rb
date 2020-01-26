#! /usr/bin/env ruby
# frozen_string_literal: true

#
# metrics-ping
#
# DESCRIPTION:
#  This plugin pings a host and outputs ping statistics
#
# OUTPUT:
#  <scheme>.packets_transmitted 5 1437137076
#  <scheme>.packets_received 5 1437137076
#  <scheme>.packet_loss 0 1437137076
#  <scheme>.time 3996 1437137076
#  <scheme>.min 0.016 1437137076
#  <scheme>.max 0.017 1437137076
#  <scheme>.avg 0.019 1437137076
#  <scheme>.mdev 0.004 1437137076
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: open3
#
# WARNING:
#  This plugins requires `ping` binary from `iputils-ping` package.
#  `ping` binary from `inetutils-ping` package produces incompatible
#  output. For more info see:
#  https://github.com/sensu-plugins/sensu-plugins-network-checks/issues/26
#
# USAGE:
#   ./metric-ping --host <host> --count <count> \
#                 --timeout <timeout> --scheme <scheme>
#
# NOTES:
#
# LICENSE:
#   Copyright 2015 Rob Wilson <roobert@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'
require 'open3'

class PingMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.ping"

  option :host,
         description: 'Host to ping',
         short: '-h HOST',
         long: '--host HOST',
         default: 'localhost'

  option :count,
         description: 'Ping count',
         short: '-c COUNT',
         long: '--count COUNT',
         default: 5

  option :timeout,
         description: 'Timeout',
         short: '-t TIMEOUT',
         long: '--timeout TIMEOUT',
         default: 5

  OVERVIEW_METRICS = %i[packets_transmitted packets_received packet_loss time].freeze
  STATISTIC_METRICS = %i[min avg max mdev].freeze
  FLOAT = '(\d+\.\d+)'

  def overview
    @ping.split("\n")[-2].scan(/^(\d+) packets transmitted, (\d+) received, (\d+)% packet loss, time (\d+)ms/)[0]
  end

  def statistics
    @ping.split("\n")[-1].scan(/^rtt min\/avg\/max\/mdev = #{FLOAT}\/#{FLOAT}\/#{FLOAT}\/#{FLOAT} ms/)[0]
  end

  def results
    Hash[OVERVIEW_METRICS.zip(overview)].merge Hash[STATISTIC_METRICS.zip(statistics)]
  end

  def timestamp
    @timestamp ||= Time.now.to_i
  end

  def write_output
    results.each { |metric, value| output "#{config[:scheme]}.#{metric} #{value} #{timestamp}" }
  end

  def ping
    @ping, @status = Open3.capture2e("ping -W#{config[:timeout]} -c#{config[:count]} #{config[:host]}")
  end

  def validate
    critical "ping error: unable to ping #{config[:host]}" unless @status.success?
  end

  def run
    ping
    validate
    write_output
    ok
  end
end
