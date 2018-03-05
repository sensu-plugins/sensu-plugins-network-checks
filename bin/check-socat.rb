#! /usr/bin/env ruby
# frozen_string_literal: false

#
#   check-socat
#
# DESCRIPTION:
#   Run socat to inspect sockets
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   coreutils package for the timeout command
#   socat package
#
# USAGE:
#
# Check if socat can receive particular a UDP multicast packet in 10 seconds:
#   check-socat.rb -t 10s -i UDP4-RECVFROM:<PORT>,ip-add-membership=<MULTICASTADDR>:<INTERFACE> -o /dev/null
#
# Check if a UDP multicast packet contains an expected pattern:
#   check-socat.rb -t 10s -i UDP4-RECVFROM:<PORT>,ip-add-membership=<MULTICASTADDR>:<INTERFACE> -o - --pipe "grep PATTERN"
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'open3'
require 'sensu-plugin/check/cli'

class SocatCheck < Sensu::Plugin::Check::CLI
  option :timeout,
         description: 'Timeout in seconds',
         short: '-t DURATION',
         long: '--timeout DURATION',
         default: '5s'

  option :input,
         description: 'Input stream',
         short: '-i INPUT',
         long: '--input INPUT',
         required: true

  option :output,
         description: 'Output stream',
         short: '-o OUTPUT',
         long: '--output OUTPUT',
         required: true

  option :pipe,
         description: 'Pipe socat output into this command',
         short: '-p COMMAND',
         long: '--pipe COMMAND'

  def run
    pipe = config[:pipe].nil? ? '' : "| #{config[:pipe]}"
    timeout = config[:timeout]
    stdout, stderr, status = Open3.capture3(
      %(bash -c "set -o pipefail; timeout #{timeout} socat #{config[:input]} #{config[:output]} #{pipe}")
    )
    if status.success?
      ok stdout
    else
      case status.exitstatus
      when 124
        critical "socat timed out\n#{stderr}"
      when 125
        critical "timeout failed\n#{stderr}"
      when 126
        critical "socat cannot be invoked\n#{stderr}"
      when 127
        critical "socat cannot be found\n#{stderr}"
      when 137
        critical "socat is sent the KILL signal\n#{stderr}"
      else
        critical stderr
      end
    end
  end
end
