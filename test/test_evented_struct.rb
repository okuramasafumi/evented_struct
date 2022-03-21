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

  def test_it_allows_to_publish_and_subscribe_events_with_specified_type_and_key
    store = []
    struct = EventedStruct.new(:foo, :bar)
    struct.subscribe(type: :change, key: :foo) do |_key, _type, payload|
      store << payload
    end
    data = struct.new(foo: "Foo", bar: 42)
    data.foo = "FOO!" # This should be subscribed
    data.bar = 1 # This should NOT be subscribed
    assert_equal [{ foo: { from: "Foo", to: "FOO!" } }], store
  end

  def test_it_allows_to_publish_and_subscribe_events_with_all_key_and_type
    store = []
    struct = EventedStruct.new(:foo, :bar)
    struct.subscribe do |key, type, _payload|
      store << [key, type]
    end
    data = struct.new(foo: "Foo", bar: 42)
    data.foo = "FOO!" # This should be subscribed
    data.bar = 1 # This should be subscribed
    assert_equal [[:foo, :add], [:bar, :add], [:foo, :change], [:bar, :change]], store
  end

  def test_it_allows_to_reset_subscription
    store = []
    struct = EventedStruct.new(:foo, :bar)
    struct.subscribe(type: :change, key: :foo) do |_key, _type, payload|
      store << payload
    end
    struct.reset_subscription!
    data = struct.new(foo: "Foo", bar: 42)
    data.foo = "FOO!"
    data.bar = 1
    assert_empty store
  end
end
