require 'delegate'

module Redmine
  # A decorator object for RestClient that adds caching capabilities to regular
  # RestClient objects. It wraps normal request methods and uses the +Etag+ and
  # +If-None-Match+ headers to locally store responses. On subsequent requests
  # for the same resource, we can skip downloading the entire body when the
  # server indicates nothing has changed (Not Modified).
  #
  # A cache is used to keep track of responses. This is assumed to support the
  # +Pstore+ interface, responding to +#transaction+, +#[]+ and +#[]=+ methods.
  #
  # Usage example:
  #
  #   require 'pstore'
  #   cache = PStore.new('cache.pstore')
  #   rest_client = RestClient.new
  #   caching_rest_client = HttpCaching.new(rest_client, cache)
  #   caching_rest_client.get('/path')
  class HttpCaching < SimpleDelegator
    def initialize(http, cache)
      @cache = cache
      super(http)
    end

    # Wrap RestClient#get to provide HTTP caching.
    #
    # New requests are stored in a cache if they have an +Etag+ header. On
    # subsequent requests to the same resource, a +If-None-Match+ header is sent
    # along, using the original Etag value. The server can then indicate that
    # nothing has changed, which will trigger this decorator to return the
    # cached response -- rather than downloading a whole new copy of the same
    # data.
    def get(path, headers = {})
      cached_response = fetch_cached_response(path)
      if cached_response
        headers = headers.merge 'If-None-Match' => cached_response['Etag']
      end
      response = super(path, headers)
      case response
      when Net::HTTPNotModified then cached_response
      else
        cache_response(path, response)
        response
      end
    end

    private

    def fetch_cached_response(path)
      @cache.transaction do
        @cache[URI(path).path]
      end
    end

    def cache_response(path, response)
      return unless response['Etag']
      @cache.transaction do
        @cache[path] = response
      end
    end
  end
end
