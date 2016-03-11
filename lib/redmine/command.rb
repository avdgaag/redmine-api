require 'optparse'

module Redmine
  # The Command mixin helps define command objects used in the command line
  # interface.  Classes can mix in this behaviour to make it easier to take
  # command line arguments, parse them and use the resulting options in the
  # command execution.
  #
  # Usage example:
  #
  #   class MyCommand
  #     extend Command
  #
  #     usage 'greet [OPTIONS]' do |o|
  #       o.on '-n', '--name', 'Provide the name to be used' do |name|
  #         options[:name] = name
  #       end
  #     end
  #
  #     def call(arguments)
  #       puts "Hello, #{options[:name]}!"
  #     end
  #   end
  module Command
    def self.extended(base) # :nodoc:
      base.send(:prepend, InstanceMethods)
    end

    # Define the command line options available to this command. This is a
    # wrapper around Ruby's own +OptionParser+. Options defined here will be
    # parsed out of incoming arguments, and what remains will be passed to
    # #call. Within this block, you have access to an +options+ hash that
    # is also available in the #call method.
    def usage(description, &block)
      @usage_description = description
      @usage_options = block
    end

    # Get the usage description set with #usage.
    def usage_description
      @usage_description ||= ''
    end

    # Get the +OptionParser+ definition block set with #usage.
    def usage_options
      @usage_options ||= ->(opts) {}
    end

    # Special instance methods for Command objects that define a common
    # interface:
    #
    # * #options can hold options parsed from command-line switches
    # * #call can be invoked to run the command.
    module InstanceMethods
      # An generic +options+ hash that can be used to store preferences in from
      # command line options, available in both the #usage block and the #call
      # method.
      def options
        @otions ||= {}
      end

      # Override #call to provide your custom logic for a command object. The
      # #call in this module will be prepended to #call in your own objects,
      # ensuring that when invoked, all options will first be parsed. All
      # non-recognized options will be passed as-is to the original #call
      # method.
      def call(arguments)
        OptionParser.new do |o|
          o.banner = 'Usage: ' + self.class.usage_description
          o.separator ''
          instance_exec o, &self.class.usage_options
          o.on_tail '-h', '--help', 'Show this message' do
            puts o
            exit
          end
        end.parse!(arguments)
        super(arguments)
      end
    end
  end
end
