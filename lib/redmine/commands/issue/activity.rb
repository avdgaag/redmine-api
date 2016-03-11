require 'redmine/command'

module Redmine
  module Commands
    class Issue
      # Sub-subcommand to show activity (comments, changes) on a given issue.
      class Activity
        extend Command

        usage 'redmine [ISSUE] activity'

        def initialize(issue_id:, redmine:)
          @issue_id = issue_id
          @redmine = redmine
        end

        def call(_args)
          issue_statuses = @redmine.issue_statuses
          issue = @redmine.issue(@issue_id)
          issue.activity.each do |event|
            puts "* #{event.user} on #{event.created_on}"
            event.issue_changes.each do |change|
              puts "  #{change.with_statuses(issue_statuses)}"
            end
            puts "  #{event.notes}"
            puts
          end
        end
      end
    end
  end
end
