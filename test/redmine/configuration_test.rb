require 'test_helper'

module Redmine
  class ConfigurationTest < Minitest::Test
    def test_works_like_an_openstruct
      config = Configuration.new
      config.foo = 'bar'
      assert_equal 'bar', config.foo
    end

    def in_tmpdir_with_config(options, dir = nil)
      Dir.mktmpdir(nil, dir) do |dirname|
        Dir.chdir(dirname) do
          File.write('.redmine.yml', YAML.dump(options))
          yield dirname
        end
      end
    end

    def test_autoload_will_parse_yaml_config_files_and_merge_them
      in_tmpdir_with_config(foo: 'bar', baz: 'bla') do |dir1|
        in_tmpdir_with_config({ foo: 'baz', bla: 'qux' }, dir1) do
          output = {
            foo: 'baz',
            baz: 'bla',
            bla: 'qux'
          }
          assert_equal output, Configuration.autoload.to_h
        end
      end
    end
  end
end
