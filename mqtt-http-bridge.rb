#!/usr/bin/env ruby
#
# MQTT to HTTP bridge
#
# Copyright 2012 Nicholas Humfrey <njh@aelius.com>
#

require 'rubygems'
require 'mqtt/client'
require 'sinatra'


class MqttHttpBridge < Sinatra::Base
  MQTT_SERVER='test.mosquitto.org'
  MQTT_TIMEOUT=1.0

  def mqtt_get(topic)
    mqtt = MQTT::Client.new(MQTT_SERVER)
    mqtt.clean_start = true
    mqtt.connect do
      mqtt.subscribe(topic)
      begin
        timeout(MQTT_TIMEOUT) do
          topic,message = mqtt.get
          return message
        end
      rescue Timeout::Error
        not_found("No retained data on topic")
      end
    end
  end

  def mqtt_topics
    mqtt = MQTT::Client.new(MQTT_SERVER)
    mqtt.clean_start = true

    topics = []
    mqtt.connect do
      mqtt.subscribe('#')
      mqtt.subscribe('$SYS/#')
      begin
        timeout(MQTT_TIMEOUT) do
          loop do
            topic,message = mqtt.get
            topics << topic
          end
        end
      rescue Timeout::Error
      end
    end
    return topics
  end

  def mqtt_publish(topic, payload)
    mqtt = MQTT::Client.new(MQTT_SERVER)
    mqtt.clean_start = true
    mqtt.connect do
      mqtt.publish(topic, payload, retain=true)
    end
  end

  def topic
    request.path_info.slice(1..-1)
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
      pattern = /#{Regexp.union(*mapping.keys)}/n
      string.to_s.gsub(pattern){|c| mapping[c] }
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

  get // do
    content_type('text/plain')
    mqtt_get(topic)
  end

  post // do
    content_type('text/plain')
    mqtt_publish(topic, request.body.read)
    "OK"
  end
end
