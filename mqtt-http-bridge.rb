#!/usr/bin/env ruby
#
# MQTT to HTTP bridge
#
# Copyright 2012 Nicholas Humfrey <njh@aelius.com>
#

require 'rubygems'
require 'mqtt'
require 'sinatra'
require 'timeout'

class MqttHttpBridge < Sinatra::Base
  MQTT_OPTS = {
    :remote_host => 'test.mosquitto.org',
    :keep_alive => 4,
    :clean_session => true
  }

  def mqtt_get(topic)
    MQTT::Client.connect(MQTT_OPTS) do |client|
      client.subscribe(topic)
      begin
        Timeout.timeout(2.5) do
          topic,message = client.get
          client.disconnect
          return message
        end
      rescue Timeout::Error
        not_found("No retained data on topic")
      end
    end
  end

  def mqtt_topics
    topics = []
    MQTT::Client.connect(MQTT_OPTS) do |client|
      client.subscribe('$SYS/#')
      client.subscribe('#')
      begin
        Timeout.timeout(1.0) do
          client.get { |topic,message| topics << topic }
        end
      rescue Timeout::Error
      end
    end
    return topics
  end

  def topic
    unescape(
      request.path_info.slice(1..-1)
    )
  end

  helpers do
    # Escape ampersands, brackets and quotes to their HTML/XML entities.
    # (Rack::Utils.escape_html is overly enthusiastic)
    def h(string)
      mapping = {
        "&" => "&amp;",
        "<" => "&lt;",
        ">" => "&gt;",
        "'" => "&#x27;",
        '"' => "&quot;"
      }
      pattern = /#{Regexp.union(*mapping.keys)}/

      # Clean up invalid UTF-8 characters
      utf16 = string.to_s.encode('UTF-16', :undef => :replace, :invalid => :replace, :replace => "")
      clean = utf16.encode('UTF-8');

      # Now perform escaping
      clean.gsub(pattern){|c| mapping[c] }
    end

    def link_to(title, url=nil, attr={})
      url = title if url.nil?
      attr.merge!('href' => url.to_s)
      attr_str = attr.keys.map {|k| "#{h k}=\"#{h attr[k]}\""}.join(' ')
      "<a #{attr_str}>#{h title}</a>"
    end
  end


  get '/' do
    headers 'Cache-Control' => 'public,max-age=60'
    @topics = mqtt_topics.sort
    erb :index
  end

  get '/*' do
    content_type('text/plain')
    mqtt_get(topic)
  end

  post '/*' do
    content_type('text/plain')
    MQTT::Client.connect(MQTT_OPTS) do |client|
      client.publish(topic, request.body.read, retain=false)
    end
    "OK"
  end

  put '/*' do
    content_type('text/plain')
    MQTT::Client.connect(MQTT_OPTS) do |client|
      client.publish(topic, request.body.read, retain=true)
    end
    "OK"
  end

  delete '/*' do
    content_type('text/plain')
    MQTT::Client.connect(MQTT_OPTS) do |client|
      client.publish(topic, '', retain=true)
    end
    "OK"
  end
end
