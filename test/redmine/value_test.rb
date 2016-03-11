require 'test_helper'
require 'time'

module Redmine
  class ValueTest < Minitest::Test
    parallelize_me!
    make_my_diffs_pretty!

    class Point < Value
      attribute :x, type: Integer
      attribute :y
      attribute :created, type: DateTime, path: 'date'
    end

    def setup
      @point = Point.new(x: '1', y: 2, created: { 'date' => '2016-01-01 12:00' })
    end

    def test_objects_are_frozen
      assert @point.frozen?
    end

    def test_values_can_be_used_as_unique_hash_keys
      hsh = { @point => true }
      hsh[@point.with({})] = false
      assert_equal 1, hsh.keys.size
      assert_equal false, hsh[@point]
    end

    def test_creates_new_objects_with_changes_applied
      point2 = @point.with(x: 3, y: 4)
      assert_equal 1, @point.x
      assert_equal 3, point2.x
    end

    def test_does_not_alter_incoming_values_without_a_type
      assert_equal 'bla', @point.with(y: 'bla').y
    end

    def test_uses_kernel_conversion_functions_to_parse_values
      assert_equal 1, @point.x
    end

    def test_will_not_parse_values_of_correct_type
      created = DateTime.new(2016, 2, 1, 11)
      assert_equal created, @point.with(created: created).created
    end

    def test_uses_class_parse_method_to_parse_values
      assert_equal DateTime.new(2016, 1, 1, 12), @point.created
    end

    def test_raises_when_value_has_invalid_type
      assert_raises ArgumentError, 'Invalid type Redmine' do
        Redmine::Value.parse_value(1, Redmine)
      end
    end

    def test_has_reader_methods_for_attributes
      assert_equal 1, @point.x
      assert_equal 2, @point.y
    end

    def test_considers_two_values_with_same_attributes_equal
      point = Point.new(x: 1, y: 2, created: { 'date' => '2016-01-01 12:00' })
      assert_equal point, @point
    end

    def test_can_be_converted_to_a_hash
      hsh = {
        x: 1,
        y: 2,
        created: DateTime.new(2016, 1, 1, 12)
      }
      assert_equal hsh, @point.to_h
    end

    def test_can_be_converted_to_an_array
      arr = [
        [:x, 1],
        [:y, 2],
        [:created, DateTime.new(2016, 1, 1, 12)]
      ]
      assert_equal arr, @point.to_a
    end

    def test_raises_when_assigning_unknown_attributes
      assert_raises NoMethodError do
        Point.new(foo: 'bar')
      end
    end
  end
end
