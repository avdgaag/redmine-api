require 'redmine/command'
require 'json'
require 'csv'

module Redmine
  module Commands
    # Command to calculate lead times for one or more tickets in Redmine.
    class LeadTimes
      extend Command

      def initialize(redmine:)
        @redmine = redmine
      end

      # rubocop:disable Metrics/LineLength
      usage 'redmine lead_times [OPTIONS] [ISSUE_ID...]' do |o|
        o.on '-f', '--format FORMAT', %w(text csv json), 'Output format to use', '(text, csv, json)' do |format|
          options[:format] = format
        end
      end

      def call(arguments)
        case options[:format]
        when 'json' then generate_json(arguments)
        when 'csv' then generate_csv(arguments)
        when 'text' then generate_text(arguments)
        else raise ArgumentError, "Unknown format #{options[:format].inspect}"
        end
      end

      private

      def generate_json(arguments)
        lead_times = to_enum(:each_issue_lead_time, arguments).inject({}) do |output, (issue_id, lead_time)|
          output.merge issue_id => lead_time
        end
        puts JSON.dump(lead_times)
      end

      def generate_csv(arguments)
        csv_output = CSV.generate do |csv|
          each_issue_lead_time(arguments) do |issue_id, lead_time|
            csv << [issue_id, lead_time]
          end
        end
        puts csv_output
      end

      def generate_text
        each_issue_lead_time(arguments) do |issue_id, lead_time|
          puts "#{issue_id}\t#{lead_time}"
        end
      end

      def each_issue_lead_time(ids)
        ids.each do |id|
          yield id, @redmine.issue(id).lead_time
        end
      end
    end
  end
end
