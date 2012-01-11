#!/usr/bin/env ruby

require 'rubygems'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w(--no-colour --format progress)
end

task :default => [:spec]
