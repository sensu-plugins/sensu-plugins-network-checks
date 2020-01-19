#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   metrics-netstat-tcp
#
# DESCRIPTION:
#   Fetch metrics on TCP socket states from netstat. This is particularly useful
#    on high-traffic web or proxy servers with large numbers of short-lived TCP
#   connections coming and going.
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
#   $ ./metrics-netstat-tcp.rb --scheme servers.hostname
#   servers.hostname.UNKNOWN      0     1350496466
#   servers.hostname.ESTABLISHED  235   1350496466
#   servers.hostname.SYN_SENT     0     1350496466
#   servers.hostname.SYN_RECV     1     1350496466
#   servers.hostname.FIN_WAIT1    0     1350496466
#   servers.hostname.FIN_WAIT2    53    1350496466
#   servers.hostname.TIME_WAIT    10640 1350496466
#   servers.hostname.CLOSE        0     1350496466
#   servers.hostname.CLOSE_WAIT   7     1350496466
#   servers.hostname.LAST_ACK     1     1350496466
#   servers.hostname.LISTEN       16    1350496466
#   servers.hostname.CLOSING      0     1350496466
#
# NOTES:
#   - Code for parsing Linux /proc/net/tcp from Anthony Goddard's ruby-netstat:
#   https://github.com/agoddard/ruby-netstat
#
# LICENSE:
#   Copyright 2012 Joe Miller <https://github.com/joemiller>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'

TCP_STATES = {
  '00' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
  'FF' => 'UNKNOWN',  # Bad state ... Impossible to achieve ...
  '01' => 'ESTABLISHED',
  '02' => 'SYN_SENT',
  '03' => 'SYN_RECV',
  '04' => 'FIN_WAIT1',
  '05' => 'FIN_WAIT2',
  '06' => 'TIME_WAIT',
  '07' => 'CLOSE',
  '08' => 'CLOSE_WAIT',
  '09' => 'LAST_ACK',
  '0A' => 'LISTEN',
  '0B' => 'CLOSING'
}.freeze

#
# Netstat TCP Metrics
#
class NetstatTCPMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.tcp"

  option :port,
         description: 'Port you wish to get metrics for',
         short: '-p PORT',
         long: '--port PORT',
         proc: proc(&:to_i)

  option :type,
         description: 'Specify the type of the port to get metrics for: Local (default)  or remote',
         short: '-t local|remote',
         long: '--type local|remote',
         default: 'local'

  option :disabletcp6,
         description: 'Disable tcp6 check',
         short: '-d',
         long: '--disabletcp6',
         boolean: true

  def netstat(protocol, pattern, state_counts)
    File.open('/proc/net/' + protocol).each do |line|
      line.strip!
      if m = line.match(pattern) # rubocop:disable AssignmentInCondition
        connection_state = m[5]
        if config[:type] == 'local'
          connection_port = m[2].to_i(16)
        elsif config[:type] == 'remote'
          connection_port = m[4].to_i(16)
        else
          unknown "Unknown type level #{config[:type]}. Available values are: local, remote."
        end
        connection_state = TCP_STATES[connection_state]
        if config[:port] && config[:port] == connection_port
          state_counts[connection_state] += 1
        elsif !config[:port]
          state_counts[connection_state] += 1
        end
      end
    end
    state_counts
  end

  def run
    timestamp = Time.now.to_i
    state_counts = Hash.new(0)
    TCP_STATES.each_pair { |_hex, name| state_counts[name] = 0 }

    tcp4_pattern = /^\s*\d+:\s+(.{8}):(.{4})\s+(.{8}):(.{4})\s+(.{2})/
    state_counts = netstat('tcp', tcp4_pattern, state_counts)

    unless config[:disabletcp6]
      tcp6_pattern = /^\s*\d+:\s+(.{32}):(.{4})\s+(.{32}):(.{4})\s+(.{2})/
      state_counts = netstat('tcp6', tcp6_pattern, state_counts)
    end

    state_counts.each do |state, count|
      graphite_name = config[:port] ? "#{config[:scheme]}.#{config[:port]}.#{config[:type]}.#{state}" :
        "#{config[:scheme]}.#{state}"
      output graphite_name.to_s, count, timestamp
    end
    ok
  end
end
