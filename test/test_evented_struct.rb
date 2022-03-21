# frozen_string_literal: true

require "test_helper"

class TestEventedStruct < Minitest::Test
  def setup
    @struct = EventedStruct.new(:name)
  end

  def test_that_it_has_a_version_number
    refute_nil ::EventedStruct::VERSION
  end

  def test_it_records_events_when_created
    user = @struct.new(name: "Test")
    assert_equal "Test", user.name
    event = user.events.last
    assert_equal :add, event.type
    assert_equal({ name: "Test" }, event.payload)
  end

  def test_it_records_events_when_updated
    user = @struct.new(name: "Test")
    user.name = "New"
    event = user.events.last
    assert_equal :change, event.type
    assert_equal({ name: { from: "Test", to: "New" } }, event.payload)
  end
end
