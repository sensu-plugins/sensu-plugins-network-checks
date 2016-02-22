#! /usr/bin/env ruby
#
#   check-ports_spec
#
# DESCRIPTION:
#  rspec tests for check-ports
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
#   Copyright 2015 Robin <robin81@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require_relative '../bin/check-ports'
require_relative './spec_helper.rb'

describe CheckPort  do
  let(:checker_tcp) { described_class.new }
  let(:checker_udp) { described_class.new }

  ## Simulate the system when you connect tcp
  before(:each) do
    # Default config
    checker_tcp.config[:port] = 80
    checker_tcp.config[:host] = 'localhost'
    checker_tcp.config[:timeout] = 2
    def checker_tcp.ok(*_args)
      exit 0
    end
    def checker_tcp.warning(*_args)
      exit 1
    end
    def checker_tcp.critical(*_args)
      exit 2
    end
  end

  it 'returns ok by default with local http service' do
    begin
      allow(TCPSocket).to receive(:new).and_return(true)
      checker_tcp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 0
  end

  it 'returns ok by default with both ssh and local http service' do
    checker_tcp.config[:host] = 22,80
    begin
      allow(TCPSocket).to receive(:new).and_return(true)
      checker_tcp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 0
  end

  it 'returns critical because of connection refused' do
    begin
      allow(TCPSocket).to receive(:new) { raise Errno::ECONNREFUSED }
      checker_tcp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 2
  end

  it 'returns critical because of timeout' do
    begin
      allow(TCPSocket).to receive(:new) { raise Timeout::Error }
      checker_tcp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 2
  end

  it 'returns critical because of no route to host' do
    begin
      allow(TCPSocket).to receive(:new) { raise Errno::EHOSTUNREACH }
      checker_tcp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 2
  end

  it 'returns critical because of conn closed' do
    begin
      allow(TCPSocket).to receive(:new) { raise EOFError }
      checker_tcp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 2
  end

  ## Simulate the system when you connect using udp
  before(:each) do
    # Default config
    checker_udp.config[:port] = 123
    checker_udp.config[:host] = 'localhost'
    checker_udp.config[:timeout] = 2
    checker_udp.config[:proto] = 'udp'
    def checker_udp.ok(*_args)
      exit 0
    end
    def checker_udp.warning(*_args)
      exit 1
    end
    def checker_udp.critical(*_args)
      exit 2
    end
  end

  it 'returns ok by default with local http service' do
    begin
      allow(UDPSocket.open).to receive(:connect).and_return(true)
      checker_udp.run
    rescue SystemExit => e
      exit_code = e.status
    end
    expect(exit_code).to eq 0
  end
end
