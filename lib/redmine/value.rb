module Redmine
  # Base class for immutable value objects.
  #
  # Value objects with the same attributes are considered equal. Value objects
  # cannot be modified, but new values can be constructed by applying new
  # attribute values to existing values.
  class Value
    attr_reader :hash

    # List of all known attributes supported by this Value.
    def self.attributes
      @attributes ||= []
    end

    # @param [Object] value raw data to be tranformed into `type`.
    # @param [Object, #parse] type
    # @return [Object] value parsed to `type`
    def self.parse_value(value, type = nil)
      case type
      when ->(t) { t.nil? } then value
      when ->(t) { t === value } then value
      when ->(t) { t.respond_to?(:parse) } then type.parse(value)
      when ->(t) { Kernel.respond_to?(t.to_s) }
        Kernel.send(type.to_s, value)
      else raise ArgumentError, "Invalid type #{type.inspect}"
      end
    end

    # Define a new attribute for this value. Attributes can be casted
    # into a specific type, and can optionally be read from a path
    # inside a nested structure (see Rubys `dig` method).
    #
    # @param [Symbol, #to_sym] name
    # @param [Class, #parse] type conversion method or class that can be
    #   used to parse the incoming values.
    # @param [Array] path for `dig` to retrieve nested values
    # @return [nil]
    def self.attribute(name, type: nil, path: nil)
      attributes << name.to_sym
      attr_reader name

      define_method :"#{name}=" do |value|
        value = value.dig(*Array(path)) if path && value.respond_to?(:dig)
        parsed_value = self.class.parse_value(value, type)
        instance_variable_set(:"@#{name}", parsed_value)
      end

      private :"#{name}="
      nil
    end

    # @param [Hash] attrs
    def initialize(attrs = {})
      attrs.to_h.each do |name, value|
        send(:"#{name}=", value)
      end
      @hash = self.class.hash ^ to_a.hash
      freeze
    end

    # Create a new value based on the current value, but with the incoming
    # attributes assigned. This "changes" the value, but leaves the original
    # value intact -- as you'll get a new instance instead.
    #
    # @param [Hash] attrs new attributes to be merged with this value's
    #   attributes.
    # @return [Value]
    def with(attrs = {})
      self.class.new(to_h.merge(attrs))
    end

    # @return [Bool]
    def eql?(other)
      hash == other.hash
    end
    alias == eql?

    # @return [Hash]
    def to_h
      Hash[to_a]
    end

    # @return [Array]
    def to_a
      self.class.attributes.map { |attr| [attr, send(attr)] }
    end
  end
end
