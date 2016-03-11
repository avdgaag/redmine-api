require 'redmine/commands/issue/show'
require 'redmine/commands/issue/activity'

module Redmine
  module Commands
    # Dispatcher for issue-related subcommands.
    class Issue
      def initialize(issue_id:, redmine:)
        @issue_id = issue_id
        @redmine = redmine
      end

      def call(arguments)
        subcommand, *other_args = arguments
        command = self.class.const_get(
          subcommand.split('_').map(&:capitalize).join
        )
        command.new(issue_id: @issue_id, redmine: @redmine).call(other_args)
      end
    end
  end
end
