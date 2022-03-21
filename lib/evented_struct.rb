# frozen_string_literal: true

require_relative "evented_struct/instance_methods"
require_relative "evented_struct/subscription"
require_relative "evented_struct/version"

# EventedStruct is a simple data structure that records data manipulations
class EventedStruct
  class Error < StandardError; end

  Event = Struct.new(:key, :type, :payload, keyword_init: true)

  # Create new EventedStruct instance
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def self.new(*attribute_names, &block)
    Class.new do |klass|
      @subscriptions = []

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
          event = Event.new(key: attribute_name,
                            type: :change,
                            payload: { attribute_name => { from: current, to: arg } })
          @events << event
          self.class.subscriptions.each do |subscription|
            subscription.publish_if_match(event)
          end
        end
      end

      class << self
        attr_reader :subscriptions

        def subscribe(key: nil, type: :all, &block)
          key = members if key.nil?

          @subscriptions << Subscription.new(keys: Array(key), type: type, &block)
        end

        def reset_subscription!
          @subscriptions = []
        end
      end
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
