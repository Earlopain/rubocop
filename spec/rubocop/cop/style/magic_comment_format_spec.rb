# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MagicCommentFormat, :config do
  subject(:cop_config) do
    {
      'EnforcedStyle' => enforced_style,
      'DirectiveCapitalization' => directive_capitalization,
      'ValueCapitalization' => value_capitalization
    }
  end

  let(:enforced_style) { 'snake_case' }
  let(:directive_capitalization) { nil }
  let(:value_capitalization) { nil }

  context 'snake case style' do
    let(:enforced_style) { 'snake_case' }

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for mixed case' do
      expect_offense(<<~RUBY)
        # frozen-string_literal: true
          ^^^^^^^^^^^^^^^^^^^^^ Prefer snake case for magic comments.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
    end

    it 'does not register an offense for dashes in other comments' do
      expect_no_offenses('# foo-bar-baz ')
    end

    it 'does not register an offense for incorrect style in comments after the first statement' do
      expect_no_offenses(<<~RUBY)
        puts 1
        # frozen-string-literal: true
      RUBY
    end
  end

  context 'kebab case style' do
    let(:enforced_style) { 'kebab_case' }

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for mixed case' do
      expect_offense(<<~RUBY)
        # frozen-string_literal: true
          ^^^^^^^^^^^^^^^^^^^^^ Prefer kebab case for magic comments.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen-string-literal: true

        puts 1
      RUBY
    end

    it 'does not register an offense for dashes in other comments' do
      expect_no_offenses('# foo-bar-baz ')
    end

    it 'does not register an offense for incorrect style in comments after the first statement' do
      expect_no_offenses(<<~RUBY)
        puts 1
        # frozen-_string_literal: true
      RUBY
    end
  end

  context 'all issues at once' do
    let(:enforced_style) { 'snake_case' }
    let(:directive_capitalization) { 'uppercase' }
    let(:value_capitalization) { 'lowercase' }

    it 'registers and corrects multiple issues' do
      expect_offense(<<~RUBY)
        # frozen-STRING-literal: TRUE
                                 ^^^^ Prefer lowercase for magic comment values.
          ^^^^^^^^^^^^^^^^^^^^^ Prefer upper snake case for magic comments.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # FROZEN_STRING_LITERAL: true
        puts 1
      RUBY
    end
  end
end
