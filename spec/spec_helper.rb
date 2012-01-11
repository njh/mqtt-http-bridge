$:.unshift(File.join(File.dirname(__FILE__),'..'))

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

# This is needed by rcov
#require 'rspec/autorun'
