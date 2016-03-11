require 'pstore'
require 'uri'

require 'redmine/configuration'
require 'redmine/cli'
require 'redmine/client'
require 'redmine/accept_json'
require 'redmine/http_caching'
require 'redmine/rest_client'

# = Redmine command line API
#
# This gem provides a command-line API to the popular Redmine issue tracking
# system, using its REST API.
module Redmine
  module_function

  def configuration
    @configuration ||= Configuration.autoload
  end

  def configure
    @configuration = Configuration.autoload
    yield @configuration
    @configuration.freeze
  end

  def cli(args)
    cache = PStore.new(configuration.http_cache)
    base_uri = URI.parse(configuration.base_uri)
    rest_client = RestClient.new(
      base_uri: base_uri,
      default_headers: {
        'X-Redmine-Api-Key' => configuration.api_token
      }
    )
    rest_client = AcceptJson.new(HttpCaching.new(rest_client, cache))
    Cli.new(
      redmine_client: Client.new(rest_client: rest_client)
    ).call(args)
  end
end
