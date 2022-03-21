# frozen_string_literal: true

class EventedStruct
  # Module containing methods extracted from EventedStruct
  # Most methods are compatible with Struct class
  module InstanceMethods
    attr_reader :events

    def initialize(attributes = {})
      super()
      @attributes = attributes.to_h
      @events = @attributes.each_with_object([]) do |(k, v), array|
        array << Event.new(type: :add, payload: { k => v })
      end
    end

    def members
      @attributes.keys
    end

    def [](key)
      case key
      when String, Symbol
        @attributes[key]
      when Integer
        to_a[key]
      end
    end

    def []=(key, value)
      @events << Event.new(type: :change, payload: { key.to_sym => { from: self[key], to: value } })
      @attributes[key] = value
    end

    def each_pair
      members.each do |key|
        yield(key, self[key])
      end
    end

    def ==(other)
      return false unless self.class == other.class

      each_pair do |key, value|
        return false if value != other[key]
      end

      true
    end
    alias eql? ==

    def length
      @attributes.size
    end
    alias size length

    def values
      @attributes.values
    end
    alias deconstruct values
    alias to_a values

    def values_at(*integers)
      values.values_at(*integers)
    end

    def to_h
      @attributes
    end

    def filter(&block)
      if block
        @attributes.each_with_object([]) do |(_k, v), array|
          array << v if yield(v)
        end
      else
        to_enum(:filter)
      end
    end
    alias select filter

    def deconstruct_keys(keys)
      return to_h if keys.nil?

      @attributes.slice(*keys)
    end

    def dig(name, *identifiers)
      case name
      when Symbol, String
        to_h.dig(name, *identifiers)
      when Integer
        item = self[name]
        n = identifiers.shift
        n ? item.dig(n, *identifiers) : item
      end
    end
  end
end
