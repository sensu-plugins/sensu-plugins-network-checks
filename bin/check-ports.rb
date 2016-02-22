#! /usr/bin/env ruby
#
#  encoding: UTF-8
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
  option :host,
         short: '-H HOSTNAME',
         long: '--hostname HOSTNAME',
         description: 'Host to connect to',
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

  def check_port(port)
    timeout(config[:timeout]) do
      config[:proto].downcase == 'tcp' ? TCPSocket.new(config[:host], port.to_i) : UDPSocket.open.connect(config[:host], port.to_i)
    end
    rescue Errno::ECONNREFUSED
      critical "Connection refused by #{config[:host]}:#{port}"
    rescue Timeout::Error
      critical "Connection or read timed out (#{config[:host]}:#{port})"
    rescue Errno::EHOSTUNREACH
      critical "Check failed to run: No route to host (#{config[:host]}:#{port})"
    rescue EOFError
      critical "Connection closed unexpectedly (#{config[:host]}:#{port})"
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
    okarray = []
    ports.each do |port|
      okarray << 'ok' if check_port port
    end
    if okarray.size == ports.size
      ok "All ports (#{config[:ports]}) are accessible for host #{config[:host]}"
    else
      warning "port count or pattern #{config[:pattern]} does not match" unless config[:crit_message]
    end
  end
end
