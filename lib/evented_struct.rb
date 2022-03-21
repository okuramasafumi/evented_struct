# frozen_string_literal: true

require_relative "evented_struct/instance_methods"
require_relative "evented_struct/version"

# EventedStruct is a simple data structure that records data manipulations
class EventedStruct
  class Error < StandardError; end

  Event = Struct.new(:type, :payload, keyword_init: true)

  # Create new EventedStruct instance
  # rubocop:disable Metrics/MethodLength
  def self.new(*attribute_names, &block)
    Class.new do |klass|
      include InstanceMethods

      klass.class_eval(&block) if block

      define_singleton_method :members do
        attribute_names
      end

      attribute_names.each do |attribute_name|
        define_method attribute_name do
          @attributes[attribute_name]
        end

        define_method "#{attribute_name}=" do |arg|
          current = @attributes[attribute_name]
          @attributes[attribute_name] = arg
          @events << Event.new(type: :change, payload: { attribute_name => { from: current, to: arg } })
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
end
