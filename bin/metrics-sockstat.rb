#!/usr/bin/env ruby

require 'sensu-plugin/metric/cli'

class Sockstat < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
    description: 'Metric naming scheme, text to prepend to $protocol.$field',
    long: '--scheme SCHEME',
    short: '-s SCHEME',
    default: 'network.sockets'

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
    begin
      return IO.read('/proc/net/sockstat')
    rescue => e
      unknown "Failed to read /proc/net/sockstat: #{e}"
    end
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
