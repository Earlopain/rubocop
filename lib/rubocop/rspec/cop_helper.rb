# frozen_string_literal: true

require 'tempfile'

# This module provides methods that make it easier to test Cops.
module CopHelper
  extend RSpec::SharedContext

  let(:ruby_version) do
    # The minimum version Prism can parse is 3.3.
    ENV['PARSER_ENGINE'] == 'parser_prism' ? 3.3 : RuboCop::TargetRuby::DEFAULT_VERSION
  end
  let(:parser_engine) { ENV.fetch('PARSER_ENGINE', :parser_whitequark).to_sym }
  let(:rails_version) { false }

  def inspect_source(source, file = nil, index)
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
    processed_source = parse_source(source, file)
    return unless processed_source.valid_syntax?

    _investigate(cop, processed_source, index)
  end

  def parse_source(source, file = nil)
    if file.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    processed_source = RuboCop::ProcessedSource.new(
      source, ruby_version, file, parser_engine: parser_engine
    )
    processed_source.config = configuration
    processed_source.registry = registry
    processed_source
  end

  def configuration
    @configuration ||= if defined?(config)
                         config
                       else
                         RuboCop::Config.new({}, "#{Dir.pwd}/.rubocop.yml")
                       end
  end

  def registry
    @registry ||= begin
      keys = configuration.keys
      cops =
        keys.map { |directive| RuboCop::Cop::Registry.global.find_cops_by_directive(directive) }
            .flatten
      cops << cop_class if defined?(cop_class) && !cops.include?(cop_class)
      cops.compact!
      RuboCop::Cop::Registry.new(cops)
    end
  end

  def _investigate(cop, processed_source, index)
    team = RuboCop::Cop::Team.new([cop], configuration, raise_error: true)
    report = team.investigate(processed_source)
    instance_variable_set(
      :"@last_corrector_#{index}",
      report.correctors.first || RuboCop::Cop::Corrector.new(processed_source)
    )
  end
end

module RuboCop
  module Cop
    # Monkey-patch Cop for tests to provide easy access to messages and
    # highlights.
    class Cop
      def messages
        offenses.sort.map(&:message)
      end

      def highlights
        offenses.sort.map { |o| o.location.source }
      end
    end
  end
end
