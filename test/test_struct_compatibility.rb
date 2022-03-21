# frozen_string_literal: true

require "test_helper"

class TestEventedStruct < Minitest::Test
  def setup
    @struct = EventedStruct.new(:name)
  end

  def test_it_behaves_like_struct_with_block
    user = EventedStruct.new(:id, :name) { # rubocop:disable Style/BlockDelimiters
      def id_and_name # rubocop:disable Lint/NestedMethodDefinition
        "Id: #{id}, Name: #{name}"
      end
    }
    u = user.new(id: 1, name: "Foo")
    assert_equal "Id: 1, Name: Foo", u.id_and_name
  end

  def test_it_behaves_like_struct_with_members
    assert_equal [:name], @struct.members
    user = @struct.new(name: "Test")
    assert_equal [:name], user.members
  end

  def test_it_behaves_like_struct_with_bracket
    user = @struct.new(name: "Test")
    assert_equal "Test", user[:name]
    assert_equal "Test", user[0]
    user[:name] = "Test!!!"
    assert_equal "Test!!!", user[:name]
  end

  def test_it_behaves_like_struct_with_length_and_size
    user = @struct.new(name: "Test")
    assert_equal 1, user.length
    assert_equal 1, user.size
  end

  def test_it_behaves_like_struct_with_equality
    user1 = @struct.new(name: "Test")
    user2 = @struct.new(name: "Test")
    assert_equal user1, user2
    user3 = @struct.new(name: "Test!")
    refute_equal user1, user3
  end

  def test_it_behaves_like_struct_with_values_and_deconstruct_and_to_a
    user = @struct.new(name: "Test")
    assert_equal ["Test"], user.values
    assert_equal ["Test"], user.deconstruct
    assert_equal ["Test"], user.to_a
  end

  def test_it_behaves_like_struct_with_deconstruct_keys
    another_struct = EventedStruct.new(:foo, :bar)
    s = another_struct.new(foo: "Foo", bar: 42)
    assert_equal({ foo: "Foo" }, s.deconstruct_keys([:foo]))
    assert_equal({ foo: "Foo", bar: 42 }, s.deconstruct_keys(nil))
  end

  def test_it_behaves_like_struct_with_select_and_filter
    another_struct = EventedStruct.new(:foo, :bar)
    s = another_struct.new(foo: "Foo", bar: 42)
    assert_equal(["Foo"], s.filter { |value| value.is_a?(String) })
    assert_equal([42], s.select { |value| value.is_a?(Integer) })
    enum = s.filter
    assert_equal(["Foo"], enum.filter { |value| value.is_a?(String) })
  end

  def test_it_behaves_like_struct_with_values_at
    another_struct = EventedStruct.new(:foo, :bar)
    s = another_struct.new(foo: "Foo", bar: 42)
    assert_equal ["Foo", 42], s.values_at(0, 1)
    assert_equal ["Foo", 42], s.values_at(0..1)
    assert_equal %w[Foo Foo], s.values_at(0, -2)
  end

  # rubocop:disable Style/SingleArgumentDig
  def test_it_behaves_like_struct_with_dig
    foo = EventedStruct.new(:a)
    f = foo.new(a: foo.new(a: { b: [1, 2, 3] }))
    assert_equal({ a: { b: [1, 2, 3] } }, f.dig(:a).to_h)
    assert_equal({ b: [1, 2, 3] }, f.dig(:a, :a).to_h)
    assert_equal({ b: [1, 2, 3] }, f.dig(0, 0).to_h)
  end
  # rubocop:enable Style/SingleArgumentDig
end
