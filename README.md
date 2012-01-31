mqtt-http-bridge.rb
===================

This simple web application provides a bridge between HTTP and [MQTT] using 
a REST type interface. It is possible to get, post and delete retained messages on a
remote MQTT server.


To get a retained value for a topic:
    curl http://test-mosquitto.heroku.com/test

To publish to a topic:
    curl -X POST --data-binary "Hello World" http://test-mosquitto.heroku.com/test

To delete the retained value for a topic:
    curl -X DELETE http://test-mosquitto.heroku.com/test


[MQTT]:    http://mqtt.org/

