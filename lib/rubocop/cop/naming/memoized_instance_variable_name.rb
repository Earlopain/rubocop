# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Checks for memoized methods whose instance variable name
      # does not match the method name. Applies to both regular methods
      # (defined with `def`) and dynamic methods (defined with
      # `define_method` or `define_singleton_method`).
      #
      # This cop can be configured with the EnforcedStyleForLeadingUnderscores
      # directive. It can be configured to allow for memoized instance variables
      # prefixed with an underscore. Prefixing ivars with an underscore is a
      # convention that is used to implicitly indicate that an ivar should not
      # be set or referenced outside of the memoization method.
      #
      # @safety
      #   This cop relies on the pattern `@instance_var ||= ...`,
      #   but this is sometimes used for other purposes than memoization
      #   so this cop is considered unsafe. Also, its autocorrection is unsafe
      #   because it may conflict with instance variable names already in use.
      #
      # @example EnforcedStyleForLeadingUnderscores: disallowed (default)
      #   # bad
      #   # Method foo is memoized using an instance variable that is
      #   # not `@foo`. This can cause confusion and bugs.
      #   def foo
      #     @something ||= calculate_expensive_thing
      #   end
      #
      #   def foo
      #     return @something if defined?(@something)
      #     @something = calculate_expensive_thing
      #   end
      #
      #   # good
      #   def _foo
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @foo ||= begin
      #       calculate_expensive_thing
      #     end
      #   end
      #
      #   # good
      #   def foo
      #     helper_variable = something_we_need_to_calculate_foo
      #     @foo ||= calculate_expensive_thing(helper_variable)
      #   end
      #
      #   # good
      #   define_method(:foo) do
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   define_method(:foo) do
      #     return @foo if defined?(@foo)
      #     @foo = calculate_expensive_thing
      #   end
      #
      # @example EnforcedStyleForLeadingUnderscores: required
      #   # bad
      #   def foo
      #     @something ||= calculate_expensive_thing
      #   end
      #
      #   # bad
      #   def foo
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   def foo
      #     return @foo if defined?(@foo)
      #     @foo = calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @_foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def _foo
      #     @_foo ||= calculate_expensive_thing
      #   end
      #
      #   def foo
      #     return @_foo if defined?(@_foo)
      #     @_foo = calculate_expensive_thing
      #   end
      #
      #   # good
      #   define_method(:foo) do
      #     @_foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   define_method(:foo) do
      #     return @_foo if defined?(@_foo)
      #     @_foo = calculate_expensive_thing
      #   end
      #
      # @example EnforcedStyleForLeadingUnderscores :optional
      #   # bad
      #   def foo
      #     @something ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     @_foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def _foo
      #     @_foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   def foo
      #     return @_foo if defined?(@_foo)
      #     @_foo = calculate_expensive_thing
      #   end
      #
      #   # good
      #   define_method(:foo) do
      #     @foo ||= calculate_expensive_thing
      #   end
      #
      #   # good
      #   define_method(:foo) do
      #     @_foo ||= calculate_expensive_thing
      #   end
      class MemoizedInstanceVariableName < Base
        extend AutoCorrector

        include ConfigurableEnforcedStyle

        MSG = 'Memoized variable `%<var>s` does not match ' \
              'method name `%<method>s`. Use `@%<suggested_var>s` instead.'
        UNDERSCORE_REQUIRED = 'Memoized variable `%<var>s` does not start ' \
                              'with `_`. Use `@%<suggested_var>s` instead.'
        RESTRICT_ON_SEND = %i[define_method define_singleton_method].freeze

        # @!method memoized(node)
        def_node_matcher :memoized, <<~PATTERN
          (
            # method definition
            {
              def $_method_name                            # def foo; end
              | defs (...) $_method_name                   # def self.foo; end
              | block (send _ _ ({sym str} $_method_name)) # define_method(:foo) do; end
            } (args)
            # method body. This uses `?` instead of `{}` because of different amount of matches
            (or-asgn $(ivasgn _ ...) ...)?                          # @foo ||= :bar
            (begin !`{ivasgn ivar}+ (or-asgn $(ivasgn _ ...) ...))? # same as above with prelude
            (begin                                                  # return @foo if defined?(@foo)
              (if                                                   # @foo = bar
                (defined $(ivar _))
                (return $(ivar _)) nil?
              )
              $(ivasgn _ ...) ...
            )?
          )
        PATTERN

        def on_send(node)
          return unless parent = (node.parent)
          return unless parent.block_type?
          
          handle_ivars(parent)
        end

        def on_def(node)
          handle_ivars(node)
        end
        alias on_defs on_def

        def handle_ivars(node)
          memoized(node) do |method_name, *ivar_matches|
            next if method_name == :initialize

            ivar_matches.flatten.each do |match|
              next if matches?(method_name, match)

              suggested_var = suggested_var(method_name)
              msg = format(
                message(var_name(match)),
                var: var_name(match),
                suggested_var: suggested_var,
                method: method_name
              )
              add_offense(offense_range(match), message: msg) do |corrector|
                corrector.replace(offense_range(match), "@#{suggested_var}")
              end
            end
          end
        end

        private

        def style_parameter_name
          'EnforcedStyleForLeadingUnderscores'
        end

        def matches?(method_name, node)
          method_name = method_name.to_s.delete('!?')
          variable_name = var_name(node).to_s.sub('@', '')

          variable_name_candidates(method_name).include?(variable_name)
        end

        def var_name(match)
          if match.ivasgn_type?
            match.name.to_s
          else
            match.children[0].to_s
          end
        end

        def offense_range(match)
          if match.ivasgn_type?
            match.loc.name
          else
            match
          end
        end

        def message(variable)
          variable_name = variable.to_s.sub('@', '')

          return UNDERSCORE_REQUIRED if style == :required && !variable_name.start_with?('_')

          MSG
        end

        def suggested_var(method_name)
          suggestion = method_name.to_s.delete('!?')

          style == :required ? "_#{suggestion}" : suggestion
        end

        def variable_name_candidates(method_name)
          no_underscore = method_name.delete_prefix('_')
          with_underscore = "_#{method_name}"
          case style
          when :required
            [with_underscore,
             method_name.start_with?('_') ? method_name : nil].compact
          when :disallowed
            [method_name, no_underscore]
          when :optional
            [method_name, with_underscore, no_underscore]
          else
            raise 'Unreachable'
          end
        end
      end
    end
  end
end
