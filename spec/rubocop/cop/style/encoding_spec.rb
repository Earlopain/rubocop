# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Encoding, :config do
  it 'does not register an offense when no encoding present' do
    expect_no_offenses(<<~RUBY)
      def foo() end
    RUBY
  end

  it 'does not register an offense on a different magic comment type' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
      def foo() end
    RUBY
  end
end
