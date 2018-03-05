#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-ports-bind
#
# DESCRIPTION:
# Connect to a TCP/UDP address:port, to check whether open or closed.
# Don't use nmap since it's overkill.
# Test UDP ports as well: Experimental
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
# ./check-ports.rb -p 127.0.0.1:22,46.20.205.10 --hard --warn
# ./check-ports.rb -p 127.0.0.1:22,46.20.205.10:80
# If you mention a port without the bind address then the default address is : 0.0.0.0
#
# NOTES:
# By default, checks for openssh on localhost port 22
#
#
# LICENSE:
#   Adpated from check-ports.rb
#   Magic Online - www.magic.fr - hanynowsky@gmail.com
#   September 2016
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'socket'
require 'timeout'

#
# Check Ports by bound address
#
class CheckPort < Sensu::Plugin::Check::CLI
  option(
    :hard,
    short: '-d',
    long: '--hard',
    description: 'Check given ports on both, TCP & UDP',
    boolean: true,
    default: false

  )
  option(
    :host,
    short: '-H HOSTNAME',
    long: '--hostname HOSTNAME',
    description: 'default Host address bound to port',
    default: '0.0.0.0'
  )

  option(
    :portbinds,
    short: '-p PORTS',
    long: '--portbinds PORTS',
    description: 'different address:port to check, comma separated (0.0.0.0:22,localhost:25,127.0.0.0.1:8100-8131,192.168.0.12:3030)',
    default: '0.0.0.0:22'
  )

  option(
    :timeout,
    short: '-t SECS',
    long: '--timeout SECS',
    description: 'Connection timeout',
    proc: proc(&:to_i),
    default: 10
  )

  option(
    :warn,
    description: 'Alert level. warn(warning) instead of critical',
    short: '-w',
    long: '--warn',
    default: false,
    boolean: true
  )

  option(
    :debug,
    description: 'Print debug info',
    short: '-D',
    long: '--debug',
    default: false,
    boolean: true
  )

  # Severity switcher
  def severity(warn, text)
    if warn
      warning text.to_s
    else
      critical text.to_s
    end
  end

  # Check address:port
  def check_port(portbind, okays)
    address = portbind.split(':')[0]
    port = portbind.split(':')[1]
    Timeout.timeout(config[:timeout]) do
      connection = TCPSocket.new(address, port.to_i)
      p connection if config[:debug]
      okays.push("TCP-#{portbind}")
    end
    if config[:hard]
      Timeout.timeout(config[:timeout]) do
        s = UDPSocket.new
        s.connect(address, port.to_i)
        s.close
        okays.push("UDP-#{portbind}")
      end
    end
  rescue Errno::ECONNREFUSED
    severity(config[:warn], "Connection refused by #{portbind}")
  rescue Timeout::Error
    severity(config[:warn], "Connection or read timed out (#{portbind})")
  rescue Errno::EHOSTUNREACH
    severity(config[:warn], "Check failed to run: No route to host (#{portbind})")
  rescue EOFError
    severity(config[:warn], "Connection closed unexpectedly (#{portbind})")
  end

  def run
    portbinds = config[:portbinds].split(',').flat_map do |port_bind|
      port_bind = "#{config[:host]}:#{port_bind}" unless port_bind.include? ':'
      # Port range
      if port_bind.split(',')[1] =~ /^[0-9]+(-[0-9]+)$/
        first_port, last_port = port_bind.split('-')
        (first_port.to_i..last_port.to_i).to_a
        # Single port
      else
        port_bind
      end
    end
    array = []
    portbinds.each do |port|
      check_port(port, array)
    end
    multiplier = 1
    multiplier = 2 if config[:hard] == true
    if array.size == portbinds.size * multiplier
      ok "All ports (#{config[:portbinds]}) are reachable - HARD: #{config[:hard]} => SUCCESS: #{array}"
    else
      severity(config[:warn], 'port count or pattern does not match')
    end
  end
end
