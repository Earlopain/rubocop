# frozen_string_literal: true

require 'rubocop'

desc 'Run codespell, if available'
task :codespell do
  system('codespell --ignore-words=codespell.txt')
  exit($CHILD_STATUS.exitstatus) unless [0, 127].include?($CHILD_STATUS.exitstatus)
end
