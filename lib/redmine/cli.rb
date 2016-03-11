require 'redmine/issue'
require 'redmine/commands'

module Redmine
  # Command line interface dispatcher: invoke subcommands based on incoming
  # command line switches.
  class Cli
    def initialize(redmine_client:)
      @redmine = redmine_client
    end

    def call(arguments)
      subcommand, *other_args = arguments
      if subcommand =~ /^\d+$/
        call_issue_command(subcommand, other_args)
      elsif subcommand =~ /^\w/
        call_subcommand(subcommand, other_args)
      else
        option_parser.parse(arguments)
      end
    end

    private

    def call_subcommand(cmd, args)
      command_name_to_class(cmd).new(redmine: @redmine).call(args)
    end

    def command_name_to_class(cmd)
      Commands.const_get(cmd.split('_').map(&:capitalize).join)
    end

    def call_issue_command(cmd, args)
      Commands::Issue.new(issue_id: cmd, redmine: @redmine).call(args)
    end

    def option_parser # rubocop:disable Metrics/MethodLength
      OptionParser.new do |o|
        o.banner = <<~EOS
        redmine [SUBCOMMAND] [OPTIONS]

        Perform common operations in a Redmine issue tracker from the command
        line.

        Available subcommands:

        projects
        issues
        show
        activity
        lead_times

        Generic options:
        EOS
        o.separator ''
        o.on_tail '-h', '--help', 'Show this message' do
          puts o
          exit
        end
        o.on_tail '-v', '--version', 'Display version number' do
          puts Redmine::VERSION
          exit
        end
      end
    end
  end
end
