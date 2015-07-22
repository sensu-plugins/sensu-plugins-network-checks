RSpec.configure do |c|
  # XXX: Sensu plugins run in the context of an at_exit handler. This prevents
  # XXX: code-under-test from being run at the end of the rspec suite.
  c.before(:each) do
    Sensu::Plugin::CLI.class_eval do
      # PluginStub
      class PluginStub
        def run; end

        def ok(*); end

        def warning(*); end

        def critical(*); end

        def unknown(*); end
      end
      class_variable_set(:@@autorun, PluginStub)
      # rubocop:enable all
    end
  end
end
