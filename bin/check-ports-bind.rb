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
# ./check-ports.rb -p 127.0.0.1:22,127.0.0.1:1812/udp,46.20.205.10:389/both
# If you mention a port without the bind address then the default address is : 0.0.0.0
#
# NOTES:
# By default, checks for openssh on localhost port 22 (TCP)
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
    description: 'Check given ports on both, TCP & UDP, if no explicit protocol is set',
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
    description: 'different address:port/protocol to check, comma separated (0.0.0.0:22,localhost:25/tcp,127.0.0.0.1:8100-8131/udp,192.168.0.12:3030/both)',
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
      warning(text.to_s)
    else
      critical(text.to_s)
    end
  end

  # Check valid port number
  def valid_port?(port)
    return false unless port =~ /^[0-9]+$/

    (0..65_535).include?(port.to_i)
  end

  # Check valid port range
  def valid_port_range?(port)
    return false unless port =~ /^[0-9]+-[0-9]+$/

    port_start, port_end = port.split('-', 2)

    valid_port?(port_start) && valid_port?(port_end) && port_start.to_i <= port_end.to_i
  end

  # Ports to check
  def portbinds
    default_protocol = config[:hard] ? 'both' : 'tcp'
    binds = []

    config[:portbinds].split(',').each do |portbind|
      portbind = "#{config[:host]}:#{portbind}" unless portbind.include?(':')
      portbind = "#{portbind}/#{default_protocol}" unless portbind.include?('/')

      protocol     = portbind.split('/')[1] || default_protocol
      address_port = portbind.split('/')[0]
      address      = address_port.split(':')[0]
      port         = address_port.split(':')[1]

      if valid_port_range?(port)
        # Port range

        first_port, last_port = port.split('-', 2)
        (first_port.to_i..last_port.to_i).each do |p|
          binds += portbindings(address, p, protocol)
        end
      elsif valid_port?(port)
        # Single port

        binds += portbindings(address, port, protocol)
      else
        critical("Invalid port or port range: #{port}")
      end
    end

    binds
  end

  def portbindings(address, port, protocol)
    if protocol == 'both'
      [
        { address: address, port: port, protocol: 'tcp' },
        { address: address, port: port, protocol: 'udp' }
      ]
    else
      [{ address: address, port: port, protocol: protocol }]
    end
  end

  # Portbind hash to string
  def portbind_to_s(portbind)
    "#{portbind[:address]}:#{portbind[:port]}/#{portbind[:protocol]}"
  end

  # Check TCP port
  def check_tcp_port(portbind, okays)
    Timeout.timeout(config[:timeout]) do
      connection = TCPSocket.new(portbind[:address], portbind[:port])
      p connection if config[:debug]
      okays.push(portbind_to_s(portbind))
    end
  end

  # Check UDP port
  def check_udp_port(portbind, okays)
    Timeout.timeout(config[:timeout]) do
      s = UDPSocket.new
      s.connect(portbind[:address], portbind[:port])
      s.close
      okays.push(portbind_to_s(portbind))
    end
  end

  # Check address:port/protocol
  def check_port(portbind, okays)
    case portbind[:protocol].downcase
    when 'tcp'
      check_tcp_port(portbind, okays)
    when 'udp'
      check_udp_port(portbind, okays)
    else
      severity(config[:warn], "Unsupported protocol #{portbind_to_s(portbind)}")
    end
  rescue Errno::ECONNREFUSED
    severity(config[:warn], "Connection refused by #{portbind_to_s(portbind)}")
  rescue Timeout::Error
    severity(config[:warn], "Connection or read timed out (#{portbind_to_s(portbind)})")
  rescue Errno::EHOSTUNREACH
    severity(config[:warn], "Check failed to run: No route to host (#{portbind_to_s(portbind)})")
  rescue EOFError
    severity(config[:warn], "Connection closed unexpectedly (#{portbind_to_s(portbind)})")
  end

  def run
    ports = portbinds
    okays = []

    ports.each do |portbind|
      check_port(portbind, okays)
    end

    if okays.size == ports.size
      ok "All ports (#{config[:portbinds]}) are reachable: #{okays.join(', ')}"
    else
      severity(config[:warn], 'port count or pattern does not match')
    end
  end
end
