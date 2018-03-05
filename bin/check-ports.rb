#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-ports
#
# DESCRIPTION:
# Connect to a TCP/UDP port on one or more ports, to see if open.   Don't use nmap since it's overkill.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# Ports are comma separated and support ranges
# ./check-ports.rb -H localhost -p 22,25,8100-8131,3030 -P tcp
#
# NOTES:
# By default, checks for openssh on localhost port 22
#
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'socket'
require 'timeout'

#
# Check Banner
#
class CheckPort < Sensu::Plugin::Check::CLI
  option :hosts,
         short: '-H HOSTNAME',
         long: '--hostname HOSTNAME',
         description: 'Hosts to connect to, comma separated',
         default: '0.0.0.0'

  option :ports,
         short: '-p PORTS',
         long: '--ports PORTS',
         description: 'Ports to check, comma separated (22,25,8100-8131,3030)',
         default: '22'

  option :proto,
         short: '-P PROTOCOL',
         long: '--protocol PROTOCOL',
         description: 'Protocol to check: tcp (default) or udp',
         default: 'tcp'

  option :timeout,
         short: '-t SECS',
         long: '--timeout SECS',
         description: 'Connection timeout',
         proc: proc(&:to_i),
         default: 30

  def check_port(port, host)
    Timeout.timeout(config[:timeout]) do
      config[:proto].casecmp('tcp').zero? ? TCPSocket.new(host, port.to_i) : UDPSocket.open.connect(host, port.to_i)
    end
  rescue Errno::ECONNREFUSED
    critical "Connection refused by #{host}:#{port}"
  rescue Timeout::Error
    critical "Connection or read timed out (#{host}:#{port})"
  rescue Errno::EHOSTUNREACH
    critical "Check failed to run: No route to host (#{host}:#{port})"
  rescue EOFError
    critical "Connection closed unexpectedly (#{host}:#{port})"
  end

  def run
    ports = config[:ports].split(',').flat_map do |port|
      # Port range
      if port =~ /^[0-9]+(-[0-9]+)$/
        first_port, last_port = port.split('-')
        (first_port.to_i..last_port.to_i).to_a
      # Single port
      else
        port
      end
    end

    hosts = config[:hosts].split(',')

    okarray = []
    hosts.each do |host|
      ports.each do |port|
        okarray << 'ok' if check_port(port, host)
      end
    end
    if okarray.size == ports.size * hosts.size
      ok "All ports (#{config[:ports]}) are accessible for hosts #{config[:hosts]}"
    else
      warning "port count or pattern #{config[:pattern]} does not match" unless config[:crit_message]
    end
  end
end
