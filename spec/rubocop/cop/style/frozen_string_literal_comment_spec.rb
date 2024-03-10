# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FrozenStringLiteralComment, :config do
  context 'always' do
    let(:cop_config) { { 'Enabled' => true, 'EnforcedStyle' => 'always' } }

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'accepts a frozen string literal on the top line' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal on the top line' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for arbitrary tokens' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: token
        ^ Missing frozen string literal comment.
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment on the top line' do
      expect_offense(<<~RUBY)
        puts 1
        ^ Missing frozen string literal comment.
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment under a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'when there is only a shebang' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing frozen string literal comment.
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
      RUBY
    end

    it 'accepts a frozen string literal below a shebang comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a disabled frozen string literal below a shebang comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        puts 1
      RUBY
    end

    it 'registers an offense for an extra first empty line' do
      expect_offense(<<~RUBY)

        ^{} Missing frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
    end
  end

  context 'never' do
    let(:cop_config) { { 'Enabled' => true, 'EnforcedStyle' => 'never' } }

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'registers an offense for a frozen string literal comment on the top line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal comment on the top line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        puts 1
      RUBY
    end

    it 'accepts not having a frozen string literal comment on the top line' do
      expect_no_offenses('puts 1')
    end

    it 'accepts not having not having a frozen string literal comment under a shebang' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        puts 1
      RUBY
    end

    it 'registers an offense for a frozen string literal comment below a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal below a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary frozen string literal comment.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        puts 1
      RUBY
    end
  end

  context 'always_true' do
    let(:cop_config) { { 'Enabled' => true, 'EnforcedStyle' => 'always_true' } }

    it 'accepts an empty source' do
      expect_no_offenses('')
    end

    it 'accepts a source with no tokens' do
      expect_no_offenses(' ')
    end

    it 'accepts a frozen string literal on the top line' do
      expect_no_offenses(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal on the top line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for arbitrary tokens' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: token
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment on the top line' do
      expect_offense(<<~RUBY)
        puts 1
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for an extra first empty line' do
      expect_offense(<<~RUBY)

        ^{} Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal above an empty line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
    end

    it 'registers an offense for arbitrary tokens above an empty line' do
      expect_offense(<<~RUBY)
        # frozen_string_literal: token
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.

        puts 1
      RUBY

      expect_correction(<<~RUBY)
        # frozen_string_literal: true

        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'accepts a frozen string literal below a shebang comment' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal below a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for arbitrary tokens below a shebang comment' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: token
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
        puts 1
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
        puts 1
      RUBY
    end

    it 'registers an offense for not having a frozen string literal comment ' \
       'under shebang with no other code' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        ^ Missing magic comment `# frozen_string_literal: true`.
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
      RUBY
    end

    it 'accepts a frozen string literal comment under shebang with no other code' do
      expect_no_offenses(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
      RUBY
    end

    it 'registers an offense for a disabled frozen string literal comment ' \
       'under shebang with no other code' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
      RUBY
    end

    it 'registers an offense for arbitrary tokens under shebang with no other code' do
      expect_offense(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: tokens
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Frozen string literal comment must be set to `true`.
      RUBY

      expect_correction(<<~RUBY)
        #!/usr/bin/env ruby
        # frozen_string_literal: true
      RUBY
    end
  end

  context 'target_ruby_version < 2.3', :ruby22, unsupported_on: :prism do
    it 'accepts freezing a string' do
      expect_no_offenses('"x".freeze')
    end

    it 'accepts calling << on a string' do
      expect_no_offenses('"x" << "y"')
    end

    it 'accepts freezing a string with interpolation' do
      expect_no_offenses('"#{foo}bar".freeze')
    end

    it 'accepts calling << on a string with interpolation' do
      expect_no_offenses('"#{foo}bar" << "baz"')
    end
  end
end
