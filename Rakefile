require 'bundler/gem_tasks'
require 'github/markup'
require 'redcarpet'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'yard/rake/yardoc_task'

desc 'Don\'t run Rubocop for unsupported versions'
begin
  if RUBY_VERSION >= '2.0.0'
    args = [:spec, :yard, :rubocop, :gem_tests, :binstubs_tests]
  else
    args = [:spec, :yard, :gem_tests, :binstubs_tests]
  end
end

YARD::Rake::YardocTask.new do |t|
  OTHER_PATHS = %w()
  t.files = ['lib/**/*.rb', 'bin/**/*.rb', OTHER_PATHS]
  t.options = %w(--markup-provider=redcarpet --markup=markdown --main=README.md --files CHANGELOG.md,CONTRIBUTING.md)
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new(:spec) do |r|
  r.pattern = FileList['**/**/*_spec.rb']
end

desc 'Test gem install'
task :gem_tests do
  `gem build sensu-plugins-network-checks.gemspec`
  `gem install *.gem`
end

desc 'test for binstubs'
task :binstubs_tests do
  bin_list= Gem::Specification.load('sensu-plugins-network-checks.gemspec').executables

  bin_list.each do |b|
    `which #{ b }`
    if ! $?.success?
      puts "#{ b } was not a binstub"
      exit
    end
  end
end

task default: args
