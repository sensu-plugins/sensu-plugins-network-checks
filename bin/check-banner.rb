#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-banner
#
# DESCRIPTION:
# Connect to a TCP port on one or more hosts, read till a char (EOF, EOL, etc)
# and test output against a pattern.
#
# Useful for SSH, ZooKeeper, etc.
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
# To check there is only one zk leader
# ./check-banner.rb -h 'zk01,z02,zk03' -p 2181 -q leader -c 1 -w mntr -r EOF -O "ZK has one leader"
# -C "ZK has zero or more than one leader"
#
# NOTES:
# By default, checks for openssh on localhost port 22 and reads till EOL
#
#
# LICENSE:
#   Copyright 2012 Sonian, Inc <chefs@sonian.net>
#   Modified by Raghu Udiyar <raghu@helpshift.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'openssl'
require 'sensu-plugin/check/cli'
require 'socket'
require 'timeout'

#
# Check Banner
#
class CheckBanner < Sensu::Plugin::Check::CLI
  option :hosts,
         short: '-H HOSTNAME(S)',
         long: '--hostnames HOSTNAME(S)',
         description: 'Host(s) to connect to, comma seperated',
         default: 'localhost'

  option :port,
         short: '-p PORT',
         long: '--port PORT',
         proc: proc(&:to_i),
         default: 22

  option :write,
         short: '-w STRING',
         long: '--write STRING',
         description: 'write STRING to the socket'

  option :exclude_newline,
         short: '-e',
         long: '--exclude_newline',
         description: 'Exclude newline character at end of write STRING',
         boolean: true,
         default: false

  option :pattern,
         short: '-q PAT',
         long: '--pattern PAT',
         description: 'Pattern to search for'

  option :timeout,
         short: '-t SECS',
         long: '--timeout SECS',
         description: 'Connection timeout',
         proc: proc(&:to_i),
         default: 30

  option :count_match,
         short: '-c NUMBER',
         long: '--count NUMBER',
         description: 'Number of successful matches, default(1)',
         proc: proc(&:to_i),
         default: 1

  option :read_till,
         short: '-r CHAR',
         long: '--readtill CHAR',
         description: 'Read till CHAR is reached',
         default: "\n"

  option :ok_message,
         short: '-O MESSAGE',
         long: '--okmessage MESSAGE',
         description: 'Custom ok message to send'

  option :crit_message,
         short: '-C MESSAGE',
         long: '--critmessage MESSAGE',
         description: 'Custom critical message to send'

  option :ssl,
         short: '-S',
         long: '--ssl',
         description: 'Enable SSL socket for secure connection'

  def acquire_banner(host)
    Timeout.timeout(config[:timeout]) do
      sock = TCPSocket.new(host, config[:port])

      if config[:ssl]
        ssl_context = OpenSSL::SSL::SSLContext.new
        sock = OpenSSL::SSL::SSLSocket.new(sock, ssl_context)
        sock.connect
      end

      if config[:write]
        sock.write config[:write]
        sock.write "\n" unless config[:exclude_newline]
      end
      if config[:read_till] == 'EOF'
        sock.gets(nil)
      else
        sock.gets(config[:read_till])
      end
    end
  rescue Errno::ECONNREFUSED
    critical "Connection refused by #{host}:#{config[:port]}"
  rescue Timeout::Error
    critical 'Connection or read timed out'
  rescue Errno::EHOSTUNREACH
    critical 'Check failed to run: No route to host'
  rescue EOFError
    critical 'Connection closed unexpectedly'
  end

  def acquire_no_banner(host)
    Timeout.timeout(config[:timeout]) do
      TCPSocket.new(host, config[:port])
    end
  rescue Errno::ECONNREFUSED
    critical "Connection refused by #{host}:#{config[:port]}"
  rescue Timeout::Error
    critical 'Connection or read timed out'
  rescue Errno::EHOSTUNREACH
    critical 'Check failed to run: No route to host'
  rescue EOFError
    critical 'Connection closed unexpectedly'
  end

  def run
    hosts = config[:hosts].split(',')
    okarray = []
    hosts.each do |host|
      case config[:pattern]
      when nil
        banner = acquire_no_banner host
        okarray << 'ok' if banner
      else
        banner = acquire_banner host
        okarray << 'ok' if banner =~ /#{config[:pattern]}/
      end
      if okarray.size == config[:count_match] && !config[:pattern].nil?
        ok "pattern #{config[:pattern]} matched" unless config[:ok_message]
        ok config[:ok_message]
      elsif okarray.size == config[:count_match] && config[:pattern].nil?
        ok "port #{config[:port]} open" unless config[:ok_message]
        ok config[:ok_message]
      else
        critical "port count or pattern #{config[:pattern]} does not match" unless config[:crit_message]
        critical config[:crit_message]
      end
    end
  end
end
