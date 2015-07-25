#!/usr/bin/env ruby
# encoding: utf-8
#
#   check-whois-domain-expiration-multi
#
# DESCRIPTION:
#   This plugin checks domain expiration dates using the 'whois' gem.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   *nix systems
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: whois
#
# USAGE:
#   ./check-whois-domain-expiration-multi.rb -d therealtimsmith.com,mightyoakspreschool.com
#   WhoisDomainExpirationCheck WARNING: mightyoakspreschool.com: 30 days
#
# LICENSE:
#   Copyright 2015 Tim Smith (tim@cozy.co) - Cozy Services Ltd.
#   Based on check-whois-domain-expiration, Copyright 2015 michael j talarczyk <mjt@mijit.com>
#    and contributors.
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'whois'

#
# Check Whois domain expiration
#
class WhoisDomainExpirationCheck < Sensu::Plugin::Check::CLI
  option :domain,
         short: '-d DOMAINS',
         long: '--domains DOMAIN',
         required: true,
         description: 'Domain(s) to check. Separate by commas for 2+'

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

  # split the provided domain list and perform whois lookups on each
  # return a hash with domains grouped by their status level
  def expiration_results
    domains = config[:domain].split(',')
    warning_days = config[:warning].to_i
    critical_days = config[:critical].to_i
    results = {}
    results['critical'] = {}
    results['warning'] = {}
    results['ok'] = {}

    domains.each do |domain|
      whois = Whois.whois(domain)
      domain_result =  (DateTime.parse(whois.expires_on.to_s) - DateTime.now).to_i
      if domain_result <= critical_days
        results['critical'][domain] = domain_result
      elsif domain_result <= warning_days
        results['warning'][domain] = domain_result
      else
        results['ok'] = domain_result
      end
    end
    results
  end

  def run
    status = expiration_results
    if !status['critical'].empty?
      critical status['critical'].map { |u, v| "#{u} days left:#{v}" }.join(',')
    elsif !status['warning'].empty?
    else
      ok 'No domains expire in the near term'
    end
  end
end
