require 'time'
require 'redmine/value'
require 'redmine/issue_change'

module Redmine
  # An IssueEvent is a set of changes by a user to an Issue in the system,
  # optionally with some notes. A user might change several properties of a
  # ticket at once, as represented by IssueChange.
  class IssueEvent < Value
    attribute :id, type: Integer
    attribute :user, path: 'name'
    attribute :notes
    attribute :created_on, type: DateTime
    attribute :details, type: Array

    # List of all changes introduced by this event as IssueChange objects.
    def issue_changes
      @details.map do |change|
        IssueChange.new(change)
      end
    end
  end
end
