require 'ostruct'
require 'pathname'
require 'yaml'

module Redmine
  # Container for library-level configuration, acting like an OpenStruct.
  class Configuration < OpenStruct
    # Filename of configuration files to look for.
    CONFIG_FILENAME = '.redmine.yml'.freeze

    # Load configuration from special YAML config files on disk, looking into
    # the current directory and upwards, merging all together.
    def self.autoload
      new(Pathname
        .pwd
        .ascend
        .lazy
        .map { |p| p.join(CONFIG_FILENAME) }
        .select(&:exist?)
        .map { |p| YAML.load_file(p) }
        .to_a
        .reverse
        .inject(:merge)
         )
    end
  end
end
