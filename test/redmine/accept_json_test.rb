require 'test_helper'

module Redmine
  class AcceptJsonTest < Minitest::Test
    def setup
      @response = Net::HTTPOK.new '1.1', '200', 'OK'
      def @response.body # rubocop:disable Lint/NestedMethodDefinition
        '{"foo": "bar"}'
      end
      @response['Content-Type'] = 'application/json'
      @output = { 'foo' => 'bar' }
    end

    def test_adds_json_accept_header_to_outgoing_requests
      tester = ->(request) { request['Accept'] == 'application/json' }
      http = Minitest::Mock.new
      http.expect :request, @response, [tester]
      AcceptJson.new(RestClient.new(http: http)).get('/path')
      http.verify
    end

    def test_parses_request_body_as_json
      http = Net::HTTP.new('example.com', 80)
      http.stub :request, @response do
        json_rest_client = AcceptJson.new(RestClient.new(http: http))
        assert_equal [@output, @response], json_rest_client.get('/foo')
      end
    end
  end
end
