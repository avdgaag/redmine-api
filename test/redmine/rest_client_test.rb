require 'test_helper'

module Redmine
  class RestClientTest < Minitest::Test
    def test_sends_request_using_given_http_client
      http = Minitest::Mock.new
      http.expect :request, :response, [Net::HTTP::Get]
      RestClient.new(http: http).get('/path')
      http.verify
    end

    def test_returns_the_http_client_response
      http = Net::HTTP.new('example.com', 80)
      http.stub :request, :response do
        rest_client = RestClient.new(http: http)
        assert_equal :response, rest_client.get('/foo')
      end
    end

    def test_includes_default_headers_in_requests
      http = Minitest::Mock.new
      http.expect :request, :response, [->(request) { request['foo'] == 'bar' }]
      RestClient.new(default_headers: { 'foo' => 'bar' }, http: http).get('/path')
      http.verify
    end
  end
end
