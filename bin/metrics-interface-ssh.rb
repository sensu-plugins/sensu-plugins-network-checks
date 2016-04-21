#! /usr/bin/env ruby
#  encoding: UTF-8
#
#   metrics-interface-ssh
#
# DESCRIPTION:
#   unlike metrics-interface, this gather metrics from interfaces
#   of an host reacheable through SSH.
#   typically this can be used to track metrics for an host which is not
#   able to run sensu directly (dd-wrt, etc ...)
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
#
# NOTES:
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'socket'
require 'net/ssh'

#
# Interface Graphite
#
class InterfaceGraphite < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME'

  option :excludeinterface,
         description: 'List of interfaces to exclude',
         short: '-x INTERFACE[,INTERFACE]',
         long: '--exclude-interface',
         proc: proc { |a| a.split(',') },
         default: ["lo"]

  option :includeinterface,
         description: 'List of interfaces to include',
         short: '-i INTERFACE[,INTERFACE]',
         long: '--include-interface',
         proc: proc { |a| a.split(',') }

  option :host,
         description: 'Remove host',
         short: '-h HOST',
         long: '--host HOST',
         default: '192.168.0.1'

  option :port,
         description: 'Remote SSH port',
         short: '-p PORT',
         long: '--port PORT',
         default: 22

  option :user,
         description: 'Remote SSH username',
         short: '-u USER',
         long: '--user USER',
         default: 'root'

  def run
    # Metrics borrowed from hoardd: https://github.com/coredump/hoardd

    metrics = %w[rxBytes
                 rxPackets
                 rxErrors
                 rxDrops
                 rxFifo
                 rxFrame
                 rxCompressed
                 rxMulticast
                 txBytes
                 txPackets
                 txErrors
                 txDrops
                 txFifo
                 txColls
                 txCarrier
                 txCompressed]

    output = nil

    Net::SSH.start(config[:host], config[:user], :port => config[:port]) do |ssh|
      output = ssh.exec!("cat /proc/net/dev")
    end

    return if not output

    if not config[:scheme]
      config[:scheme] = "#{config[:host].tr('.','_')}.interface"
    end

    output.each_line do |line|
      interface, stats_string = line.scan(/^\s*([^:]+):\s*(.*)$/).first
      next if config[:excludeinterface] && config[:excludeinterface].find { |x| line.match(x) }
      next if config[:includeinterface] && !(config[:includeinterface].find { |x| line.match(x) })
      next unless interface
      if interface.is_a?(String)
        interface = interface.tr('.', '_')
      end

      stats = stats_string.split(/\s+/)
      next if stats == ['0'].cycle.take(stats.size)

      metrics.size.times { |i| output "#{config[:scheme]}.#{interface}.#{metrics[i]}", stats[i] }
    end

    ok
  end
end
