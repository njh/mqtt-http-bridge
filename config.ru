require 'rubygems'
require 'bundler'

Bundler.require(:default)

require './mqtt-http-bridge'
run MqttHttpBridge
