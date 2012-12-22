require 'spec_helper'
require 'mqtt-http-bridge'

# NOTE: there is deliberately no mocking in these tests,
#       a live internet connection is required

set :environment, :test

describe MqttHttpBridge do
  include Rack::Test::Methods

  TEST_MESSAGE_1 = "#{Time.now} - Test Message 1"
  TEST_MESSAGE_2 = "#{Time.now} - Test Message 2"

  def app
    MqttHttpBridge
  end

  before :each do
    app.enable :raise_errors
    app.disable :show_exceptions
  end

  context "PUTing to a simple topic name" do
    before :all do
      put '/test', TEST_MESSAGE_1
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

  context "PUTing to a topic with a slash at the start" do
    before :all do
      put '/%2Ftest', TEST_MESSAGE_2
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

  context "POSTing to a simple topic name" do
    before :all do
      @put_response = put('/test', TEST_MESSAGE_1)
      @post_response = post('/test', TEST_MESSAGE_2)
      @get_response = get('/test')
    end

    it "should successfully publish a retained message to topic using PUT" do
      @put_response.should be_ok
      @put_response.body.should == 'OK'
    end

    it "should successfully publish a non-retained message to topic using POST" do
      @post_response.should be_ok
      @post_response.body.should == 'OK'
    end

    it "should successfully GET the retained message afterwards" do
      @get_response.should be_ok
      @get_response.body.should == TEST_MESSAGE_1
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
      last_response.body.should == TEST_MESSAGE_1
    end
  end

  context "GETing a topic name with a slash at the start" do
    before :all do
      get '/%2Ftest'
    end

    it "should be successful" do
      last_response.should be_ok
    end

    it "should have a response of type text/plain" do
      last_response.content_type.should == 'text/plain;charset=utf-8'
    end

    it "should have a response body of 'OK'" do
      last_response.body.should == TEST_MESSAGE_2
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

    it "should have a response body of an integer" do
      last_response.body.should =~ %r[^\d+$]
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
      last_response.body.should =~ %r[<h1>HTTP to MQTT Bridge for (.+)</h1>]
    end

    it "should contain the text from the README" do
      last_response.body.should =~ %r[This simple web application provides a bridge between HTTP]
    end

    it "should contain a link to a topic not starting with a slash" do
      last_response.body.should =~ %r[<li><a href="\w+">\w+</a></li>]
    end

    it "should contain a link to a topic starting with a slash" do
      last_response.body.should =~ %r[<li><a href="%2F\w">/\w+</a></li>]
    end

    it "should contain a link to the '$SYS/broker/version' topic" do
      last_response.body.should =~ %r[<li><a href="%24SYS%2Fbroker%2Fversion">\$SYS/broker/version</a></li>]
    end
  end


  context "DELETEing a topic" do
    before :all do
      @put_response = put('/deleteme', TEST_MESSAGE_1)
      @get1_response = get('/deleteme')
      @delete_response = delete('/deleteme')
      @get2_response = get('/deleteme')
    end

    it "should successfully create the topic to be deleted" do
      @put_response.should be_ok
      @put_response.body.should == 'OK'
    end

    it "should successfully GET back the topic to be deleted" do
      @get1_response.should be_ok
      @get1_response.body.should == TEST_MESSAGE_1
    end

    it "should successfully delete the topic" do
      @delete_response.should be_ok
      @delete_response.body.should == 'OK'
    end

    it "should return 404 after deleting the topic" do
      @get2_response.should be_not_found
    end
  end

end
