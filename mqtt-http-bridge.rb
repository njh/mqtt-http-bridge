#!/usr/bin/env ruby
#
# MQTT to HTTP bridge
# Copyright 2012 Nicholas Humfrey <njh@aelius.com>
#
#
# To get a retained value for a topic:
#   curl http://test-mosquitto.heroku.com/test
#
# To publish to a topic:
#   curl -X POST --data-binary "Hello World" http://test-mosquitto.heroku.com/test
# 

require 'rubygems'
require 'mqtt/client'
require 'sinatra'

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
