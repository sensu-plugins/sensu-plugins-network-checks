#!/usr/bin/env ruby
# frozen_string_literal: true

#
#   check-netfilter-conntrack_spec
#
# DESCRIPTION:
#  rspec tests for netfilter-conntrack-mtu
#
# OUTPUT:
#   RSpec testing output: passes and failures info
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   rspec
#
# USAGE:
#   For Rspec Testing
#
# NOTES:
#   For Rspec Testing
#
# LICENSE:
#   Copyright 2018 Jan Kunzmann <jan-github@phobia.de>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require_relative '../bin/check-netfilter-conntrack'
require_relative './spec_helper.rb'

describe CheckNetfilterConntrack do
  let(:checker) { described_class.new }
  let(:checker_no_file) { described_class.new }
  let(:exit_code) { nil }

  before(:each) do
    def checker.ok(*_args)
      exit 0
    end

    def checker.warning(*_args)
      exit 1
    end

    def checker.critical(*_args)
      exit 2
    end
  end

  [
    [100, 0, 0, 'ok'],
    [100, 79, 0, 'ok'],
    [100, 80, 1, 'warn'],
    [100, 89, 1, 'warn'],
    [100, 90, 2, 'crit'],
    [100, 100, 2, 'crit']
  ].each do |testdata|
    it "returns #{testdata[3]} for default thresholds" do
      begin
        allow(checker).to receive(:nf_conntrack_max).and_return testdata[0]
        allow(checker).to receive(:nf_conntrack_count).and_return testdata[1]
        checker.run
      rescue SystemExit => e
        exit_code = e.status
      end
      expect(exit_code).to eq testdata[2]
    end
  end

  it 'returns warning if conntract sysctl files not found' do
    begin
      allow(checker).to receive(:nf_conntrack_max).and_raise Errno::ENOENT
      checker.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 1
  end
end
