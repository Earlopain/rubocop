# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `Struct.new(..., keyword_init: true)` on Ruby >= 3.2 where it can
      # be removed. Starting from Ruby 3.2, all structs can be initialized via keyword
      # arguments by default, unless explicitly disabled.
      #
      # @safety
      #   This cop is unsafe because `keyword_init: true` also prevents initializing
      #   the struct with positional arguments. Additionally, the return value of
      #   `keyword_init?` changes from `true` to `nil`.
      #
      # @example
      #   # bad
      #   Struct.new(:foo, :bar, keyword_init: true)
      #
      #   # good
      #   Struct.new(:foo, :bar)
      #
      #   # good
      #   Struct.new(:foo, :bar, keyword_init: false)
      #
      class StructKeywordInit < Base
        extend AutoCorrector
        include RangeHelp
        extend TargetRubyVersion

        MSG = 'Remove the `keyword_init: true` argument. Keyword arguments' \
              'are accepted by default since Ruby 3.2.'

        RESTRICT_ON_SEND = %i[new].freeze

        minimum_target_ruby_version 3.2

        # @!method struct_with_hash_args?(node)
        def_node_matcher :struct_with_hash_args?, <<~PATTERN
          (send
            (const {nil? | cbase} :Struct) :new
            ...
            $(hash (pair ...)+)
          )
        PATTERN

        def on_send(node)
          struct_with_hash_args?(node) do |hash_node|
            return if hash_node.braces?

            keyword_init_args = hash_node.each_pair.select do |pair_node|
              pair_node.key.value == :keyword_init
            end

            if keyword_init_args.one? && (true_kwarg = keyword_init_args.first).value.true_type?
              add_offense(true_kwarg) do |corrector|
                with_space = range_with_surrounding_space(true_kwarg.source_range)
                corrector.remove(range_with_surrounding_comma(with_space, :left))
              end
            end
          end
        end
      end
    end
  end
end
