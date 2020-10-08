#!/usr/bin/env ruby
# frozen_string_literal: true

#
# metrics-sockstat
#
# DESCRIPTION:
#   This metric check parses /proc/net/sockstat and outputs all fields as metrics
#
# OUTPUT:
#   graphite metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   Specify [-s|--scheme] SCHEME to change the text appended to the metric paths.
#
# NOTES:
#   It outputs the value in the first line ("sockets used") as SCHEME.total_used.
#   All other fields are output as SCHEME.type.field, i.e., SCHEME.TCP.inuse, SCHEME.UDP.mem
#
# LICENSE:
#   Copyright 2015 Contegix, LLC.
#   Released under the same terms as Sensu (the MIT license); see LICENSE for details.
#
require 'sensu-plugin/metric/cli'

# MetricsSockstat
class MetricsSockstat < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to $protocol.$field',
         long: '--scheme SCHEME',
         short: '-s SCHEME',
         default: "#{Socket.gethostname}.network.sockets"

  def output_metric(name, value)
    output "#{@config[:scheme]}.#{name} #{value} #{@timestamp}"
  end

  def socket_metrics(fields)
    name = 'total_used'
    value = fields[2]
    output_metric(name, value)
  end

  def generic_metrics(fields)
    proto = fields[0].sub(':', '')
    fields[1..-1].join(' ').scan(/([A-Za-z]+) (\d+)/).each do |tuple|
      output_metric("#{proto}.#{tuple[0]}", tuple[1])
    end
  end

  def read_sockstat
    IO.read('/proc/net/sockstat')
  rescue StandardError => e
    unknown "Failed to read /proc/net/sockstat: #{e}"
  end

  def run
    sockstat = read_sockstat
    @config = config
    @timestamp = Time.now.to_i
    sockstat.split("\n").each do |line|
      fields = line.split
      if fields[0] == 'sockets:'
        socket_metrics(fields)
      elsif fields.length > 1
        generic_metrics(fields)
      end
    end
    ok
  end
end
