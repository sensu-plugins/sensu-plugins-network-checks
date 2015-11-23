#! /usr/bin/env ruby
#
#   check-netif
#
# DESCRIPTION:
#   Network interface throughput monitoring
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#   #YELLOW
#
# NOTES:
#   This plugin depends on rpm package sysstat!
# LICENSE:
#   Copyright 2015 Autodesk, Inc. and contributors. <autumn.wang@autodesk.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'socket'

#
# Netif Monitoring
#
class NetIFMetrics < Sensu::Plugin::Check::CLI
  option :interfaces,
         description: 'Comma delimited list of interface names',
         short: '-i INTERFACES',
         long: '--interfaces INTERFACES',
         default: 'eth0'

  option :critical,
         description: 'Critical throughput in KB',
         short: '-c rx_kb_per_sec,tx_kb_per_sec',
         long: '--critical rx_kb_per_sec,tx_kb_per_sec',
         default: '1048576,1048576'

  option :warning,
         description: 'Waring throughput in KB',
         short: '-w rx_kb_per_sec,tx_kb_per_sec',
         long: '--warning rx_kb_per_sec,tx_kb_per_sec',
         default: '104857,104857'

  def run
    warn_output = "\n"
    critical_output = "\n"

    tmp_list = config[:critical].split(',')
    critcal_rx = tmp_list[0].to_f
    critcal_tx = tmp_list[1].to_f

    tmp_list = config[:warning].split(',')
    warn_rx = tmp_list[0].to_f
    warn_tx = tmp_list[1].to_f

    ifs = config[:interfaces].split(',')

    `sar -n DEV 1 1 | grep Average | grep -v IFACE`.each_line do |line|
      stats = line.split(/\s+/)
      nic = stats[1]

      next unless ifs.include?(nic)

      rx_kb_per_sec = stats[4].to_f if stats[5]
      tx_kb_per_sec = stats[5].to_f if stats[5]
      if rx_kb_per_sec > critcal_rx
        critical_output += "#{nic}.rx_kb_per_sec : #{rx_kb_per_sec}\n"
      elsif rx_kb_per_sec > warn_rx
        warn_output += "#{nic}.rx_kb_per_sec : #{rx_kb_per_sec}\n"
      end
      if tx_kb_per_sec > critcal_tx
        critical_output += "#{nic}.tx_kb_per_sec : #{tx_kb_per_sec}\n"
      elsif tx_kb_per_sec > warn_tx
        warn_output += "#{nic}.tx_kb_per_sec : #{tx_kb_per_sec}\n"
      end
    end
    critical critical_output if critical_output.length > 1
    warning warn_output if warn_output.length > 1
    ok 'All interface throughput is normal.'
  end
end
