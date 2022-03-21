# frozen_string_literal: true

class EventedStruct
  # Simple data holder for `subscribe` method
  # It encapsulates event matching and publishing
  class Subscription
    def initialize(keys:, type:, &block)
      @keys = keys
      @type = type
      @block = block
    end

    def publish_if_match(event)
      if @keys.include?(event.key) && (@type == event.type || @type == :all) # rubocop:disable Style/GuardClause
        @block.call(event.key, event.type, event.payload)
      end
    end
  end
end
