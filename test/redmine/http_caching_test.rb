require 'test_helper'
require 'support/fake_cache'
require 'support/fake_http'

module Redmine
  class HttpCachingTest < Minitest::Test
    def setup
      @http = FakeHttp.new
      @cache = FakeCache.new
      @client = HttpCaching.new(RestClient.new(http: @http), @cache)
    end

    def last_request
      @http.requests.last
    end

    def build_response(headers = {}, klass = Net::HTTPOK)
      response = klass.new('1.1', '200', 'OK')
      headers.each do |key, value|
        response[key] = value
      end
      response
    end

    def test_when_cache_is_present_it_adds_etag_header_to_request
      @cache['/path'] = build_response('Etag' => 'etag123')
      @client.get('/path')
      assert_equal 'etag123', last_request['If-None-Match']
    end

    def test_when_cache_is_present_it_does_not_replace_cache_with_not_modified_response
      response = build_response('Etag' => 'etag123')
      @cache['/path'] = response
      @client.get('/path')
      assert_equal response, @cache['/path']
    end

    def test_when_cache_is_present_it_caches_new_modified_response
      @cache['/path'] = build_response('Etag' => 'etag123')
      new_response = build_response('Etag' => 'etag123')
      @http.respond_with(new_response)
      @client.get('/path')
      assert_equal new_response, @cache['/path']
    end

    def test_caches_per_path
      @http.respond_with(build_response('Etag' => 'etag123'))
      @client.get('/path1')
      @client.get('/path1')
      @client.get('/path2')
      assert_equal 2, @cache.keys.count
    end

    def test_when_there_is_no_cache_stores_the_response
      response = build_response('Etag' => 'etag123')
      @http.respond_with(response)
      @client.get('/path')
      assert_equal response, @cache['/path']
    end

    def test_when_there_is_no_cache_adds_no_etag_header
      @client.get('/path')
      assert_equal nil, last_request['If-None-Match']
    end

    def test_when_cache_is_present_returns_cached_response_when_not_modified
      @cache['/path'] = :cached_response
      @http.respond_with build_response({}, Net::HTTPNotModified)
      assert_equal :cached_response, @client.get('/path')
    end

    def test_when_cache_is_present_returns_response_when_it_is_modified
      @cache['/path'] = :cached_response
      new_response = build_response
      @http.respond_with(new_response)
      assert_equal new_response, @client.get('/path')
    end

    def test_does_not_cache_when_there_is_no_caching_header_in_the_response
      @http.respond_with(build_response)
      @client.get('/path')
      assert_equal nil, @cache['/path']
    end
  end
end
