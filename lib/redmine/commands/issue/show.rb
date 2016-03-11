require 'redmine/command'

module Redmine
  module Commands
    class Issue
      # Sub-subcommand to show general information about a given issue.
      class Show
        extend Command

        usage 'redmine [ISSUE] show'

        def initialize(issue_id:, redmine:)
          @issue_id = issue_id
          @redmine = redmine
        end

        def call(_args)
          issue = @redmine.issue(@issue_id)
          puts "#{issue.tracker} #{issue.id} " \
            "(#{issue.status}): #{issue.subject}"
          puts "Author: #{issue.author}"
          puts "Assigned to: #{issue.assigned_to}"
          puts "\n#{issue.description}"
        end
      end
    end
  end
end
