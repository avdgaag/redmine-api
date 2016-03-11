require 'redmine/command'

module Redmine
  module Commands
    # Command to list projects in Redmine.
    class Projects
      extend Command

      def initialize(redmine:)
        @redmine = redmine
      end

      def call(_arguments)
        @redmine.projects.each do |project|
          puts "#{project.id} #{project.name}"
        end
      end
    end
  end
end
