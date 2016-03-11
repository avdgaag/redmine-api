require 'time'
require 'redmine/value'
require 'redmine/issue_event'

module Redmine
  # Represents a single issue (ticket) in the Redmine system.
  class Issue < Value
    attribute :id, type: Integer
    attribute :subject
    attribute :description
    attribute :done_ratio, type: Integer
    attribute :start_date, type: DateTime
    attribute :created_on, type: DateTime
    attribute :updated_on, type: DateTime
    attribute :closed_on, type: DateTime
    attribute :project, path: 'name'
    attribute :tracker, path: 'name'
    attribute :status, path: 'name'
    attribute :priority, path: 'name'
    attribute :author, path: 'name'
    attribute :assigned_to, path: 'name'
    attribute :fixed_version, path: 'name'
    attribute :journals, type: Array
    attribute :spent_hours, type: Integer

    # List event history for this Issue as IssueEvent objects.
    def activity
      journals.map do |event|
        IssueEvent.new(event)
      end
    end

    # Calculate the lead time for this ticket.
    #
    # This returns the difference in days between the closed date and the start
    # date.
    def lead_time
      return Float::INFINITY unless closed_on
      (closed_on - [created_on, start_date].max).to_i
    end
  end
end
