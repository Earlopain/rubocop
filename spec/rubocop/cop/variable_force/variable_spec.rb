# frozen_string_literal: true

require 'rubocop/ast/sexp'

RSpec.describe RuboCop::Cop::VariableForce::Variable do
  include RuboCop::AST::Sexp

  describe '.new' do
    context 'when non variable declaration node is passed' do
      it 'raises error' do
        name = :foo
        declaration_node = s(:def)
        scope = RuboCop::Cop::VariableForce::Scope.new(s(:class))
        expect { described_class.new(name, declaration_node, scope) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#referenced?' do
    subject { variable.referenced? }

    let(:name) { :foo }
    let(:declaration_node) { s(:arg, name) }
    let(:scope) { instance_double(RuboCop::Cop::VariableForce::Scope).as_null_object }
    let(:variable) { described_class.new(name, declaration_node, scope) }

    context 'when the variable is not assigned' do
      it { is_expected.to be(false) }

      context 'and the variable is referenced' do
        before { variable.reference!(s(:lvar, name)) }

        it { is_expected.to be(true) }
      end
    end

    context 'when the variable has an assignment' do
      before { variable.assign(s(:lvasgn, name)) }

      context 'and the variable is not yet referenced' do
        it { is_expected.to be(false) }
      end

      context 'and the variable is referenced' do
        before { variable.reference!(s(:lvar, name)) }

        it { is_expected.to be(true) }
      end
    end
  end
end
