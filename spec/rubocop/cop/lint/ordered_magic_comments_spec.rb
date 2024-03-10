# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::OrderedMagicComments, :config do
  it 'does not register an offense when using `frozen_string_literal` magic comment only' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true
    RUBY
  end

  it 'does not register an offense when using ' \
     '`encoding: Encoding::SJIS` Hash notation after' \
     '`frozen_string_literal` magic comment' do
    expect_no_offenses(<<~RUBY)
      # frozen_string_literal: true

      x = { encoding: Encoding::SJIS }
      puts x
    RUBY
  end
end
