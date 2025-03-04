# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StructKeywordInit, :config do
  context 'Ruby <= 3.1', :ruby31, unsupported_on: :prism do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: true)
      RUBY
    end
  end

  context 'Ruby >= 3.2', :ruby32 do
    it 'registers an offense when using using `keyword_init: true`' do
      expect_offense(<<~RUBY)
        Struct.new(:foo, keyword_init: true)
                         ^^^^^^^^^^^^^^^^^^ Remove the `keyword_init: true` argument. [...]
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'registers an offense when using using `keyword_init: true` with constant base' do
      expect_offense(<<~RUBY)
        ::Struct.new(:foo, keyword_init: true)
                           ^^^^^^^^^^^^^^^^^^ Remove the `keyword_init: true` argument. [...]
      RUBY
    end

    it 'registers an offense when using using `keyword_init: true` and class name is given' do
      expect_offense(<<~RUBY)
        Struct.new('MyStruct', :foo, keyword_init: true)
                                     ^^^^^^^^^^^^^^^^^^ Remove the `keyword_init: true` argument. [...]
      RUBY
    end

    it 'registers an offense when using using `keyword_init: true` and members are splatted' do
      expect_offense(<<~RUBY)
        Struct.new(*members, keyword_init: true)
                             ^^^^^^^^^^^^^^^^^^ Remove the `keyword_init: true` argument. [...]
      RUBY
    end

    it 'registers no offense when using using `keyword_init: false`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: false)
      RUBY
    end

    it 'registers no offense when `keyword_init` is repeated' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, keyword_init: true, keyword_init: false)
      RUBY
    end

    it 'registers no offense when omitting `keyword_init`' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo)
      RUBY
    end

    it 'registers no offense for namespaced constant' do
      expect_no_offenses(<<~RUBY)
        Foo::Struct.new(:foo)
      RUBY
    end

    it 'registers no offense for non-keyword argument hash' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, { keyword_init: true })
      RUBY
    end

    it 'registers no offense for splatted keyword arguments' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:foo, **bar)
      RUBY
    end
  end
end
