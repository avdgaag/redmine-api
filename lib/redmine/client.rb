require 'redmine/project'
require 'redmine/issue'

module Redmine
  # The client is a Redmine-aware REST API client that maps remote resources
  # into local methods and data. It uses the RestClient under the hood and
  # outputs our own domain objects.
  class Client
    def initialize(rest_client:)
      @rest_client = rest_client
    end

    def issue(issue_id)
      data = @rest_client.get("/issues/#{issue_id}.json?include=journals").first
      Issue.new(data.fetch('issue'))
    end

    def projects
      @rest_client
        .get('/projects.json')
        .first
        .fetch('projects')
        .map { |p| Project.new(p) }
    end

    def project(id)
      @rest_client
        .get("/projects/#{id}.json?include=trackers")
        .fetch('project')
    end

    def issue_statuses
      @rest_client
        .get('/issue_statuses.json')
        .first
        .fetch('issue_statuses')
    end

    def issues(options = {}) # rubocop:disable Metrics/AbcSize
      options = { limit: 10, offset: 0, sort: :asc }.merge(options.to_h)
      Enumerator.new do |yielder|
        loop do
          result, _response = @rest_client.get(
            '/issues.json?' + URI.encode_www_form(options)
          )
          result.fetch('issues').each { |issue| yielder << Issue.new(issue) }
          position = result.fetch('limit') + result.fetch('offset')
          raise StopIteration unless result.fetch('total_count').to_i > position
          options.merge!(offset: options.fetch(:limit) + options.fetch(:offset))
        end
      end
    end
  end
end
