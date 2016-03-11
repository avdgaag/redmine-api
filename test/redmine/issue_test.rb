require 'test_helper'

module Redmine
  class IssueTest < Minitest::Test
    parallelize_me!

    def test_calculates_lead_time
      issue = Issue.new(
        closed_on: '2016-01-31',
        start_date: '2016-01-01',
        created_on: '2016-01-01'
      )
      assert_equal 30, issue.lead_time
    end

    def test_when_issue_is_copied_it_uses_creation_time_if_more_recent
      issue = Issue.new(
        closed_on: '2016-01-31',
        start_date: '2016-01-01',
        created_on: '2016-01-02'
      )
      assert_equal 29, issue.lead_time
    end

    def test_has_infinite_time_when_not_closed
      issue = Issue.new(
        start_date: '2016-01-01'
      )
      assert_equal Float::INFINITY, issue.lead_time
    end
  end
end
