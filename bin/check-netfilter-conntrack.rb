#!/usr/bin/env ruby
# frozen_string_literal: true

#
#   check-netfilter-conntrack
#
# DESCRIPTION:
#   Check netfilter connection tracking table condition
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
#   $ ./check-netfilter-conntrack.rb --warning 60 --critical 90
#
# NOTES:
#   - If you need to check the conntrack table of a specific linux
#     network namespace (e.g in a docker context), run this check as
#     `nsenter --net=<file> check-netfilter-conntrack.rb` to use the
#     network namespace which `<file>`'s descriptor indicates.
#
# LICENSE:
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'

#
# Check Netfilter connection tracking table condition
#
class CheckNetfilterConntrack < Sensu::Plugin::Check::CLI
  option :warning,
         description: 'Warn if conntrack table is filled more than PERC%',
         short: '-w PERC',
         long: '--warning PERC',
         default: 80,
         proc: proc(&:to_i)

  option :critical,
         description: 'Critical if conntrack table is filled more than PERC%',
         short: '-c PERC',
         long: '--critical PERC',
         default: 90,
         proc: proc(&:to_i)

  def nf_conntrack_max
    File.read('/proc/sys/net/netfilter/nf_conntrack_max').to_i
  end

  def nf_conntrack_count
    File.read('/proc/sys/net/netfilter/nf_conntrack_count').to_i
  end

  def run
    max = nf_conntrack_max
    count = nf_conntrack_count
    percentage = (count / max.to_f) * 100

    message "Table is at #{percentage.round(1)}% (#{count}/#{max})"

    critical if percentage >= config[:critical]
    warning if percentage >= config[:warning]
    ok
  rescue StandardError
    warning "Can't read conntrack information."
  end
end
