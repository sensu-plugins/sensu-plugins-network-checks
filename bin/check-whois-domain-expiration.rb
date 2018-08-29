#!/usr/bin/env ruby
# frozen_string_literal: false

#
#   check-whois-domain-expiration
#
# DESCRIPTION:
#   This plugin checks domain expiration dates using the 'whois' gem.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Tested on Mac OS X
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: whois
#
# USAGE:
#   $ ./check-whois-domain-expiration.rb -d mijit.com
#   WhoisDomainExpirationCheck OK: mijit.com expires on 02-07-2016 (325 days away)
#
# LICENSE:
#   Copyright 2015 michael j talarczyk <mjt@mijit.com> and contributors.
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'whois'
require 'whois-parser'

#
# Check Whois domain expiration
#
class WhoisDomainExpirationCheck < Sensu::Plugin::Check::CLI
  option :domain,
         short: '-d DOMAIN',
         long: '--domain DOMAIN',
         required: true,
         description: 'Domain to check'

  option :warning,
         short: '-w DAYS',
         long: '--warn DAYS',
         default: 30,
         description: 'Warn if fewer than DAYS away'

  option :critical,
         short: '-c DAYS',
         long: '--critical DAYS',
         default: 7,
         description: 'Critical if fewer than DAYS away'

  option :help,
         short: '-h',
         long: '--help',
         description: 'Show this message',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0

  def run
    whois = Whois.whois(config[:domain])

    # TODO: figure out which to use `Date` or `Time`
    expires_on = DateTime.parse(whois.parser.expires_on.to_s)
    num_days = (expires_on - DateTime.now).to_i

    message "#{config[:domain]} expires on #{expires_on.strftime('%m-%d-%Y')} (#{num_days} days away)"

    if num_days <= config[:critical].to_i
      critical
    elsif num_days <= config[:warning].to_i
      warning
    else
      ok
    end
  rescue StandardError
    unknown "#{config[:domain]} can't be checked"
  end
end
