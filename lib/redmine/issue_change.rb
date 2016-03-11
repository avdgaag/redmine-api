require 'redmine/value'

module Redmine
  # An IssueChange is a change in the history of an Issue, such as assigning it
  # to a different user, or changing its state.
  class IssueChange < Value
    attribute :id, type: Integer
    attribute :name
    attribute :property
    attribute :old_value
    attribute :new_value

    # Provide a human-readable description of the change that this object
    # represents.
    def to_s
      format '%s: %s => %s', name, old_value, new_value
    end

    # Like #to_s, but use a given map of IDs to human-readable statuses to
    # provide more meaningful information.
    def with_statuses(issue_statuses)
      if name == 'status_id'
        format 'Status: %s => %s',
               find_issue_status(issue_statuses, old_value),
               find_issue_status(issue_statuses, new_value)
      else
        to_s
      end
    end

    private

    def find_issue_status(issue_statuses, value)
      issue_status = issue_statuses.find do |is|
        is.fetch('id').to_i == value.to_i
      end
      issue_status.fetch('name')
    end
  end
end
