require 'redmine/accept_json'
require 'redmine/http_caching'
require 'net/http'

module Redmine
  # Simple REST-aware HTTP client that uses +Net::HTTP+ under the hood to make
  # external requests. Most of its functionality comes from decorators, such as
  # AcceptJson and HttpCaching.
  class RestClient
    # Initialize a new RestClient using default headers to be included in all
    # requests, and optionally a customized HTTP client. If not providing a
    # custom +http+ option, you can provide a +base_uri+ that will be used to
    # create a new Net::HTTP instance.
    def initialize(
      default_headers: {},
      base_uri: nil,
      http: Net::HTTP.new(base_uri.host, base_uri.port)
    )
      @http = http
      @default_headers = default_headers
    end

    # Perform a GET requests to a given path, optionally with additional
    # headers. Returns raw Net::HTTPResponse objects.
    def get(path, headers = {})
      request = Net::HTTP::Get.new(path)
      @default_headers.merge(headers).each do |key, value|
        request[key] = value
      end
      @http.request(request)
    end
  end
end
