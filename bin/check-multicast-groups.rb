#! /usr/bin/env ruby
# frozen_string_literal: false

#
#   check-multicast-groups
#
# DESCRIPTION:
#   This plugin checks if specific multicast groups are configured
#   on specific interfaces. The netstat command is required.
#
#   The configurations can be put in the default sensu config directory
#   and/or out of the sensu directory, as a JSON file. If the config file
#   is not in the sensu directry, -c PATH option must be given.
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
#   example commands
#
# NOTES:
#   Does it behave differently on specific platforms, specific use cases, etc
#
# LICENSE:
# Copyright 2014 Mitsutoshi Aoe <maoe@foldr.in>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'json'
require 'sensu-plugin/check/cli'
require 'sensu-plugin/utils'
require 'set'

#
# Check Multicast Groups
#
class CheckMulticastGroups < Sensu::Plugin::Check::CLI
  include Sensu::Plugin::Utils

  option :config,
         short: '-c PATH',
         long: '--config PATH',
         required: true,
         description: 'Path to a config file'

  def run
    targets = load_config(config[:config])['check-multicast-groups'] || []
    critical 'No target muticast groups are specified.' if targets.empty?

    iface_pat = /[a-zA-Z0-9\.]+/
    refcount_pat = /\d+/
    group_pat = /[a-f0-9\.:]+/ # assumes that -n is given
    pattern = /(#{iface_pat})\s+#{refcount_pat}\s+(#{group_pat})/

    actual = Set.new(`netstat -ng`.scan(pattern))
    expected = Set.new(targets)

    diff = expected.difference(actual)
    unless diff.empty?
      diff_output = diff.map { |iface, addr| "#{iface}\t#{addr}" }.join("\n")
      critical "#{diff.size} missing multicast group(s):\n#{diff_output}"
    end
    ok
  rescue StandardError => e
    critical "Failed to check multicast groups: #{e}"
  end
end
