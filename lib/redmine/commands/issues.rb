require 'redmine/command'

module Redmine
  module Commands
    # Command to list issues from Redmine.
    class Issues
      extend Command

      # rubocop:disable Metrics/LineLength
      usage 'redmine issues [options]' do |op|
        op.on '--mine', 'Limit results to issues assigned to me' do
          options[:assigned_to_id] = 'me'
        end

        op.on '-p', '--project ID', Integer, 'Limit results to the given project' do |id|
          options[:project_id] = id
        end

        op.on '-s', '--status STATUS', %i(open closed), 'Show only open or closed issues', '(open, closed)' do |status|
          options[:status_id] = status
        end

        op.on '-o', '--offset N', Integer, 'Skip the first N issues' do |n|
          options[:offset] = n
        end

        op.on '-l', '--limit N', Integer, 'Limit the total number of issues' do |_n|
          options[:total]
        end
      end

      def initialize(redmine:)
        @redmine = redmine
      end

      def call(_args)
        total = options.delete(:total) || 10
        @redmine.issues(options).first(total).each do |issue|
          puts "#{issue.id} #{issue.subject}"
        end
      end
    end
  end
end
