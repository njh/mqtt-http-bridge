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
      put '/test-mhb', TEST_MESSAGE_1
    end

    it "should be successful" do
      expect(last_response).to be_ok
    end

    it "should have a response of type text/plain" do
      expect(last_response.content_type).to eq('text/plain;charset=utf-8')
    end

    it "should have a response body of 'OK'" do
      expect(last_response.body).to eq('OK')
    end
  end

  context "PUTing to a topic with a slash at the start" do
    before :all do
      put '/%2Ftest', TEST_MESSAGE_2
    end

    it "should be successful" do
      expect(last_response).to be_ok
    end

    it "should have a response of type text/plain" do
      expect(last_response.content_type).to eq('text/plain;charset=utf-8')
    end

    it "should have a response body of 'OK'" do
      expect(last_response.body).to eq('OK')
    end
  end

  context "POSTing to a simple topic name" do
    before :all do
      @put_response = put('/test-mhb', TEST_MESSAGE_1)
      @post_response = post('/test-mhb', TEST_MESSAGE_2)
      @get_response = get('/test-mhb')
    end

    it "should successfully publish a retained message to topic using PUT" do
      expect(@put_response).to be_ok
      expect(@put_response.body).to eq('OK')
    end

    it "should successfully publish a non-retained message to topic using POST" do
      expect(@post_response).to be_ok
      expect(@post_response.body).to eq('OK')
    end

    it "should successfully GET the retained message afterwards" do
      expect(@get_response).to be_ok
      expect(@get_response.body).to eq(TEST_MESSAGE_1)
    end
  end


  context "GETing a simple topic name" do
    before :all do
      get '/test-mhb'
    end

    it "should be successful" do
      expect(last_response).to be_ok
    end

    it "should have a response of type text/plain" do
      expect(last_response.content_type).to eq('text/plain;charset=utf-8')
    end

    it "should have a response body of 'OK'" do
      expect(last_response.body).to eq(TEST_MESSAGE_1)
    end
  end

  context "GETing a topic name with a slash at the start" do
    before :all do
      get '/%2Ftest'
    end

    it "should be successful" do
      expect(last_response).to be_ok
    end

    it "should have a response of type text/plain" do
      expect(last_response.content_type).to eq('text/plain;charset=utf-8')
    end

    it "should have a response body of 'OK'" do
      expect(last_response.body).to eq(TEST_MESSAGE_2)
    end
  end

  context "GETing a topic with a space in the name" do
    before :all do
      @put_response = put('/test%20mhb%20space', TEST_MESSAGE_1)
      @get_response = get('/test%20mhb%20space')
    end

    it "should successfully publish a retained message to topic using PUT" do
      expect(@put_response).to be_ok
      expect(@put_response.body).to eq('OK')
    end

    it "should successfully GET the retained message afterwards" do
      expect(@get_response).to be_ok
      expect(@get_response.body).to eq(TEST_MESSAGE_1)
    end
  end

  context "GETing the homepage" do
    before :all do
      get '/'
    end

    it "should be successful" do
      expect(last_response).to be_ok
    end

    it "should be of type text/html" do
      expect(last_response.content_type).to eq('text/html;charset=utf-8')
    end

    it "should be cachable" do
      expect(last_response.headers['Cache-Control']).to match(/max-age=([1-9]+)/)
    end

    it "should contain a page title" do
      expect(last_response.body).to match(%r[<h1>HTTP to MQTT Bridge for (.+)</h1>])
    end

    it "should contain the text from the README" do
      expect(last_response.body).to match(%r[This simple web application provides a bridge between HTTP])
    end

    it "should contain a link to a topic not starting with a slash" do
      expect(last_response.body).to match(%r[<li><a href="\w+">\w+</a></li>])
    end

    it "should contain a link to a topic starting with a slash" do
      expect(last_response.body).to match(%r[<li><a href="%2F\w+">/\w+</a></li>])
    end

    it "should contain a link to the '$SYS/broker/version' topic" do
      expect(last_response.body).to match(%r[<li><a href="%24SYS%2Fbroker%2Fversion">\$SYS/broker/version</a></li>])
    end

    it "should not have any duplicate <li> lines" do
      lines = last_response.body.split(/\n+/).select {|line| line.match(/<li>/)}
      dups = lines.group_by{|e| e}.keep_if{|_, e| e.length > 1}
      expect(dups).to be_empty
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
      expect(@put_response).to be_ok
      expect(@put_response.body).to eq('OK')
    end

    it "should successfully GET back the topic to be deleted" do
      expect(@get1_response).to be_ok
      expect(@get1_response.body).to eq(TEST_MESSAGE_1)
    end

    it "should successfully delete the topic" do
      expect(@delete_response).to be_ok
      expect(@delete_response.body).to eq('OK')
    end

    it "should return 404 after deleting the topic" do
      expect(@get2_response).to be_not_found
    end
  end

end
