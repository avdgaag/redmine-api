require 'json'
require 'delegate'

module Redmine
  # A decorator object for RestClient that provides immediate JSON-parsing
  # capabilities. Rather than dealing with raw response objects, this decorator
  # helps us get at parsed JSON data immediately.
  #
  # This decorator works by intercepting outgoing requests and adding an
  # +Accept+ header to indicate we would like to receive JSON data
  # back. Responses will then be parsed, given they actually are JSON, and both
  # the parsed response body and the original response are returned.
  class AcceptJson < SimpleDelegator
    # Value of the outgoing +Accept+ header.
    ACCEPT = 'application/json'.freeze

    # Matcher for recognizing response content types.
    CONTENT_TYPE = %r{application/json}

    # Wrap requests to add an `Accept` header to ask for JSON, and parse
    # response bodies as JSON data.
    def get(path, headers = {})
      response = super(path, { 'Accept' => ACCEPT }.merge(headers.to_h))
      case response.content_type
      when CONTENT_TYPE then [parse_response(response), response]
      else raise "Unknown content type #{response.content_type.inspect}"
      end
    end

    private

    def parse_response(response)
      JSON.parse(response.body)
    rescue JSON::ParserError => e
      # TODO: log output here
      p response
      p response.to_hash
      raise e
    end
  end
end
