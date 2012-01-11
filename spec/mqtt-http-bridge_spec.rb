require 'spec_helper'
require 'mqtt-http-bridge'

# NOTE: there is deliberately no mocking in these tests,
#       a live internet connect is required

set :environment, :test

describe MqttHttpBridge do
  include Rack::Test::Methods

  TEST_MESSAGE = "#{Time.now} - Test Message"

  def app
    MqttHttpBridge
  end

  before :each do
    app.enable :raise_errors
    app.disable :show_exceptions
  end

  context "POSTing to a simple topic name" do
    before :all do
      post '/test', TEST_MESSAGE
    end

    it "should be successful" do
      last_response.should be_ok
    end

    it "should have a response of type text/plain" do
      last_response.content_type.should == 'text/plain;charset=utf-8'
    end

    it "should have a response body of 'OK'" do
      last_response.body.should == 'OK'
    end
  end

  context "GETing a simple topic name" do
    before :all do
      get '/test'
    end

    it "should be successful" do
      last_response.should be_ok
    end

    it "should have a response of type text/plain" do
      last_response.content_type.should == 'text/plain;charset=utf-8'
    end

    it "should have a response body of 'OK'" do
      last_response.body.should == TEST_MESSAGE
    end
  end

  context "GETing a topic with a space in the name" do
    before :all do
      get '$SYS/broker/heap/current%20size'
    end

    it "should be successful" do
      last_response.should be_ok
    end

    it "should have a response of type text/plain" do
      last_response.content_type.should == 'text/plain;charset=utf-8'
    end

    it "should have a response body of 'N bytes'" do
      last_response.body.should =~ %r[^\d+ bytes$]
    end
  end

  context "GETing the homepage" do
    before :all do
      get '/'
    end

    it "should be successful" do
      last_response.should be_ok
    end

    it "should be of type text/html" do
      last_response.content_type.should == 'text/html;charset=utf-8'
    end

    it "should be cachable" do
      last_response.headers['Cache-Control'].should =~ /max-age=([1-9]+)/
    end

    it "should contain a page title" do
      last_response.body.should =~ %r[<h1>mqtt-http-bridge.rb</h1>]
    end

    it "should contain an link to the server" do
      last_response.body.should =~ %r[<a href="http://test.mosquitto.org/">test.mosquitto.org</a>]
    end

    it "should contain a link to the 'test' topic" do
      last_response.body.should =~ %r[<li><a href="test">test</a></li>]
    end

    it "should contain a link to the '$SYS/broker/version' topic" do
      last_response.body.should =~ %r[<li><a href="\$SYS/broker/version">\$SYS/broker/version</a></li>]
    end
  end

end
