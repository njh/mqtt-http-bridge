require 'rubygems'
require 'bundler'

Bundler.require(:default)

require 'dbpedialite'
run Sinatra::Application
