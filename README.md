mqtt-http-bridge.rb
===================

This simple web application provides a bridge between HTTP and [MQTT] using 
a [REST]ish interface. It is possible to GET, POST, PUT and DELETE retained messages 
on a remote MQTT server.



Getting started
---------------

Install bundler:

    sudo gem install bundler
    
Install the other gem dependencies:

    bundle install

Run the local web server:

    bundle exec rackup -p 1234

You can then open the bridge in your browser:

    http://localhost:1234/



Examples using curl
-------------------

To get a retained value for a topic:

    curl http://localhost:1234/test

To publish to a topic (retained):

    curl -X PUT --data-binary "Hello World" http://localhost:1234/test

To publish to a topic (non-retained):

    curl -X POST --data-binary "Hello World" http://localhost:1234/test

To delete the retained value for a topic:

    curl -X DELETE http://localhost:1234/test




License
-------

The ruby mqtt-http-bridge is licensed under the terms of the MIT license.
See the file LICENSE for details.


Contact
-------

* Author:    Nicholas J Humfrey
* Twitter:   [@njh](http://twitter.com/njh)
* Home Page: http://www.aelius.com/njh/


[MQTT]:    https://en.wikipedia.org/wiki/MQTT
[REST]:    http://en.wikipedia.org/wiki/Representational_state_transfer
